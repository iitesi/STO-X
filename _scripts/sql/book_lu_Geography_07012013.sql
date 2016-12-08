USE [book]
GO

ALTER TABLE [lu_Geography]
ADD City_Code BIT NULL
GO

UPDATE [lu_Geography]
SET City_Code = 1
WHERE Location_Type = 125
	AND Location_Code IN (
		'BER'
		,'BJS'
		,'BUE'
		,'BUH'
		,'CHI'
		,'DTT'
		,'LON'
		,'MIL'
		,'MOW'
		,'NYC'
		,'OSA'
		,'PAR'
		,'RIO'
		,'ROM'
		,'SAO'
		,'SEL'
		,'SPK'
		,'STO'
		,'TYO'
		,'WAS'
		,'YEA'
		,'YMQ'
		,'YTO'
	)
GO

UPDATE [lu_Geography]
SET City_Code = 0
WHERE City_Code IS NULL
GO

INSERT INTO [lu_Geography] (
	Location_Display
	,Location_Name
	,Location_Code
	,Airport_Name
	,Region_Name
	,Region_Code
	,Country_Name
	,Country_Code
	,Lat
	,Long
	,Location_Type
	,Checked
	,City_Code
)
VALUES (
	'Dallas Metro Area (DFW), Dallas, TX, US'
	,'Dallas'
	,'DFW'
	,'Dallas'
	,'Dallas'
	,'TX'
	,'United States'
	,'US'
	,'32.7801399'
	,'-96.8004511'
	,125
	,'0'
	,1
)
GO

INSERT INTO [lu_Geography] (
	Location_Display
	,Location_Name
	,Location_Code
	,Airport_Name
	,Region_Name
	,Region_Code
	,Country_Name
	,Country_Code
	,Lat
	,Long
	,Location_Type
	,Checked
	,City_Code
)
VALUES (
	'Houston Metro Area (HOU), Houston, TX, US'
	,'Houston'
	,'HOU'
	,'Houston'
	,'Houston'
	,'TX'
	,'United States'
	,'US'
	,'29.7601927'
	,'-95.3693896'
	,125
	,'0'
	,1
)
GO