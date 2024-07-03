USE BOOKSTORE
CREATE TABLE FEEDBACK(
FEEDBACKID INT PRIMARY KEY IDENTITY(1,1),
BOOKID INT FOREIGN KEY REFERENCES BOOKS(BOOKID),
USERID INT FOREIGN KEY REFERENCES USERS(USERID),
FULLNAME VARCHAR(50),
RATING INT,
REVIEW VARCHAR(MAX));

CREATE OR ALTER PROCEDURE AddFeedback (
    @BOOKID INT,
    @USERID INT,
    @RATING FLOAT,
    @REVIEW VARCHAR(MAX)
)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        DECLARE @FULLNAME VARCHAR(50);
        SELECT @FULLNAME = FULLNAME FROM Users WHERE USERID = @USERID;
        INSERT INTO FEEDBACK (USERID, BOOKID, FULLNAME, RATING, REVIEW)
        VALUES (@USERID, @BOOKID, @FULLNAME, @RATING, @REVIEW);

        UPDATE Books
        SET RATING = (SELECT AVG(RATING) FROM FEEDBACK WHERE BOOKID = @BOOKID),
            RatingCount = (SELECT COUNT(*) FROM FEEDBACK WHERE BOOKID = @BOOKID)
        WHERE BOOKID = @BOOKID;
        
        PRINT 'FEEDBACK ADDED SUCCESSFULLY';
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR('Error: %s', @ErrorSeverity, @ErrorState, @ErrorMessage);
    END CATCH
END;


exec AddFeedback @USERID=2, @BOOKID=1, @RATING=3, @REVIEW='Excellent';

CREATE OR ALTER PROCEDURE UpdateFeedback
    @FEEDBACKID INT,
    @BOOKID INT,
    @USERID INT,
    @FULLNAME VARCHAR(50),
    @RATING INT,
    @REVIEW VARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM FEEDBACK WHERE FEEDBACKID = @FEEDBACKID)
        BEGIN
            UPDATE FEEDBACK
            SET BOOKID = @BOOKID,
                USERID = @USERID,
                FULLNAME = @FULLNAME,
                RATING = @RATING,
                REVIEW = @REVIEW
            WHERE FEEDBACKID = @FEEDBACKID;

            PRINT 'Feedback updated successfully.';
        END
        ELSE
        BEGIN
            RAISERROR('Feedback ID not found.', 16, 1);
        END
    END TRY
    BEGIN CATCH

        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();
        PRINT 'ERROR: ' + @ErrorMessage;
        THROW;
    END CATCH
END;

CREATE OR ALTER PROCEDURE DeleteFeedback
   @FEEDBACKID INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM FEEDBACK WHERE FEEDBACKID = @FEEDBACKID)
        BEGIN
            DELETE FROM FEEDBACK WHERE FEEDBACKID = @FEEDBACKID;

            PRINT 'Feedback deleted successfully.';
        END
        ELSE
        BEGIN
            THROW 50000, 'FeedbackId does not exist.', 1;
        END 
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();
        THROW @ErrorSeverity, @ErrorMessage, @ErrorState;
    END CATCH
END;

CREATE OR ALTER PROCEDURE GetAllFeedbacks
AS
BEGIN
BEGIN TRY
IF EXISTS (SELECT 1 FROM FEEDBACK)
BEGIN
SELECT * FROM USERS
 END
        ELSE
        BEGIN
            PRINT 'NO FEEDBACK FOUND'
        END
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT @ErrorMessage = ERROR_MESSAGE(), 
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();

        PRINT 'Error: ' + @ErrorMessage;
    END CATCH
END


EXEC GetAllFeedbacks;

CREATE OR ALTER PROCEDURE GetFeedbacksByBookId
    @BOOkId INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Books WHERE BookId = @BookId)
        BEGIN
            SELECT * FROM FEEDBACK WHERE BOOKID = @BOOkId;
        END
        ELSE
        BEGIN
            THROW 50000, 'BookId does not exist.', 1;
        END
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        THROW @ErrorSeverity, @ErrorMessage, @ErrorState;
    END CATCH
END;
