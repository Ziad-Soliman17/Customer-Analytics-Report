# Customer Purchase Analytics Report 

A comprehensive Power BI analytics solution that transforms customer transaction data into actionable insights through RFM (Recency, Frequency, Monetary) segmentation and purchase behaviour analysis.

![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![DAX](https://img.shields.io/badge/DAX-blue?style=for-the-badge)

![Dashboard Preview](images/Customer%20Analytics-1.png)

![Dashboard Preview](images/Customer%20Analytics-2.png)

![Dashboard Preview](images/Customer%20Analytics-3.png)

-----

## Project Overview

This Project provides deep insights into customer purchasing patterns, segmentation, and retention metrics. The solution enables data-driven decision-making for marketing strategies, customer retention programs, and revenue optimization.

-----

## Data Extraction and Preparation with SQL

The following SQL queries were used to extract and prepare data from the AdventureWorks database for analysis in Power BI.

- Sales Fact Table 
  
```sql
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
```

- Date Dimension Table
  
```sql
SELECT 
	DateKey,
	FullDateAlternateKey AS Date,
	CalendarYear,
	LEFT(EnglishMonthName,3) AS Month_Abbrv,
	MonthNumberOfYear AS Month_NR
FROM DimDate 
WHERE YEAR(FullDateAlternateKey) BETWEEN 2022 AND 2024;
```


- Customer Dimension Table
  
```sql
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

```

- Product Dimension Table
  
```sql
SELECT
SELECT
	p.ProductKey,
	p.EnglishProductName AS ProductName,
	COALESCE(s.EnglishProductSubcategoryName, 'Others') AS Subcategory,
	COALESCE(c.EnglishProductCategoryName, 'Others') AS Catgeory
FROM DimProduct p
LEFT JOIN DimProductSubcategory s ON p.ProductSubcategoryKey = s.ProductSubcategoryKey
LEFT JOIN DimProductCategory c ON s.ProductCategoryKey = c.ProductCategoryKey;
```

 - SalesReason Dimension Table
  
```sql
 SELECT 
	 SalesReasonKey,
	 SalesReasonName,
	 SalesReasonReasonType
 FROM DimSalesReason;
```

-----

## Data Model

### Star Schema Design

The data model follows a star schema architecture for optimal query performance:

**Fact Tables:**

- `FactSales` - Transactional sales data

**Dimension Tables:**

- `DimCustomer` - Customer demographics and details
- `DimSalesReason` - Sales reasons and motivations
- `DimDate` - Date dimension for time-based analysis
- `DimProduct` - Product catalog and categories

### Relationships

- Sales[CustomerKey] → Customers[CustomerKey] (Many-to-One)
- Sales[ProductKey] → Products[ProductKey] (Many-to-One)
- Sales[OrderDateKey] → Date[DateKey] (Many-to-One)
- SalesReason[SalesReasonKey] → Sales[SalesReasonKey] (Many-to-One)

![Dashboard Preview](images/Data%20Model.jpeg)

-----

## DAX Measures

### Core Metrics

```dax
// Total Customers
Total Customers = DISTINCTCOUNT(Customers[CustomerKey])

// Total Spending
Total Spending = SUM(Sales[SalesAmount])

// Average Monthly Spending
Avg Monthly Spending = 
DIVIDE(
    [Total Spending],
    DISTINCTCOUNT(Customers[CustomerKey])
)

// Total Orders
Total Orders = DISTINCTCOUNT(Sales[SalesOrderNumber])

// Average Order Value (AOV)
Average Order Value = DIVIDE([Total Spending], [Total Orders])
```

### Advanced Calculations

```dax
// Retention Rate %
Retention Rate = 
VAR ReturningCustomers = 
    CALCULATE(
        DISTINCTCOUNT(Customers[CustomerID]),
        FILTER(Orders, Orders[IsReturning] = TRUE)
    )
VAR TotalCustomers = [Total Customers]
RETURN
DIVIDE(ReturningCustomers, TotalCustomers, 0)

// New vs Returning Classification
New Customers = 
CALCULATE(
    DISTINCTCOUNT(Customers[CustomerKey]),
    FILTER(
        Sales,
        COUNTROWS(
            FILTER(
                Sales,
                Sales[CustomerKey] = EARLIER(Sales[CustomerKey]) &&
                Sales[OrderDateKey] < EARLIER(Sales[OrderDateKey])
            )
        ) = 0
    )
)

Returning Customers = [Total Customers] - [New Customers]

// RFM Segment Count
Customers by Segment = 
CALCULATE(
    DISTINCTCOUNT(Customers[CustomerID]),
    ALLEXCEPT(RFM_Scores, RFM_Scores[RFM_Segment])
)

// Spending Trend (Time Intelligence)
Spending MoM Growth = 
VAR CurrentMonth = [Total Spendings]
VAR PreviousMonth = 
    CALCULATE(
        [Total Spendings],
        DATEADD(Date[Date], -1, MONTH)
    )
RETURN
DIVIDE(CurrentMonth - PreviousMonth, PreviousMonth)
```


-----

## 📈 Data Visualization

### Page 1: Purchase Analytics

![Dashboard Preview](images/Customer%20Analytics-1.png)

- **KPI Cards**: Total Customers (18K), Total Spendings ($70.9M), Avg Monthly Spending, Total Orders, AOV
- **Line Chart**: Monthly spending trend
- **Combo Chart**: New vs Returning Customers with Retention Rate overlay
- **Bar Chart**: Top 5 subcategories by spending (Road Bikes lead at $31M)
- **Bar Chart**: Purchase reasons ranked by customer count 


### Page 2: Customer Segmentation

![Dashboard Preview](images/Customer%20Analytics-2.png)

- **Scatter Plot**: RFM Analysis matrix (Recency,Frequency and Monetary as size) with segment labels
- **Bar Chart**: Customer distribution across 6 RFM segments + drill through to customer details
- **Donut Charts**: Gender split (50.66% Male, 49.34% Female)
- **Geographic Map**: Customer distribution by country
- **Bar Chart**: Age group breakdown (60+ largest at 6.3K)


### Page 3: Customer Details

![Dashboard Preview](images/Customer%20Analytics-3.png)

- **Data Table**: Detailed customer demographics and RFM segmentation
- **Fields**: Name, Age, Gender, Location, RFM metrics, Segment

-----

## Contact Information

- Email: <ziad.mohamed17.1@gmail.com>
- LinkedIn: [www.linkedin.com/in/ziadsoliman](www.linkedin.com/in/ziadsoliman)

-----

## Resources

- AdventureWorks Database: [Microsoft SQL Samples](https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver17&tabs=ssms)

-----
