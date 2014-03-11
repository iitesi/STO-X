USE [booking]
GO

ALTER TABLE Accounts
ADD
	ConfirmationMessage_NotRequired VARCHAR(1000) NULL
	,ConfirmationMessage_Required VARCHAR(1000) NULL

GO