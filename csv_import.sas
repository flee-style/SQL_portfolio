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

/*DATA WORK.Tweet;*/
/*    LENGTH*/
/*        tweet_id           8*/
/*        writer           $ 17*/
/*        post_date          8*/
/*        body             $ 5436*/
/*        comment_num      $ 521*/
/*        retweet_num      $ 336*/
/*        like_num         $ 268 ;*/
/*    KEEP*/
/*        tweet_id*/
/*        writer*/
/*        post_date*/
/*        body*/
/*        comment_num*/
/*        retweet_num*/
/*        like_num ;*/
/*    FORMAT*/
/*        tweet_id         BEST19.*/
/*        writer           $CHAR17.*/
/*        post_date        BEST10.*/
/*        body             $CHAR5436.*/
/*        comment_num      $CHAR521.*/
/*        retweet_num      $CHAR336.*/
/*        like_num         $CHAR268. ;*/
/*    INFORMAT*/
/*        tweet_id         BEST19.*/
/*        writer           $CHAR17.*/
/*        post_date        BEST10.*/
/*        body             $CHAR5436.*/
/*        comment_num      $CHAR521.*/
/*        retweet_num      $CHAR336.*/
/*        like_num         $CHAR268. ;*/
/*    INFILE 'C:\Users\user\AppData\Local\Temp\SEG1212\Tweet-e413ad8cb3ac47279118ceb7833901c4.txt'*/
/*        LRECL=5557*/
/*        ENCODING="SHIFT-JIS"*/
/*        TERMSTR=CRLF*/
/*        DLM='7F'x*/
/*        MISSOVER*/
/*        DSD ;*/
/*    INPUT*/
/*        tweet_id         : ?? BEST19.*/
/*        writer           : $CHAR17.*/
/*        post_date        : ?? BEST10.*/
/*        body             : $CHAR5436.*/
/*        comment_num      : $CHAR521.*/
/*        retweet_num      : $CHAR336.*/
/*        like_num         : $CHAR268.;*/
/*RUN;*/
