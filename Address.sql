CREATE TABLE ADDRESS(
AddressId INT PRIMARY KEY IDENTITY(1,1),
USERID INT FOREIGN KEY REFERENCES USERS(USERID),
FullName VARCHAR(50),
Mobile VARCHAR(15),
Address VARCHAR(MAX),
City VARCHAR(50),
State VARCHAR(50),
Type VARCHAR(15));





CREATE OR ALTER PROCEDURE AddAddress
    @USERID INT,
    @FullName VARCHAR(100),
    @Mobile VARCHAR(50),
    @Address VARCHAR(MAX),
    @City VARCHAR(100),
    @State VARCHAR(100),
    @Type VARCHAR(15)
AS
BEGIN
    BEGIN TRY
        INSERT INTO ADDRESS (USERID, FullName, Mobile, Address, City, State, Type)
        VALUES (@USERID, @FullName, @Mobile, @Address, @City, @State, @Type);
    END TRY
    BEGIN CATCH

        DECLARE @ErrorNumber INT = ERROR_NUMBER();
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();

        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(200) = ERROR_PROCEDURE();
        

        RAISERROR (
            @ErrorProcedure,
            @ErrorLine,
            @ErrorNumber,
            @ErrorMessage
        );
    END CATCH
END;

CREATE OR ALTER PROCEDURE GetByUserId
    @USERId INT
AS
BEGIN
    BEGIN TRY

        IF @USERID IS NULL OR @USERID <= 0
        BEGIN
            RAISERROR('Invalid userId: %d. userId must be a positive integer.', 16, 1, @userId);
            RETURN;
        END
        

        SELECT * FROM ADDRESS
        WHERE USERID = @USERID;
    END TRY
    BEGIN CATCH

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Error occurred: %s', 16, 1, @ErrorMessage);
    END CATCH
END;




select * from address;


CREATE OR ALTER PROCEDURE GetById
    @AddressId INT
AS
BEGIN
    BEGIN TRY

        IF @AddressId IS NULL OR @AddressId <= 0
        BEGIN
            RAISERROR('Invalid AddressId: %d. AddressId must be a positive integer.', 16, 1, @AddressId);
            RETURN;
        END
        

        SELECT * FROM ADDRESS
        WHERE AddressId = @AddressId;
    END TRY
    BEGIN CATCH

        DECLARE @ErrorNumber INT = ERROR_NUMBER();
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(200) = ERROR_PROCEDURE();
        

        RAISERROR (
            'Error occurred in procedure %s at line %d. Error %d: %s',
            @ErrorProcedure,
            @ErrorLine,
            @ErrorNumber,
            @ErrorMessage
        );
    END CATCH
END;


CREATE OR ALTER PROCEDURE UpdateById
    @USERID INT,
    @AddressId INT,
    @FullName VARCHAR(50),
    @Mobile VARCHAR(15),
    @Address VARCHAR(MAX),
    @City VARCHAR(50),
    @State VARCHAR(50),
    @Type VARCHAR(15)
AS
BEGIN
    BEGIN TRY
        UPDATE ADDRESS
        SET FullName = @FullName,
            Mobile = @Mobile,
            Address = @Address,
            City = @City,
            State = @State,
            Type = @Type
        WHERE AddressId = @AddressId AND USERID = @USERID;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;





CREATE OR ALTER PROCEDURE DeleteId
    @USERID INT,
    @AddressId INT
AS
BEGIN
    BEGIN TRY
        DELETE FROM ADDRESS
        WHERE AddressId = @AddressId AND USERID = @USERID;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;