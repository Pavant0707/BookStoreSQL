USE BOOKSTORE
CREATE TABLE Wishlist (
 WishlistId INT PRIMARY KEY IDENTITY(1,1),
 UserId INT FOREIGN kEY REFERENCES Users(UserId),
 BookId INT FOREIGN KEY REFERENCES Books(BookId),
 Title VARCHAR(40),
 Author VARCHAR(40),
 Image VARCHAR(MAX),
 Price DECIMAL(10,2),
 OriginalPrice DECIMAL(10, 2),
);

CREATE OR ALTER PROCEDURE AddWishlist
@UserId INT,
@BookId INT
AS
BEGIN
    DECLARE @Title VARCHAR(40),
            @Author VARCHAR(40),
            @Image VARCHAR(MAX),
            @Price DECIMAL(10,2),
            @OriginalPrice DECIMAL(10, 2);
    
    SELECT @Title = Title,
           @Author = Author,
           @Image = Image,
           @Price = Price,
           @OriginalPrice = OriginalPrice
    FROM Books
    WHERE BookId = @BookId;
    
    IF @@ROWCOUNT > 0
    BEGIN
        INSERT INTO Wishlist (UserId, BookId, Title, Author, Image, Price, OriginalPrice)
        VALUES (@UserId, @BookId, @Title, @Author, @Image, @Price, @OriginalPrice);
        
        PRINT 'Book added to wishlist successfully.';
    END
    ELSE
    BEGIN
        RAISERROR ('Book not found.', 16, 1);
    END 
END

CREATE OR ALTER PROCEDURE GETALL (
    @UserId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT * FROM Wishlist WHERE @UserId = UserId;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        IF @ErrorSeverity >= 16
        BEGIN
            PRINT 'A severe error occurred: ' + @ErrorMessage;
        END
        ELSE
        BEGIN
            THROW 51000, @ErrorMessage, 1;
        END
    END CATCH
END;


CREATE OR ALTER PROCEDURE DELETEBYID (
    @WishlistId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DELETE FROM Wishlist WHERE WishlistId = @WishlistId;
        IF @@ROWCOUNT = 0
        BEGIN
            THROW 51000, 'No rows deleted', 1;
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

        IF @ErrorSeverity >= 16
        BEGIN
            PRINT 'A severe error occurred: ' + @ErrorMessage;
        END
        ELSE
        BEGIN
            THROW 50001, @ErrorMessage, 1;
        END
    END CATCH
END;
