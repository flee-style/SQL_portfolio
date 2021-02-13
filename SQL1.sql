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
  COPY Company COPY 'C:\ProgramData\SampleData\Company.csv' WITH csv HEADER;

  -- Company_Tweet Data
  DROP TABLE IF EXISTS Company_Tweet;
  CREATE TABLE Company_Tweet(
    tweet_id BIGINT,
    ticker_symbol VARCHAR(20)
  );
  COPY Company_Tweet COPY 'C:\ProgramData\SampleData\Company_Tweet.csv' WITH csv HEADER;
  
  -- CompanyValues Data
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
  COPY Company_Values COPY 'C:\ProgramData\SampleData\CompanyValues.csv' WITH csv HEADER;

-- 2.ツイートデータと会社名データを結合

-- 3.企業ごとにツイートされた数、ツイート文字数の平均と中央値、コメント数、リツイート数、いいねの数を集計

-- 4.会社名データとツイート

-- ツイッター本文の""に囲まれた,に反応し読み込みができない。2021/02/08
