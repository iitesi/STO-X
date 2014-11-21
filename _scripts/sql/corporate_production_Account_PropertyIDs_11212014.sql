USE CORPORATE_PRODUCTION

ALTER TABLE Accounts_PropertyIDs ADD Property_IDvarchar VARCHAR(15)

UPDATE Accounts_PropertyIDs
SET Property_IDvarchar = Property_ID

EXEC sp_rename 'Accounts_PropertyIDs.Property_ID', 'Property_IDint', 'COLUMN';
EXEC sp_rename 'Accounts_PropertyIDs.Property_IDvarchar', 'Property_ID', 'COLUMN';
