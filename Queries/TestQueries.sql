SELECT * from fact_Order
FROM fact_Order
WHERE ProductKey IS NULL OR SellerKey IS NULL OR CustomerKey IS NULL OR OrderKey IS NULL OR Prod;

delete from dim_Product

SELECT * FROM dim_Product
WHERE ProductCategoryName IS NULL

ALTER TABLE fact_Order
DROP COLUMN Quantity;

SELECT 
    OrderID, 
    OrderDeliveredCustomerDateKey
FROM fact_Order
WHERE OrderDeliveredCustomerDateKey NOT IN (SELECT DateKey FROM dim_Date)
AND OrderDeliveredCustomerDateKey IS NOT NULL;

-- Add the specific missing date (1753-01-01) to dim_Date
IF NOT EXISTS (SELECT 1 FROM dim_Date WHERE DateKey = 17530101)
BEGIN
    INSERT INTO dim_Date (
        DateKey,
        FullDate,
        Day,
        Month,
        Year,
        Quarter,
        DayName,
        MonthName,
        IsWeekend
    )
    VALUES (
        17530101,  -- DateKey as YYYYMMDD
        '1753-01-01',  -- FullDate
        1,  -- Day
        1,  -- Month
        1753,  -- Year
        1,  -- Quarter
        DATENAME(WEEKDAY, '1753-01-01'),  -- DayName
        'January',  -- MonthName
        CASE WHEN DATENAME(WEEKDAY, '1753-01-01') IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END  -- IsWeekend
    );
    
    PRINT 'Date 1753-01-01 added successfully.';
END
ELSE
BEGIN
    PRINT 'Date 1753-01-01 already exists in dim_Date.';
END

CREATE TABLE fact_Order (
    OrderKey INT IDENTITY(1,1) PRIMARY KEY,
    OrderID VARCHAR(50) NOT NULL,  -- Business key
    CustomerKey INT NOT NULL,
    SellerKey INT NOT NULL,
    ProductKey INT NOT NULL,
    OrderStatus VARCHAR(20),
    OrderPurchaseDateKey INT, -- FK to dim_Date
    OrderApprovedDateKey INT, -- FK to dim_Date
    OrderDeliveredCustomerDateKey INT, -- FK to dim_Date
    OrderEstimatedDeliveryDateKey INT, -- FK to dim_Date
    PaymentType VARCHAR(50),
    PaymentInstallments INT,
    PaymentValue DECIMAL(10,2),
    FreightValue DECIMAL(10,2),
    ProductPrice DECIMAL(10,2),
    Quantity INT,

    -- Foreign Key Constraints
    CONSTRAINT FK_fact_Order_Customer FOREIGN KEY (CustomerKey) REFERENCES dim_Customer(CustomerKey),
    CONSTRAINT FK_fact_Order_Seller FOREIGN KEY (SellerKey) REFERENCES dim_Seller(SellerKey),
    CONSTRAINT FK_fact_Order_Product FOREIGN KEY (ProductKey) REFERENCES dim_Product(ProductKey),
    CONSTRAINT FK_fact_Order_OrderPurchaseDate FOREIGN KEY (OrderPurchaseDateKey) REFERENCES dim_Date(DateKey),
    CONSTRAINT FK_fact_Order_OrderApprovedDate FOREIGN KEY (OrderApprovedDateKey) REFERENCES dim_Date(DateKey),
    CONSTRAINT FK_fact_Order_OrderDeliveredCustomerDate FOREIGN KEY (OrderDeliveredCustomerDateKey) REFERENCES dim_Date(DateKey),
    CONSTRAINT FK_fact_Order_OrderEstimatedDeliveryDate FOREIGN KEY (OrderEstimatedDeliveryDateKey) REFERENCES dim_Date(DateKey)
);

ALTER TABLE fact_Order
ADD 
    accm_txn_create_time DATETIME NOT NULL DEFAULT GETDATE(),
    accm_txn_complete_time DATETIME NULL,
    txn_process_time_hours INT NULL;

UPDATE fact_Order
SET txn_process_time_hours = DATEDIFF(HOUR, accm_txn_complete_time, accm_txn_create_time)
WHERE accm_txn_complete_time IS NOT NULL;