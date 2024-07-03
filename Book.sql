USE BOOKSTORE
CREATE TABLE BOOKS(
BOOKID INT PRIMARY KEY IDENTITY(1,1),
TITLE VARCHAR(100),
AUTHOR VARCHAR(100),
RATING FLOAT,
RATINGCOUNT INT,
PRICE DECIMAL,
ORIGINALPRICE DECIMAL(6,2),
DISCOUNTPERCENTAGE FLOAT,
DESCRIPTION VARCHAR(MAX),
IMAGE VARCHAR(MAX),
QUANTITY INT);



CREATE OR ALTER PROCEDURE ADDBOOK(
    @TITLE VARCHAR(40),
    @AUTHOR VARCHAR(40),
	@ORIGINALPRICE DECIMAL(6,2),
	@DISCOUNTPERCENTAGE FLOAT,
    @DESCRIPTION VARCHAR(MAX),
    @IMAGE VARCHAR(MAX),
    @QUANTITY INT
)
AS
BEGIN
    BEGIN TRY
        DECLARE @BOOKID INT;

        INSERT INTO Books (TITLE, AUTHOR, ORIGINALPRICE, DISCOUNTPERCENTAGE, DESCRIPTION, IMAGE, QUANTITY)
        VALUES (@TITLE, @AUTHOR, @ORIGINALPRICE, @DISCOUNTPERCENTAGE, @DESCRIPTION, @IMAGE, @QUANTITY);


        SET @BOOKID = SCOPE_IDENTITY();


        UPDATE Books
        SET PRICE = ORIGINALPRICE - ORIGINALPRICE * (@DISCOUNTPERCENTAGE / 100) -- Assuming a discount percentage for all books initially
        WHERE BOOKID = @BOOKID;

        PRINT 'Book added successfully.';
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR('Error Occurred: %s', @ErrorSeverity, @ErrorState, @ErrorMessage);
    END CATCH;
END;


EXEC ADDBOOK @TITLE='Autobiography of A Yogi ', @AUTHOR='Paramahansa', @ORIGINALPRICE=2000,@DISCOUNTPERCENTAGE=25, @DESCRIPTION='Inspiring stalwarts like the Beatles, Steve Jobs and Ravi Shankar, Autobiography of a Yogi is an immensely gratifying spiritual read that has altered and enriched the lives of millions across the world', @IMAGE='IMG', @QUANTITY=50;

SELECT * FROM USERS;
SELECT * FROM BOOKS;
SELECT * FROM FEEDBACK;
SELECT * FROM CART;


CREATE OR ALTER PROCEDURE UpdateBook
    @BOOKID INT,
    @TITLE VARCHAR(40),
    @AUTHOR VARCHAR(40),
   
    @ORIGINALPRICE DECIMAL(6,2),
    @DISCOUNTPERCENTAGE FLOAT,
    @DESCRIPTION VARCHAR(MAX),
    @IMAGE VARCHAR(MAX),
    @QUANTITY INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM BOOKS WHERE BOOKID = @BOOKID)
        BEGIN
            DECLARE @PRICE DECIMAL(10,2);


            SET @PRICE = @ORIGINALPRICE * (1 - @DISCOUNTPERCENTAGE / 100);

            UPDATE BOOKS
            SET
                TITLE = @TITLE,
                AUTHOR = @AUTHOR,
                
                PRICE = @PRICE,
                ORIGINALPRICE = @ORIGINALPRICE,
                DISCOUNTPERCENTAGE = @DISCOUNTPERCENTAGE,
                DESCRIPTION = @DESCRIPTION,
                IMAGE = @IMAGE,
                QUANTITY = @QUANTITY
            WHERE BOOKID = @BOOKID;

            PRINT 'Book updated successfully.';
        END
        ELSE
        BEGIN
            PRINT 'Book not found.';
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

        PRINT 'Error Occurred: ' + @ErrorMessage;
    END CATCH;
END;
EXEC UpdateBook  @BOOKID=2,
@TITLE='Autobiography of A Yogi',
                @AUTHOR ='RAM',  
                @ORIGINALPRICE=2500,
                @DISCOUNTPERCENTAGE=25,
                @DESCRIPTION='BOOK',
                 @IMAGE='img',
                 @QUANTITY=25;
            

	CREATE OR ALTER PROCEDURE DeleteBook
    @BOOKID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF EXISTS (SELECT 1 FROM BOOKS WHERE BOOKID = @BOOKID)
        BEGIN

            DELETE FROM BOOKS WHERE BOOKID = @BOOKID;
            PRINT 'Book deleted successfully.';
        END
        ELSE
        BEGIN
            PRINT 'Book not found.';
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

        PRINT 'Error Occurred: ' + @ErrorMessage;
    END CATCH;
END;
EXEC DeleteBook @BOOKID=2;

CREATE OR ALTER PROCEDURE GetAllBooks
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        SELECT * FROM BOOKS;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR(@ErrorSeverity, @ErrorState, @ErrorMessage);
    END CATCH;
END;


CREATE OR ALTER PROCEDURE GetBookByID
    @BOOKID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @BookExists BIT;


        SELECT @BookExists = CASE WHEN EXISTS (SELECT 1 FROM BOOKS WHERE BOOKID = @BOOKID) THEN 1 ELSE 0 END;

        IF @BookExists = 1
        BEGIN

            SELECT *
            FROM BOOKS
            WHERE BOOKID = @BOOKID;
        END
        ELSE
        BEGIN
            RAISERROR('Book not found.', 16, 1);
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

        RAISERROR( @ErrorSeverity, @ErrorState, @ErrorMessage);
    END CATCH;
END;


CREATE OR ALTER PROCEDURE GetBookByName
    @TITLE VARCHAR(100),
    @AUTHOR VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @BookID INT;


        SELECT @BookID = BOOKID
        FROM BOOKS
        WHERE TITLE = @TITLE AND AUTHOR = @AUTHOR;

        IF @BookID IS NOT NULL
        BEGIN

            SELECT *
            FROM BOOKS
            WHERE TITLE = @TITLE AND AUTHOR = @AUTHOR;
        END
        ELSE
        BEGIN

            RAISERROR('Book not found.', 16, 1);
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

        RAISERROR( @ErrorSeverity, @ErrorState, @ErrorMessage);
    END CATCH;
END;
