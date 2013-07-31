USE [book]
GO

sp_RENAME 'Searches.Redirector', 'SiteURL', 'COLUMN'

GO

sp_RENAME 'Searches.Size', 'Width', 'COLUMN'

GO

ALTER TABLE [Searches]
ADD
	TitleColor VARCHAR(6) NULL
	,SiteEmail VARCHAR(100) NULL

GO