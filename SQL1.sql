DROP TABLE IF EXISTS Tweet;
CREATE TABLE Tweet(
    tweet_id BIGINT,
    writer VARCHAR(30),
    post_date BIGINT,
    count_bodytext SMALLINT,
    comment_num VARCHAR(100),
    retweet_num VARCHAR(100),
    like_num VARCHAR(100));
  COPY Tweet FROM 'C:\ProgramData\SampleData\Tweet2.csv' WITH csv;
  
-- 検証用2015年ツイートデータ   
DROP TABLE IF EXISTS Tweet1;
CREATE TABLE Tweet1 AS 
  SELECT tweet_id,post_date,count_bodytext,
          COALESCE(comment_num,'0') AS comment_num ,
          COALESCE(retweet_num,'0') AS retweet_num ,
          COALESCE(like_num,'0')    AS like_num,
          TO_TIMESTAMP(post_date)::date AS tweet_date
  FROM TWEET
--   WHERE  TO_TIMESTAMP(post_date)::date < '2016-01-01'
;

-- Company_Tweet Data
DROP TABLE IF EXISTS Company_Tweet;
CREATE TABLE Company_Tweet(
  tweet_id BIGINT,
  ticker_symbol VARCHAR(20)
);COPY Company_Tweet FROM 'C:\ProgramData\SampleData\Company_Tweet.csv' WITH csv HEADER;

-- GOOGをGOOGLに変更
DROP TABLE IF EXISTS Company_Tweet1;
CREATE TABLE Company_Tweet1 AS
  SELECT tweet_id
        ,CASE WHEN ticker_symbol = 'GOOG' THEN 'GOOGL' ELSE ticker_symbol END AS ticker_symbol
  FROM Company_Tweet
;

-- Tweet2015,Company_Tweet結合
DROP TABLE IF EXISTS Tweetdata01;
CREATE TABLE Tweetdata01 AS
--Tweet,Company_Tweetデータのマージ
  SELECT tweet_id,
          ticker_symbol,
          tweet_date::date AS tweet_date,
          count_bodytext,
--           CASE  WHEN count_bodytext < 50 THEN 1
--           WHEN count_bodytext < 100 THEN 2
--           WHEN count_bodytext < 150 THEN 3
--           WHEN count_bodytext < 200 THEN 4
--           WHEN count_bodytext < 250 THEN 5
--           WHEN count_bodytext < 300 THEN 6
--           ELSE 0 END AS text_cat,
          RIGHT(RIGHT(comment_num,1),1),
          CASE WHEN comment_num          IS NULL THEN '0'
               WHEN RIGHT(comment_num,1) = '"' AND LEFT(comment_num,1) = '7' THEN LEFT(comment_num,3)
               ELSE                                   comment_num        END AS comment_num,
          CASE WHEN retweet_num IS NULL THEN '0' ELSE retweet_num END AS retweet_num,
          CASE WHEN like_num IS NULL THEN '0' ELSE like_num END AS like_num                 
  FROM Tweet1
    INNER JOIN Company_Tweet1 USING(tweet_id)
--   WHERE tweet_id = 635902108449959936
    ;
    
CREATE OR REPLACE FUNCTION isnumeric(c_num character varying)
  RETURNS boolean AS
$BODY$
declare
	n_result 		numeric;  -- 一時変数
BEGIN
    --数値へcastする
	select cast(c_num as numeric) into n_result;
	--castできる時はtrueでリターン
	return TRUE;
	
	EXCEPTION
	WHEN OTHERS THEN
	--castできずエラーになる時はfalseでリターン
	return FALSE;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
    
-- comment_num,retweet_num,like_numの数値のみのデータを残す
DROP TABLE IF EXISTS Tweetdata01_1;
CREATE TABLE Tweetdata01_1 AS
  SELECT tweet_id
         ,ticker_symbol
         ,tweet_date
         ,count_bodytext
         ,comment_num
         ,retweet_num
         ,like_num 
  FROM Tweetdata01
  GROUP BY 1,2,3,4,5,6,7
  HAVING  COUNT(CASE WHEN isnumeric(comment_num) AND isnumeric(retweet_num) AND isnumeric(like_num) THEN NULL
                ELSE 1 END) <> 1
  ;
  
