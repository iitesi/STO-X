if NOT exists(select * from sys.columns 
	where Name = N'Details' and Object_ID = Object_ID(N'lu_hotels'))    
begin
  ALTER TABLE lu_hotels
	ADD Details TEXT NULL;
end

if NOT exists(select * from sys.columns 
	where Name = N'DescriptionDetail' and Object_ID = Object_ID(N'lu_hotels'))    
begin
  ALTER TABLE lu_hotels
	ADD DescriptionDetail TEXT NULL;
end

if NOT exists(select * from sys.columns
	where Name = N'StarRating' and Object_ID = Object_ID(N'lu_hotels'))
begin
  ALTER TABLE lu_hotels
	ADD StarRating INT NULL;
	ALTER TABLE lu_hotels
	ADD RatingService varchar(50) NULL;
end

ALTER TABLE lu_hotels
	ALTER COLUMN ServiceDetail TEXT NULL;
ALTER TABLE lu_hotels
	ALTER COLUMN FacilityDetail TEXT NULL;
ALTER TABLE lu_hotels
	ALTER COLUMN RoomDetail TEXT NULL;
ALTER TABLE lu_hotels
	ALTER COLUMN RecreationDetail TEXT NULL
ALTER TABLE lu_hotels
	ALTER COLUMN CancelDetail TEXT NULL;
ALTER TABLE lu_hotels
	ALTER COLUMN GuaranteeDetail TEXT NULL;
ALTER TABLE lu_hotels
	ALTER COLUMN CCPolicyDetail TEXT NULL;
ALTER TABLE lu_hotels
	ALTER COLUMN DepositPolicyDetail TEXT NULL;
ALTER TABLE lu_hotels
	ALTER COLUMN FrequentDetail TEXT NULL;
ALTER TABLE lu_hotels
	ALTER COLUMN HotelLocationDetail TEXT NULL;
ALTER TABLE lu_hotels
	ALTER COLUMN DirectionDetail TEXT NULL;
ALTER TABLE lu_hotels
	ALTER COLUMN AreaTransportationDetail TEXT NULL;