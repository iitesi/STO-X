USE [booking]
GO

/****** Object:  Table [dbo].[Logs]    Script Date: 07/12/2013 08:35:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Logs](
	[Log_ID] [int] IDENTITY(1,1) NOT NULL,
	[Search_ID] [int] NULL,
	[Acct_ID] [int] NULL,
	[User_ID] [int] NULL,
	[ElapsedTime] [float] NULL,
	[Service] [varchar](50) NULL,
	[Request] [text] NULL,
	[Response] [text] NULL,
	[Timestamp] [datetime] NULL,
 CONSTRAINT [PK_Logs] PRIMARY KEY CLUSTERED 
(
	[Log_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[Logs] ADD  CONSTRAINT [DF_Logs_Timestamp]  DEFAULT (getdate()) FOR [Timestamp]
GO

USE [booking]
GO

/****** Object:  StoredProcedure [dbo].[sp_logSTO]    Script Date: 07/12/2013 08:36:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_logSTO]
	@SearchID int
   ,@AcctID int
   ,@UserID int
   ,@ElapsedTime float
   ,@Service varchar
   ,@Request text
   ,@Response text
AS
BEGIN

	SET NOCOUNT ON;

	INSERT INTO [booking].[dbo].[Logs]
           ([Search_ID]
           ,[Acct_ID]
           ,[User_ID]
           ,[ElapsedTime]
           ,[Service]
           ,[Request]
           ,[Response])
     VALUES
           (@SearchID
           ,@AcctID
           ,@UserID
           ,@ElapsedTime
           ,@Service
           ,@Request
           ,@Response)

END

GO


