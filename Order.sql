USE BOOKSTORE
create table Orders(
OrderId INT PRIMARY KEY IDENTITY(1,1),
 UserId INT FOREIGN kEY REFERENCES Users(UserId),
 BookId INT FOREIGN KEY REFERENCES Books(BookId),
 Title VARCHAR(40),
 Author VARCHAR(40),
 Image VARCHAR(MAX),
 Quantity INT,
 TotalPrice DECIMAL(10,2),
 TotalOriginalPrice DECIMAL(10, 2),
 OrderDate DATETIME DEFAULT GETDATE()
);

create or alter procedure AddOrder
@CartId int
as
begin
    declare @UserId int, 
			@BookId int, 
			@Title varchar(50),
			@Author varchar(50),
			@Image varchar(max),
			@Quantity int, 
			@TotalPrice decimal(10, 2), 
			@TotalOriginalPrice decimal(10, 2)
	

    select @UserId = c.UserId, 
           @BookId = c.BookId, 
		   @Title = b.Title,
		   @Author = b.Author,
		   @Image = b.Image,
           @Quantity = c.Quantity, 
           @TotalPrice = c.TotalPrice, 
           @TotalOriginalPrice = c.TotalOriginalPrice
    from Cart c, Books b
    where c.BookId = b.BookId and
		  CartId = @CartId


    if exists (select 1 from Books where BookId = @BookId and Quantity >= @Quantity)
	begin

		 if  exists (select 1 from Cart where BookId = @BookId)
			begin

				insert into Orders (UserId, BookId, Title, Author, Image, Quantity, TotalPrice, TotalOriginalPrice)
				values (@UserId, @BookId, @Title, @Author, @Image, @Quantity, @TotalPrice, @TotalOriginalPrice);

				update Books
				set Quantity = Quantity - @Quantity
				where BookId = @BookId;

				delete from Cart
				where CartId = @CartId;
			end
		else
		begin
			        RAISERROR ('The book is out of stock.', 16, 1);

		end
	end
	else
    begin
			RAISERROR ('The book is not available in the cart..', 16, 1);
    end
end
CREATE OR ALTER PROCEDURE GetOrdersId(
    @UserId INT
)
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Orders WHERE UserId = @UserId)
        BEGIN

            SELECT * FROM Orders WHERE UserId = @UserId ;
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

CREATE OR ALTER PROCEDURE GetAllOrderss
AS
BEGIN
BEGIN TRY
IF EXISTS (SELECT 1 FROM Orders)
BEGIN
SELECT * FROM Orders
 END
        ELSE
        BEGIN
            PRINT 'NO Orders FOUND'
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


CREATE OR ALTER PROCEDURE CancelOrderAndRestore
@OrderId int
AS
BEGIN
    DECLARE @BookId int, 
            @Quantity int;

    SELECT @BookId = BookId, @Quantity = Quantity
    FROM Orders
    WHERE OrderId = @OrderId;

    IF EXISTS (SELECT 1 FROM Orders WHERE OrderId = @OrderId)
    BEGIN

        DELETE FROM Orders WHERE OrderId = @OrderId;

        UPDATE Books
        SET Quantity = Quantity + @Quantity
        WHERE BookId = @BookId;
        PRINT 'Order deleted  and book restored to cart.';
    END
    ELSE
    BEGIN
        RAISERROR ('Order not found.', 16, 1);
    END
END
