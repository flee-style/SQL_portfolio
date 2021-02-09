/* 取得したデータを加工 */
data WORK.TWEET;
	set WORK.TWEET;
	/* F8などの変数チェック */
	where F8 is null;
run;