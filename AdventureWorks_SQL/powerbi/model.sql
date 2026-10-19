-- AdventureWorks Power BI star-schema extraction (SQL Server)
-- Export each statement as a separate CSV with export_powerbi.py
-- Sales order grain for fact_orders: one row per order
-- Order line grain for fact_lines: one row per order detail
-- Dates in this sample dataset are historical; do not present these as live sales.

-- fact_orders
SELECT h.SalesOrderID, CAST(h.OrderDate AS date) AS OrderDate,
       h.CustomerID, h.TerritoryID, h.OnlineOrderFlag,
       CAST(h.SubTotal AS decimal(18,2)) AS SubTotal,
       CAST(h.TaxAmt AS decimal(18,2)) AS TaxAmt,
       CAST(h.Freight AS decimal(18,2)) AS Freight,
       CAST(h.TotalDue AS decimal(18,2)) AS TotalDue
FROM Sales.SalesOrderHeader AS h;

-- fact_lines
SELECT d.SalesOrderID, d.SalesOrderDetailID, d.ProductID, d.OrderQty,
       CAST(d.UnitPrice AS decimal(18,4)) AS UnitPrice,
       CAST(d.UnitPriceDiscount AS decimal(18,4)) AS UnitPriceDiscount,
       CAST(d.LineTotal AS decimal(18,2)) AS LineTotal
FROM Sales.SalesOrderDetail AS d;

-- dim_products
SELECT p.ProductID, p.Name AS ProductName, p.ProductNumber,
       s.Name AS Subcategory, c.Name AS Category
FROM Production.Product AS p
LEFT JOIN Production.ProductSubcategory AS s ON p.ProductSubcategoryID = s.ProductSubcategoryID
LEFT JOIN Production.ProductCategory AS c ON s.ProductCategoryID = c.ProductCategoryID;

-- dim_territories
SELECT t.TerritoryID, t.Name AS Territory, t.CountryRegionCode,
       t.[Group] AS RegionGroup
FROM Sales.SalesTerritory AS t;
