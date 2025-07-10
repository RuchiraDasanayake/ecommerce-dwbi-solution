select * from [dbo].[fact_Order]
order by OrderDeliveredCustomerDateKey, OrderEstimatedDeliveryDateKey, OrderApprovedDateKey, OrderPurchaseDateKey
select * from [dbo].[dim_Seller]
DECLARE @Date DATE = '2016-01-01';  -- Start date
DECLARE @EndDate DATE = '2020-12-31';  -- End date

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
select * from dim_Date
delete from dim_Product
delete from fact_Order

-- Remove foreignkey constraints -- 
ALTER TABLE fact_Order
DROP CONSTRAINT FK_fact_Order_PurchaseDate;

ALTER TABLE fact_Order
DROP CONSTRAINT FK_fact_Order_ApprovedDate;

ALTER TABLE fact_Order
DROP CONSTRAINT FK_fact_Order_DeliveredDate;

ALTER TABLE fact_Order
DROP CONSTRAINT FK_fact_Order_EstimatedDate;

-- Add foreign keys --
ALTER TABLE fact_Order
ADD CONSTRAINT FK_fact_Order_PurchaseDate FOREIGN KEY (OrderPurchaseDateKey) REFERENCES dim_Date(DateKey);

ALTER TABLE fact_Order
ADD CONSTRAINT FK_fact_Order_ApprovedDate FOREIGN KEY (OrderApprovedDateKey) REFERENCES dim_Date(DateKey);

ALTER TABLE fact_Order
ADD CONSTRAINT FK_fact_Order_DeliveredDate FOREIGN KEY (OrderDeliveredCustomerDateKey) REFERENCES dim_Date(DateKey);

ALTER TABLE fact_Order
ADD CONSTRAINT FK_fact_Order_EstimatedDate FOREIGN KEY (OrderEstimatedDeliveryDateKey) REFERENCES dim_Date(DateKey);

