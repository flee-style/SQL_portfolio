/* �擾�����f�[�^�����H */
DATA _null_;
	file 'C:\Users\user\Documents\�f�[�^�T�C�G���e�B�X�g\�|�[�g�t�H���I�쐬\sample_data\Tweet2.csv' 
		dsd ;
	set WORK.TWEET;
	count_text = length(body);
	rc2 = COMPRESS(comment_num,,'KF');
	rc3 = COMPRESS(retweet_num,,'KF');
	rc4 = COMPRESS(like_num,,'KF'); 
	/* ���l�ϐ��ɕ����񂪓����Ă���s���o�� */
	if not(rc2 ^= null or rc3 ^= null or rc4 ^= null) 
		then put tweet_id writer $ post_date count_text comment_num $ retweet_num $ like_num $;
run;