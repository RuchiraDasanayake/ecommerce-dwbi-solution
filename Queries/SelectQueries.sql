SELECT * FROM [BrazilianECommerce_DW].[dbo].fact_Order  -- Replace YourTable with a valid table name
DBCC CHECKDB('BrazilianECommerce_DW')
SELECT * FROM Dim_Date WHERE Day IS NULL;

SELECT * 
FROM fact_Order
order by OrderApprovedDateKey

DELETE FROM fact_Order
WHERE OrderApprovedDateKey = '17530101';

SELECT * 
FROM fact_Order
WHERE OrderApprovedDateKey NOT IN (SELECT DateKey FROM Dim_Date);
