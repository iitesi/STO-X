USE [booking]
GO

ALTER TABLE Accounts
ADD PrePaid_Rates BIT NOT NULL
CONSTRAINT PrePaid_Rates_Default DEFAULT 1

GO