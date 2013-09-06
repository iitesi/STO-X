USE [booking]
GO
/****** Object:  UserDefinedFunction [dbo].[udf_Calculate_Distance]    Script Date: 08/12/2013 17:07:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[udf_Calculate_Distance] (@Latitude1 DECIMAL(16,12), @Longitude1 DECIMAL(16,12), @Latitude2 DECIMAL(16,12), @Longitude2 DECIMAL(16,12))  
RETURNS DECIMAL(10,2)  
AS 
BEGIN
   
DECLARE @distance DECIMAL(10,2)  
  
SET @distance = convert(DECIMAL(10,2),(degrees(acos(sin(radians(@Latitude1)) * sin(radians(@Latitude2)) +   
  cos(radians(@Latitude1))* cos(radians(@Latitude2)) *   
  cos(radians(@Longitude2-(@Longitude1))))) * pi() * 3958.754 / 180))  
  
RETURN(@distance)  
END