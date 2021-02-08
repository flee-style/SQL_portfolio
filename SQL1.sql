-- CSVインポート
drop table if exists Tweet;
create table Tweet(
  tweet_id varchar(20),
  writer varchar(30),
  post_date bigint,
  body text,
  comment_num int,
  retweet_num int,
  like_num int
);

-- copy Tweet from 'C:\Users\user\Documents\データサイエンティスト\ポートフォリオ作成\SQL\Tweet.csv' with csv;
-- 
WbImport -type=text
-file='C:\Users\user\Documents\データサイエンティスト\ポートフォリオ作成\SQL\Tweet.csv'
-delimiter=,
-table=tweet
-quoteChar=""
-badfile='C:\Users\user\Documents\データサイエンティスト\ポートフォリオ作成\SQL\rejected'
-continueOnError=true
-multiLine=true
-emptyStringIsNull=false;

-- ツイッター本文の""に囲まれた,に反応し読み込みができない。2021/02/08
