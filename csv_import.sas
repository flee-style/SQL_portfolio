filename IN 'C:\Users\user\Google �h���C�u\�t���[�����X\portfolio\SQL\Tweet.csv';
data Tweet;
	infile IN dlm=',' missover encoding=any;
	input tweet_id $ writer $30. post_date body $500. comment_num retweet_num like_num;
run;