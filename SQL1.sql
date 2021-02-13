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
    like_num VARCHAR(100)
  );
  COPY Tweet FROM 'C:\ProgramData\SampleData\Tweet2.csv' WITH csv;

  -- Company Data
  DROP TABLE IF EXISTS Company;
  CREATE TABLE Company(
    ticker_symbol VARCHAR(20),
    company_name  VARCHAR(20)
  );
  COPY Company FROM 'C:\ProgramData\SampleData\Company.csv' WITH csv HEADER;

  -- Company_Tweet Data
  DROP TABLE IF EXISTS Company_Tweet;
  CREATE TABLE Company_Tweet(
    tweet_id BIGINT,
    ticker_symbol VARCHAR(20)
  );
  COPY Company_Tweet FROM 'C:\ProgramData\SampleData\Company_Tweet.csv' WITH csv HEADER;

-- select *
-- from Company_Tweet
-- limit 100;

  -- CompanyValues Data
  --   2010-06-01からデータが存在している。
  DROP TABLE IF EXISTS Company_Values;
  CREATE TABLE Company_Values(
    ticker_symbol VARCHAR(20),
    day_date VARCHAR(10),
    close_value REAL,
    volume INTEGER,
    open_value REAL,
    high_value REAL,
    low_value REAL
  );
  COPY Company_Values FROM 'C:\ProgramData\SampleData\CompanyValues.csv' WITH csv HEADER;

-- ツイート年月日、2010～2020の範囲なのか?
-- SELECT *
-- FROM Company_Values
-- ORDER BY day_date
-- limit 100;

-- 2.ツイートデータと会社名データを結合,EPOCH時間を変換
DROP TABLE IF EXISTS Tweetdata01;
CREATE TABLE Tweetdata01 AS
SELECT C.tweet_id,
      ticker_symbol AS Company_symbol,
      day_date
      index_startdate, 
      index_enddate, 
      count_bodytext AS body_cnt, 
      text_cat AS body_cat,
      comment_num,
      retweet_num, 
      like_num, 
      close_value
FROM(--Tweet,Company_Tweetデータのマージ
      SELECT tweet_id,
          ticker_symbol,
          post_date,
          TO_TIMESTAMP(post_date)::date as day_date,
          MIN(post_date) OVER(PARTITION BY ticker_symbol) AS index_startdate,
          MAX(post_date) OVER(PARTITION BY ticker_symbol) AS index_enddate,
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
      FROM (SELECT * FROM Tweet LIMIT 100000) AS A
        INNER JOIN (SELECT * FROM Company_Tweet LIMIT 100000) AS B USING(tweet_id)) AS C
  INNER JOIN (--Company_Valuesデータのマージ 
              SELECT ticker_symbol, day_date::date AS day_date, close_value FROM Company_Values LIMIT 10000) AS D
          USING(ticker_symbol,day_date);
          
SELECT *
FROM Tweetdata01
LIMIT 100
;

-- データ検証1　
-- 100行データ：結合テスト,index_startdate,index_enddate,close_value
-- 全行データ:??
