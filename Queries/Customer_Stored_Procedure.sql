CREATE PROCEDURE dbo.UpdateDimCustomer
    @CustomerID VARCHAR(100),
    @CustomerUniqueID VARCHAR(100),
    @CustomerZipCode VARCHAR(10),
    @CustomerCity VARCHAR(100),
    @CustomerState VARCHAR(2)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @CurrentCustomerKey INT,
        @HasChanged BIT = 0;

    -- Get current customer record
    SELECT TOP 1 
        @CurrentCustomerKey = customer_key,
        @HasChanged = CASE 
            WHEN customer_unique_id <> @CustomerUniqueID OR
                 customer_zip_code  <> @CustomerZipCode OR
                 customer_city      <> @CustomerCity OR
                 customer_state     <> @CustomerState
            THEN 1 ELSE 0 
        END
    FROM Dim_Customer
    WHERE customer_id = @CustomerID AND is_current = 1;

    -- Insert if new
    IF @CurrentCustomerKey IS NULL
    BEGIN
        INSERT INTO Dim_Customer (
            customer_id, customer_unique_id, customer_zip_code,
            customer_city, customer_state,
            effective_date, expiration_date, is_current
        )
        VALUES (
            @CustomerID, @CustomerUniqueID, @CustomerZipCode,
            @CustomerCity, @CustomerState,
            GETDATE(), '9999-12-31', 1
        );
    END
    ELSE IF @HasChanged = 1
    BEGIN
        -- Expire current row
        UPDATE Dim_Customer
        SET expiration_date = GETDATE(),
            is_current = 0
        WHERE customer_key = @CurrentCustomerKey;

        -- Insert new current row
        INSERT INTO Dim_Customer (
            customer_id, customer_unique_id, customer_zip_code,
            customer_city, customer_state,
            effective_date, expiration_date, is_current
        )
        VALUES (
            @CustomerID, @CustomerUniqueID, @CustomerZipCode,
            @CustomerCity, @CustomerState,
            GETDATE(), '9999-12-31', 1
        );
    END
END;
