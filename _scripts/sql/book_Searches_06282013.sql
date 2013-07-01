USE [book]
GO

ALTER TABLE [Searches]
ADD
	CarPickup_DateTimeActual VARCHAR(20) NULL
	,CarDropoff_DateTimeActual VARCHAR(20) NULL
	,Depart_DateTimeActual VARCHAR(20) NULL
	,Depart_DateTimeStart DATETIME NULL
	,Depart_DateTimeEnd DATETIME NULL
	,Arrival_DateTimeActual VARCHAR(20) NULL
	,Arrival_DateTimeStart DATETIME NULL
	,Arrival_DateTimeEnd DATETIME NULL
	,AirFrom_CityCode BIT NULL
	,AirTo_CityCode BIT NULL
GO