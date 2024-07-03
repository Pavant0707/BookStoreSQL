USE BOOKSTORE
CREATE TABLE CART(
 CartID INT PRIMARY KEY IDENTITY(1,1),
    USERID INT FOREIGN KEY (USERID) REFERENCES USERS(USERID),
    BOOKID INT FOREIGN KEY (BOOKID) REFERENCES BOOKS(BOOKID),
    Quantity INT,
	TotalPrice DECIMAL(10,2),
    TOTALORIGINALPRICE DECIMAL(6,2))
 

	CREATE OR ALTER PROCEDURE AddBookToCart
    @USERID INT,
    @BOOKID INT,
    @Quantity INT
AS
BEGIN
    BEGIN TRY
        DECLARE @CartID INT;
        DECLARE @ExistingQuantity INT;
        DECLARE @PRICE DECIMAL(6, 2);
        DECLARE @ORIGINALPRICE DECIMAL(6, 2);
        SELECT @PRICE = PRICE, @ORIGINALPRICE = ORIGINALPRICE
        FROM BOOKS
        WHERE BOOKID = @BOOKID;

        SELECT @CartID = CartID, @ExistingQuantity = Quantity
        FROM CART
        WHERE USERID = @USERID AND BOOKID = @BOOKID;

        IF @CartID IS NOT NULL
        BEGIN

            UPDATE CART
            SET Quantity = @ExistingQuantity + @Quantity,
                TotalPrice = (@ExistingQuantity + @Quantity) * @PRICE,
                TotalOriginalPrice = (@ExistingQuantity + @Quantity) * @ORIGINALPRICE
            WHERE CartID = @CartID;
        END
        ELSE
        BEGIN

            INSERT INTO CART (USERID, BOOKID, Quantity, TotalPrice, TotalOriginalPrice)
            VALUES (@USERID, @BOOKID, @Quantity, @Quantity * @Price, @Quantity * @ORIGINALPRICE);
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


        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;


EXEC AddBookToCart @USERID=2,
    @BOOKID=1,
    @Quantity=1;
	SELECT * FROM CART


	CREATE OR ALTER PROCEDURE GetCartItem
    @USERID INT
AS
BEGIN
    BEGIN TRY
        SELECT c.CartID,c.USERID,c.BOOKID,b.TITLE,b.IMAGE, b.AUTHOR,
               c.TotalPrice,
               c.TOTALORIGINALPRICE,
			   c.Quantity
        FROM Cart c
        JOIN BOOKS b ON c.BOOKID = b.BOOKId
        WHERE c.USERID = @USERID;
    END TRY
    BEGIN CATCH

        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();


        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;

EXEC GetCartItems @USERID=2;

CREATE OR ALTER PROCEDURE DELETEBYID
(
    @CartID INT
)
AS
BEGIN
    BEGIN TRY
        IF @CartID IS NULL
        BEGIN
            RAISERROR('CartID IS REQUIRED', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM CART WHERE CartID = @CartID)
        BEGIN
            DELETE FROM CART WHERE CartID = @CartID;
            PRINT 'Record deleted successfully';
        END
        ELSE
        BEGIN
            RAISERROR('No record found for the given STUDENTID', 16, 1);
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

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;

CREATE OR ALTER PROCEDURE UpdateCart
    @CartID INT,
    @Quantity INT
AS
BEGIN
    BEGIN TRY
        DECLARE @BOOKID INT;
        DECLARE @PRICE DECIMAL(10,2);
        DECLARE @ORIGINALPRICE DECIMAL(6,2);

        SELECT @BOOKID = BOOKID
        FROM CART
        WHERE CartID = @CartID;

        IF @BOOKID IS NULL
        BEGIN
            RAISERROR('Cart item not found.', 16, 1);
            RETURN;
        END


        SELECT @PRICE = PRICE, @ORIGINALPRICE = ORIGINALPRICE
        FROM BOOKS
        WHERE BOOKID = @BOOKID;

        IF @PRICE IS NULL OR @ORIGINALPRICE IS NULL
        BEGIN
            RAISERROR('Book not found.', 16, 1);
            RETURN;
        END


        UPDATE CART
        SET Quantity = @Quantity,
            TotalPrice = @Quantity * @PRICE,
            TOTALORIGINALPRICE = @Quantity * @ORIGINALPRICE
        WHERE CartID = @CartID;
    END TRY
    BEGIN CATCH

        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;

exec UpdateCart @CartID=1,
@Quantity=2;


CREATE OR ALTER PROCEDURE GetBooks
    @USERID INT
AS
BEGIN
    BEGIN TRY
        SELECT c.CartID, c.USERID, c.BOOKID, b.TITLE, b.IMAGE, b.AUTHOR, 
               u.PHONENUMBER, u.FULLNAME,
               c.TotalPrice,
               c.TOTALORIGINALPRICE,
               c.Quantity
        FROM Users u
        JOIN Cart c ON u.UserId = c.UserId
        JOIN Books b ON c.BookId = b.BookId
        WHERE c.USERID = @USERID;
    END TRY
    BEGIN CATCH

        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;

SELECT * FROM USERS;
SELECT * FROM BOOKS;
SELECT * FROM FEEDBACK;
SELECT * FROM CART;