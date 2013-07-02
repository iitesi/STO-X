USE [book]
GO

ALTER TABLE [Accounts]
ADD Air_Policy_Window INT NULL
GO

UPDATE [Accounts]
SET Air_Policy_Window = 6
WHERE Acct_ID = 1
GO