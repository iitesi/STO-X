USE Corporate_Production

ALTER TABLE Account_Policies
ADD Policy_FindItChangeAir INT DEFAULT(1)

UPDATE Account_Policies
SET Policy_FindItChangeAir = 1