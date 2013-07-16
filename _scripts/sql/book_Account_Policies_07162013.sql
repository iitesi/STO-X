USE [book]
GO

UPDATE [Account_Policies]
SET Policy_Window = 4
WHERE Policy_Window IS NULL 

GO