-- CompanyValues Data
--   2010-06-01からデータが存在している。
DROP TABLE IF EXISTS Company_Values;
CREATE TABLE Company_Values(
    ticker_symbol VARCHAR(20),
    tweet_date VARCHAR(10),
    close_value REAL,
    volume INTEGER,
    open_value REAL,
    high_value REAL,
    low_value REAL
);COPY Company_Values FROM 'C:\ProgramData\SampleData\CompanyValues.csv' WITH csv HEADER; 

-- 会社の株価を2015年から2020年に絞る。2020-01-01の株価データがないため前日の株価を入れる。
DROP TABLE IF EXISTS Company_Values1;
CREATE TABLE Company_Values1 AS  
  SELECT CASE WHEN ticker_symbol = 'GOOG' THEN 'GOOGL' ELSE ticker_symbol END AS ticker_symbol
        ,tweet_date::date
        ,close_value
  FROM  Company_Values
--   WHERE '2015-01-01' <= tweet_date AND tweet_date <= '2021-01-01'
  ;

-- 株価データと結合
DROP TABLE IF EXISTS Tweetdata01_2;
CREATE TABLE Tweetdata01_2 AS
  SELECT DISTINCT
            T1.tweet_id
         ,  T1.ticker_symbol
         ,  t1.tweet_date
         ,  count_bodytext
         ,  comment_num
         ,  retweet_num
         ,  like_num 
         ,  MIN(T2.close_value) OVER(PARTITION BY T1.tweet_id , T1.ticker_symbol , T2.tweet_date)  AS Company_value
  FROM Tweetdata01_1 AS T1 FULL OUTER JOIN Company_Values1 AS T2
    ON T1.ticker_symbol = T2.ticker_symbol AND T1.tweet_date = T2.tweet_date 
;

-- 2020-01-01の日付の株価は前日の株価を設定する
DROP TABLE IF EXISTS Tweetdata01_2_beforedate;
CREATE TABLE Tweetdata01_2_beforedate AS
  SELECT  tweet_id
        , ticker_symbol
        , tweet_date
        , count_bodytext
        , comment_num
        , retweet_num
        , like_num
        , CASE WHEN tweet_date = '2020-01-01' THEN (SELECT DISTINCT company_value
                                                      FROM Tweetdata01_2 T2
                                                     WHERE T2.ticker_symbol = T1.ticker_symbol AND tweet_date = '2019-12-31') ELSE company_value END AS Company_value
  FROM  Tweetdata01_2 T1
;
-- 
-- SELECT *
-- FROM Tweetdata01_2_beforedate
-- WHERE tweet_date = '2020-01-01'

 -- Company Data
DROP TABLE IF EXISTS Company;
CREATE TABLE Company(
  ticker_symbol VARCHAR(20),
  company_name  VARCHAR(20)
);COPY Company FROM 'C:\ProgramData\SampleData\Company.csv' WITH csv HEADER;

-- 会社名を名称に変更
DROP TABLE IF EXISTS Tweetdata01_3;
CREATE TABLE Tweetdata01_3 AS
  SELECT tweet_id
         ,T2.company_name
         ,T1.ticker_symbol
         ,tweet_date
         ,count_bodytext
         ,comment_num
         ,retweet_num
         ,like_num  
         ,company_value
  FROM Tweetdata01_2_beforedate T1
    INNER JOIN Company T2 ON T1.ticker_symbol = T2.ticker_symbol 
;

-- 帳票用データ1
DROP TABLE IF EXISTS Tweetdata01_4;
CREATE TABLE Tweetdata01_4 AS
  SELECT company_name
        ,ticker_symbol
         , tweet_date
         , date_part('year', tweet_date) 
            || '-' || CASE WHEN '1' <= date_part('month', tweet_date) AND date_part('month', tweet_date) <= '9'
                      THEN '0' || date_part('month', tweet_date) 
                      ELSE   date_part('month', tweet_date)::varchar END as tweet_ymdate
         , COUNT(tweet_id)       AS tweet_num
         , SUM(count_bodytext)   AS tweet_text_sum
         , SUM(comment_num::int) AS tweet_comment_sum
         , MAX(comment_num::int) AS tweet_comment_max
         , SUM(retweet_num::int) AS tweet_retweet_sum
         , MAX(retweet_num::int) AS tweet_retweet_max
         , SUM(like_num::int)    AS tweet_like_sum
         , MAX(like_num::int)    AS tweet_like_max
         , Company_value
  FROM Tweetdata01_3
  WHERE tweet_date <= '2020-05-29'
  GROUP BY company_name,ticker_symbol, tweet_date , Company_value
  ;

 
