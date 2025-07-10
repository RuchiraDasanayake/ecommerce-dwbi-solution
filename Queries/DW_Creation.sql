-- Customer Dimension (implementing as SCD Type 2)
CREATE TABLE dim_Customer (
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID VARCHAR(50) NOT NULL,  -- Business key from olist_customers_dataset
    CustomerUniqueID VARCHAR(50) NOT NULL,
    CustomerZipCodePrefix VARCHAR(10) NOT NULL,
    CustomerCity VARCHAR(100) NOT NULL,
    CustomerState VARCHAR(2) NOT NULL,
    EffectiveStartDate DATETIME NOT NULL,
    EffectiveEndDate DATETIME NULL,
    IsCurrent BIT NOT NULL,
    CONSTRAINT UQ_Customer_BusinessKey UNIQUE (CustomerID, EffectiveStartDate)
);

CREATE TABLE dim_Product (
    ProductKey INT IDENTITY(1,1) PRIMARY KEY,  -- Surrogate key
    ProductID VARCHAR(50) NOT NULL,  -- Business key
    ProductCategoryName VARCHAR(100),
    ProductNameLength INT,
    ProductDescriptionLength INT,
    ProductPhotosQty INT,
    ProductWeightGrams FLOAT,
    ProductLengthCM FLOAT,
    ProductHeightCM FLOAT,
    ProductWidthCM FLOAT
);


CREATE TABLE dim_Seller (
    SellerKey INT IDENTITY(1,1) PRIMARY KEY,
    SellerID VARCHAR(255) NOT NULL, -- Business key
    SellerZipCodePrefix VARCHAR(50),
    SellerCity VARCHAR(255),
    SellerState VARCHAR(50),
);

CREATE TABLE dim_Date (
    DateKey INT PRIMARY KEY, -- Format: YYYYMMDD
    FullDate DATE NOT NULL,
    Day INT NOT NULL,
    Month INT NOT NULL,
    Year INT NOT NULL,
    Quarter INT NOT NULL,
    DayName VARCHAR(10),
    MonthName VARCHAR(10),
    IsWeekend BIT
);

-- Insert data into dim_Date table for a range of years (e.g., 2020 to 2025)
DECLARE @Date DATE = '2016-01-01';  -- Start date
DECLARE @EndDate DATE = '2018-12-31';  -- End date

WHILE @Date <= @EndDate
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
        CONVERT(INT, CONVERT(VARCHAR(8), @Date, 112)),  -- DateKey as YYYYMMDD
        @Date,  -- FullDate
        DAY(@Date),  -- Day
        MONTH(@Date),  -- Month
        YEAR(@Date),  -- Year
        DATEPART(QUARTER, @Date),  -- Quarter
        DATENAME(WEEKDAY, @Date),  -- DayName (e.g., Monday, Tuesday)
        DATENAME(MONTH, @Date),  -- MonthName (e.g., January, February)
        CASE WHEN DATENAME(WEEKDAY, @Date) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END  -- IsWeekend
    );

    -- Increment the date by 1 day
    SET @Date = DATEADD(DAY, 1, @Date);
END;

-- Verify the data
SELECT * FROM dim_Date ORDER BY FullDate;

CREATE TABLE fact_Order (
    OrderKey INT IDENTITY(1,1) PRIMARY KEY,
    OrderID VARCHAR(50) NOT NULL,  -- Business key
    CustomerKey INT NOT NULL,
    SellerKey INT NOT NULL,
    ProductKey INT NOT NULL,
    OrderStatus VARCHAR(20),
    OrderPurchaseDateKey INT, 
    OrderApprovedDateKey INT, 
    OrderDeliveredCustomerDateKey INT, 
    OrderEstimatedDeliveryDateKey INT, 
    PaymentType VARCHAR(50),
    PaymentInstallments INT,
    PaymentValue DECIMAL(10,2),
    FreightValue DECIMAL(10,2),
    ProductPrice DECIMAL(10,2),

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

SELECT * FROM [dbo].[fact_Order]
SELECT 
    OrderID,
    accm_txn_create_time,
    accm_txn_complete_time,
    txn_process_time_hours
FROM fact_Order
WHERE accm_txn_complete_time IS NOT NULL
ORDER BY txn_process_time_hours DESC;
