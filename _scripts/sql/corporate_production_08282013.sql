ALTER TABLE Users
ADD token [varchar](500) NULL;

UPDATE Users
SET Users.token = susers.s
FROM susers
	JOIN Users
		ON Users.User_ID = susers.User_ID;