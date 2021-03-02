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
DROP TABLE IF EXISTS Tweet_2015;
CREATE TABLE Tweet_2015 AS 
  SELECT tweet_id,post_date,count_bodytext,
          COALESCE(comment_num,'0') AS comment_num ,
          COALESCE(retweet_num,'0') AS retweet_num ,
          COALESCE(like_num,'0')    AS like_num,
          TO_TIMESTAMP(post_date)::date AS tweet_date
  FROM TWEET
  WHERE  TO_TIMESTAMP(post_date)::date < '2016-01-01'
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
          CASE  WHEN count_bodytext < 50 THEN 1
          WHEN count_bodytext < 100 THEN 2
          WHEN count_bodytext < 150 THEN 3
          WHEN count_bodytext < 200 THEN 4
          WHEN count_bodytext < 250 THEN 5
          WHEN count_bodytext < 300 THEN 6
          ELSE 0 END AS text_cat,
          CASE WHEN comment_num IS NULL THEN '0' ELSE comment_num END AS comment_num,
          CASE WHEN retweet_num IS NULL THEN '0' ELSE retweet_num END AS retweet_num,
          CASE WHEN like_num IS NULL THEN '0' ELSE like_num END AS like_num                 
  FROM Tweet_2015
    INNER JOIN Company_Tweet1 USING(tweet_id)
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
    
-- 数値以外の値をcomment_numなどの変数から削除
DROP TABLE IF EXISTS Tweetdata01_1;
CREATE TABLE Tweetdata01_1 AS

 = true
  ;
  
-- 帳票作成
DROP TABLE IF EXISTS Tweetdata02 ;
CREATE TABLE Tweetdata02 AS
SELECT ticker_symbol,
      COUNT(tweet_id) AS tweet_count,
      AVG(CAST(count_bodytext AS int)) AS text_mean,
      PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY count_bodytext),
      SUM(CAST(comment_num AS int)) AS comment_count,
      AVG(CAST(comment_num AS int)) AS comment_mean,
      MAX(CAST(comment_num AS int)) AS comment_max,
      SUM(CAST(retweet_num AS int)) AS retweet_count,
      AVG(CAST(retweet_num AS int)) AS retweet_mean,
      MAX(CAST(retweet_num AS int)) AS retweet_max,
      SUM(CAST(like_num AS int)) AS like_count,
      AVG(CAST(like_num AS int)) AS like_mean,
      MAX(CAST(like_num AS int)) AS like_max
FROM Tweetdata01_1
GROUP BY ticker_symbol
limit 100
;
    
SELECT *
fROM Tweetdata01
limit 100;

   -- Company Data
  DROP TABLE IF EXISTS Company;
  CREATE TABLE Company(
    ticker_symbol VARCHAR(20),
    company_name  VARCHAR(20)
  );COPY Company FROM 'C:\ProgramData\SampleData\Company.csv' WITH csv HEADER;

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
  -- 会社の株価を2015年から2020年に絞る
  DROP TABLE IF EXISTS Company_Values1;
  CREATE TABLE Company_Values1 AS  
  SELECT ticker_symbol
        ,tweet_date::date
        ,close_value
  FROM  Company_Values
  WHERE '2015-01-01' <= tweet_date AND tweet_date <= '2020-12-31'
--   limit 100
  ;

    


    


-- index_date作成
DROP TABLE IF EXISTS Tweetdata02;
CREATE TABLE Tweetdata02 AS  
  SELECT ticker_symbol AS Company_symbol,
        MIN(tweet_date) AS index_startdate,
        MAX(tweet_date) AS index_enddate
  FROM Tweetdata01
  GROUP BY 1
  ;

-- 検証用2015年会社の株価データ
DROP TABLE IF EXISTS Company_Values2;
CREATE TABLE Company_Values1 AS  
  SELECT *
  FROM   Company_Values1
  WHERE  tweet_date < '2016-01-01'
--   GROUP BY tweet_date
  ;
