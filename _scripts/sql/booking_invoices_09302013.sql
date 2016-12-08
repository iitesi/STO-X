USE [booking]
GO

/****** Object:  Table [dbo].[Invoices]    Script Date: 09/30/2013 09:05:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Invoices](
	[invoiceID] [int] IDENTITY(1,1) NOT NULL,
	[searchID] [int] NOT NULL,
	[recloc] [varchar](10) NULL,
	[urRecloc] [varchar](10) NULL,
	[firstName] [varchar](50) NULL,
	[lastName] [varchar](50) NULL,
	[travelerNumber] [int] NULL,
	[air] [int] NULL,
	[airSelection] [text] NULL,
	[car] [int] NULL,
	[carSelection] [text] NULL,
	[hotel] [int] NULL,
	[hotelSelection] [text] NULL,
	[userID] [int] NULL,
	[profileID] [int] NULL,
	[valueID] [int] NULL,
	[policyID] [int] NULL,
	[filter] [text] NULL,
	[timestamp] [datetime] NULL,
	[active] [int] NULL,
 CONSTRAINT [PK_Invoices] PRIMARY KEY CLUSTERED 
(
	[invoiceID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[Invoices] ADD  CONSTRAINT [DF_Invoices_timestamp]  DEFAULT (getdate()) FOR [timestamp]
GO

ALTER TABLE [dbo].[Invoices] ADD  CONSTRAINT [DF_Invoices_active]  DEFAULT ((1)) FOR [active]
GO

