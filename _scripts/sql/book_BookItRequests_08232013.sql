USE [book]
GO

ALTER TABLE [BookItRequests]
ADD
	Guest CHAR(1) NULL
	,GuestDepartment INT NULL

GO