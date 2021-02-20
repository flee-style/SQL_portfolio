-- 1. CSVインポート
  -- Tweet Data
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
   -- Company Data
  DROP TABLE IF EXISTS Company;
  CREATE TABLE Company(
    ticker_symbol VARCHAR(20),
    company_name  VARCHAR(20)
  );COPY Company FROM 'C:\ProgramData\SampleData\Company.csv' WITH csv HEADER;
  -- Company_Tweet Data
  DROP TABLE IF EXISTS Company_Tweet;
  CREATE TABLE Company_Tweet(
    tweet_id BIGINT,
    ticker_symbol VARCHAR(20)
  );COPY Company_Tweet FROM 'C:\ProgramData\SampleData\Company_Tweet.csv' WITH csv HEADER;
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

-- 2.検証用データ作成
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
  
-- SELECT *
-- FROM Tweet_2015
-- LIMIT 100
-- ;

-- 3.データ加工
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
          comment_num,
          retweet_num,
          like_num
  FROM Tweet_2015
    INNER JOIN Company_Tweet USING(tweet_id)
    ;
    
-- 数値以外の値
DROP TABLE IF EXISTS Tweetdata01_1;
CREATE TABLE Tweetdata01_1 AS
  SELECT *
  FROM 
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
FROM Tweetdata01_1 AS A
GROUP BY ticker_symbol
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
  
SELECT *
FROM Company_Values
LIMIT 100
;

-- 検証用2015年会社の株価データ
DROP TABLE IF EXISTS Company_Values1;
CREATE TABLE Company_Values1 AS  
  SELECT *
  FROM   Company_Values
  WHERE  tweet_date < '2016-01-01'
--   GROUP BY tweet_date
  ;

-- SELECT *
-- FROM Tweetdata01
-- INNER JOIN Company_Values1 USING(ticker_symbol,tweet_date)
-- LIMIT 100;
  
-- 継続判定フラグ作成

-- 毎日ツイートフラグ判定

  
    INNER JOIN (--Company_Valuesデータのマージ 
                SELECT ticker_symbol, day_date::date AS day_date, close_value FROM Company_Values1 LIMIT 10000) AS D
            USING(ticker_symbol,day_date);
          
SELECT *
FROM Tweetdata01
LIMIT 100
;

-- データ検証1　
-- 100行データ：結合テスト,index_startdate,index_enddate,close_value
-- 全行データ:??
