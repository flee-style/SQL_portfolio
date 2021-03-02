/* 取得したデータを加工 */
DATA _null_;
	file 'C:\Users\user\Documents\データサイエンティスト\ポートフォリオ作成\sample_data\Tweet2.csv' 
		dsd ;
	set WORK.TWEET;
	count_text = length(body);
	rc2 = COMPRESS(comment_num,,'KF');
	rc3 = COMPRESS(retweet_num,,'KF');
	rc4 = COMPRESS(like_num,,'KF'); 
	/* 数値変数に文字列が入っている行を出力 */
	if not(rc2 ^= null or rc3 ^= null or rc4 ^= null) 
		then put tweet_id writer $ post_date count_text comment_num $ retweet_num $ like_num $;
run;