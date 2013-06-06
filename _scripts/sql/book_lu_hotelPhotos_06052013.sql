CREATE TABLE lu_HotelPhotos
(
imageID INT IDENTITY PRIMARY KEY,
propertyID int NOT NULL,
caption varchar(100),
height int,
width int,
imageType varchar(20),
imageURL varchar(255),
sizeCode varchar(1)
)