-- 日付にて終値の変化を作成
DROP TABLE IF EXISTS Tweetdata01_5;
CREATE TABLE Tweetdata01_5 AS
  SELECT    T1.company_name
        ,   T1.ticker_symbol
        ,   T1.tweet_date
        ,   T1.tweet_ymdate
        ,   T1.tweet_num
        ,   T1.tweet_text_sum
        ,   T1.tweet_comment_sum
        ,   T1.tweet_comment_max
        ,   T1.tweet_retweet_sum
        ,   T1.tweet_retweet_max
        ,   T1.tweet_like_sum
        ,   T1.tweet_like_max
        ,   T1.Company_value
        ,  CASE WHEN T1.company_value = T2.company_value THEN '→'
                WHEN T1.company_value < T2.company_value THEN '↑'
                WHEN T1.company_value > T2.company_value THEN '↓' 
                ELSE NULL END AS Company_variation
  FROM Tweetdata01_4 T1, Tweetdata01_4 T2
  WHERE T1.ticker_symbol = T2.ticker_symbol
    AND T1.tweet_date + 1 = T2.tweet_date
    ;

-- 帳票用データ2
DROP TABLE IF EXISTS Tweetdata01_6;
CREATE TABLE Tweetdata01_6 AS
  SELECT company_name
         , tweet_ymdate
         , SUM(tweet_num )       AS tweet_num
         , SUM(tweet_text_sum)   AS tweet_text_sum
         , SUM(tweet_comment_sum) AS tweet_comment_sum
         , MAX(tweet_comment_max) AS tweet_comment_max
         , SUM(tweet_retweet_sum) AS tweet_retweet_sum
         , MAX(tweet_retweet_max) AS tweet_retweet_max
         , SUM(tweet_like_sum)    AS tweet_like_sum
         , MAX(tweet_like_max)    AS tweet_like_max
         , AVG(Company_value)     AS Company_value
  FROM Tweetdata01_5
  WHERE tweet_date <= '2020-05-29'
  GROUP BY company_name, tweet_ymdate
  ORDER BY 1,2
  ;

-- SELECT *
-- FROM
-- (SELECT company_name, tweet_ymdate, COUNT(tweet_ymdate) AS count_
-- FROM   Tweetdata01_6
-- GROUP BY company_name, tweet_ymdate) AS T1
-- WHERE 1 < count_
-- ;

-- 帳票1作成
DROP TABLE IF EXISTS Tweetdata02 ;
CREATE TABLE Tweetdata02 AS
  SELECT company_name,
        SUM(tweet_num)              AS tweet_count,
        SUM(tweet_text_sum)         AS text_sum,
        SUM(tweet_text_sum) / SUM(tweet_num)      AS text_mean,
        SUM(tweet_comment_sum)      AS comment_count,
        SUM(tweet_comment_sum) / SUM(tweet_num) AS comment_mean,
        MAX(tweet_comment_max)      AS comment_max,
        SUM(tweet_retweet_sum)      AS retweet_count,
        SUM(tweet_retweet_sum) / SUM(tweet_num) AS retweet_mean,
        MAX(tweet_retweet_max)      AS retweet_max,
        SUM(tweet_like_sum)         AS like_count,
        SUM(tweet_like_sum) / SUM(tweet_num)    AS like_mean,
        MAX(tweet_like_max)         AS like_max
  FROM Tweetdata01_6
  GROUP BY company_name
  ;
  
-- 帳票2作成
DROP TABLE IF EXISTS Tweetdata03 ;
CREATE TABLE Tweetdata03 AS
  SELECT company_name,
          Company_variation,
        SUM(tweet_num)              AS tweet_count,
        SUM(tweet_text_sum)         AS text_sum,
        SUM(tweet_text_sum) / SUM(tweet_num)      AS text_mean,
        SUM(tweet_comment_sum)      AS comment_count,
        SUM(tweet_comment_sum) / SUM(tweet_num) AS comment_mean,
        MAX(tweet_comment_max)      AS comment_max,
        SUM(tweet_retweet_sum)      AS retweet_count,
        SUM(tweet_retweet_sum) / SUM(tweet_num) AS retweet_mean,
        MAX(tweet_retweet_max)      AS retweet_max,
        SUM(tweet_like_sum)         AS like_count,
        SUM(tweet_like_sum) / SUM(tweet_num)    AS like_mean,
        MAX(tweet_like_max)         AS like_max
  FROM Tweetdata01_5
  GROUP BY company_name,Company_variation
  ORDER BY 1,2
  ;
  
commit;
