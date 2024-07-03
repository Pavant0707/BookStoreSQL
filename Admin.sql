use BOOKSTORE
CREATE TABLE Admin(
AdminId int PRIMARY KEY IDENTITY(1,1), 
FullName VARCHAR(50),
EmailId VARCHAR(50),
Password VARCHAR(20),
MobileNumber VARCHAR(15))
CREATE OR ALTER PROCEDURE AddAdmin (
    @FullName VARCHAR(50),
    @EmailId VARCHAR(50),
    @Password VARCHAR(20),
    @MobileNumber VARCHAR(15)
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @FullName IS NULL OR @EmailId IS NULL OR @Password IS NULL OR @MobileNumber IS NULL
    BEGIN
        
        THROW 51000, 'All parameters are required', 1;
        RETURN;
    END;

    BEGIN TRY
        
        IF EXISTS (SELECT 1 FROM Admin WHERE EmailId = @EmailId)
        BEGIN
            
            THROW 51001, 'Email ID already exists', 1;
            RETURN;
        END;

        IF LEN(@Password) < 6
        BEGIN
            
            THROW 51002, 'Password must be at least 6 characters', 1;
            RETURN;
        END;

        IF LEN(@MobileNumber) <> 10
        BEGIN
           
            THROW 51003, 'Mobile number must be exactly 10 digits', 1;
            RETURN;
        END;

       
        INSERT INTO Admin (FullName, EmailId, Password, MobileNumber)
        VALUES (@FullName, @EmailId, @Password, @MobileNumber);

        
        IF @@ROWCOUNT = 1
        BEGIN
            PRINT 'Admin REGISTERED SUCCESSFULLY';
        END
        ELSE
        BEGIN
            
            THROW 51004, 'Admin registration failed', 1;
            RETURN;
        END;
    END TRY
    BEGIN CATCH
        
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        
        PRINT 'Error occurred: ' + @ErrorMessage;
    END CATCH
END;


CREATE OR ALTER PROCEDURE Login(
    @EmailId VARCHAR(50),
    @Password VARCHAR(20)
)
AS
BEGIN 
    BEGIN TRY
        IF EXISTS(SELECT 1 FROM Admin WHERE EmailId = @EmailId AND Password = @Password)
        BEGIN
            SELECT * FROM Admin WHERE EmailId = @EmailId AND Password = @Password;
            PRINT 'Admin LOGIN SUCCESSFULL';
        END
        ELSE
        BEGIN
            THROW 50001, 'LOGIN DETAILS ARE INCORRECT', 1;
        END
    END TRY
    BEGIN CATCH
        -- Error handling
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT @ErrorMessage = ERROR_MESSAGE(), 
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();

        THROW @ErrorSeverity, @ErrorMessage, @ErrorState;
    END CATCH
END;


