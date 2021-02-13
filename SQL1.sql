-- 1. CSVインポート
  -- Tweet Data
  DROP TABLE IF EXISTS TWEET;
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
  SELECT *
  FROM  Company_Values
  WHERE '2015-01-01' <= tweet_date AND tweet_date <= '2020-12-31'
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

-- 3.データ加工
DROP TABLE IF EXISTS Tweetdata01;
CREATE TABLE Tweetdata01 AS
--Tweet,Company_Tweetデータのマージ
  SELECT tweet_id,
          ticker_symbol,
          tweet_date,
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

-- index_date作成
DROP TABLE IF EXISTS Tweetdata02;
CREATE TABLE Tweetdata02 AS  
  SELECT ticker_symbol AS Company_symbol,
        MIN(tweet_date) AS index_startdate,
        MAX(tweet_date) AS index_enddate
  FROM Tweetdata01
  GROUP BY 1
  ;
  
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
