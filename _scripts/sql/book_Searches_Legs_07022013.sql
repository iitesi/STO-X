USE [book]
GO

ALTER TABLE [Searches_Legs]
ADD
	Depart_DateTimeActual VARCHAR(20) NULL
	,Depart_DateTimeStart DATETIME NULL
	,Depart_DateTimeEnd DATETIME NULL
	,AirFrom_CityCode BIT NULL
	,AirTo_CityCode BIT NULL
GO