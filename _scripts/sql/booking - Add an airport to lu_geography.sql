USE BOOKING

SELECT *
FROM lu_Geography
WHERE Location_Type = 125
AND Location_Code = 'BSB'

SELECT MAX(Geography_ID)+1
FROM lu_Geography

INSERT INTO lu_Geography
	( Geography_ID
	, Location_Display
	, Location_Name
	, Location_Code
	, Location_Type
	, Airport_Name
	, Country_Name
	, Country_Code
	, Lat
	, Long )
VALUES
	( 200601
	, 'Brasilia Arpt (BSB), Brasilia, BR'
	, 'Brasilia'
	, 'BSB'
	, 125
	, 'Brasilia Arpt'
	, 'BR'
	, 'BR'
	, 15.8692
	, 47.9208 )
