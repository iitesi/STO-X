USE [book]
GO

ALTER TABLE [Searches]
ADD
	CarPickup_Airport VARCHAR(3) NULL
	,CarPickup_DateTime DATETIME NULL
	,CarDropoff_DateTime DATETIME NULL
GO