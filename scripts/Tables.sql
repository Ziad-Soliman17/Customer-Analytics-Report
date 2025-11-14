USE AdventureWorksDW2019
GO

-- Sales Fact table--
Select 
	i.SalesOrderNumber,
	COALESCE(r.SalesReasonKey,10) AS SalesReasonKey,
	i.ProductKey,
	i.CustomerKey,
	i.OrderDateKey,
	i.SalesAmount,
	i.OrderDate
FROM FactInternetSales i 
LEFT JOIN  FactInternetSalesReason r  ON r.SalesOrderNumber = i.SalesOrderNumber
WHERE OrderDate IS NOT NULL 
	AND YEAR(OrderDate) BETWEEN 2022 AND 2024;


-- Date Dimension Table--
SELECT 
	DateKey,
	FullDateAlternateKey AS Date,
	CalendarYear,
	LEFT(EnglishMonthName,3) AS Month_Abbrv,
	MonthNumberOfYear AS Month_NR
FROM DimDate 
WHERE YEAR(FullDateAlternateKey) BETWEEN 2022 AND 2024;


-- Customer Dimesnion Table--
SELECT
	c.CustomerKey,
	CONCAT (c.FirstName,' ',c.LastName) AS CustomerName,
	BirthDate, 
	DATEDIFF(YEAR,c.BirthDate,GETDATE()) AS Age,
	CASE 
		WHEN c.Gender = 'M' THEN 'Male'	
		WHEN c.Gender = 'F' THEN 'Female'
		ELSE 'Not Specified'
	END AS Gender,  
	g.City,
	g.StateProvinceName AS State,
	g.EnglishCountryRegionName AS Country  
From DimCustomer c
LEFT JOIN DimGeography g ON c.GeographyKey = g.GeographyKey;


--Product Dimension Table--
SELECT
	p.ProductKey,
	p.EnglishProductName AS ProductName,
	COALESCE(s.EnglishProductSubcategoryName, 'Others') AS Subcategory,
	COALESCE(c.EnglishProductCategoryName, 'Others') AS Catgeory
FROM DimProduct p
LEFT JOIN DimProductSubcategory s ON p.ProductSubcategoryKey = s.ProductSubcategoryKey
LEFT JOIN DimProductCategory c ON s.ProductCategoryKey = c.ProductCategoryKey;
 

 --SalesReason Dimension Table--
 SELECT 
	 SalesReasonKey,
	 SalesReasonName,
	 SalesReasonReasonType
 FROM DimSalesReason;

