-- AdventureWorks2022 | Retail Sales Analytics
-- SQL Server / T-SQL. All metrics are derived from SalesOrderHeader and SalesOrderDetail.
USE AdventureWorks2022;
GO

-- 1. Sales KPI overview. SubTotal excludes tax and freight.
SELECT COUNT(*) AS OrderCount,
       COUNT(DISTINCT CustomerID) AS UniqueCustomers,
       CAST(SUM(SubTotal) AS decimal(18,2)) AS RevenueExclTaxFreight,
       CAST(AVG(SubTotal) AS decimal(18,2)) AS AverageOrderValue,
       CAST(SUM(TotalDue) AS decimal(18,2)) AS OrderValueInclTaxFreight
FROM Sales.SalesOrderHeader;

-- 2. Monthly performance: make grouping based on order date, not due date.
SELECT YEAR(OrderDate) AS OrderYear,
       MONTH(OrderDate) AS OrderMonth,
       COUNT(*) AS OrderCount,
       CAST(SUM(SubTotal) AS decimal(18,2)) AS Revenue,
       CAST(AVG(SubTotal) AS decimal(18,2)) AS AverageOrderValue
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY OrderYear, OrderMonth;

-- 3. Sales territory, measured from individual orders.
SELECT COALESCE(st.[Group], 'Unknown') AS RegionGroup,
       COALESCE(st.Name, 'Unassigned') AS Territory,
       COUNT(soh.SalesOrderID) AS OrderCount,
       CAST(SUM(soh.SubTotal) AS decimal(18,2)) AS Revenue
FROM Sales.SalesOrderHeader AS soh
LEFT JOIN Sales.SalesTerritory AS st ON soh.TerritoryID = st.TerritoryID
GROUP BY st.[Group], st.Name
ORDER BY Revenue DESC;

-- 4. Top products by units and line revenue. LineTotal excludes tax/freight.
SELECT TOP (10) p.ProductID, p.Name AS ProductName,
       SUM(sod.OrderQty) AS UnitsSold,
       CAST(SUM(sod.LineTotal) AS decimal(18,2)) AS LineRevenue
FROM Sales.SalesOrderDetail AS sod
JOIN Production.Product AS p ON p.ProductID = sod.ProductID
GROUP BY p.ProductID, p.Name
ORDER BY LineRevenue DESC, UnitsSold DESC;

-- 5. Year-over-year revenue change: compare completed calendar years only if appropriate.
WITH annual AS (
 SELECT YEAR(OrderDate) AS OrderYear, SUM(SubTotal) AS Revenue
 FROM Sales.SalesOrderHeader GROUP BY YEAR(OrderDate)
), growth AS (
 SELECT OrderYear, Revenue,
        LAG(Revenue) OVER (ORDER BY OrderYear) AS PreviousYearRevenue
 FROM annual
)
SELECT OrderYear, CAST(Revenue AS decimal(18,2)) AS Revenue,
       CAST(PreviousYearRevenue AS decimal(18,2)) AS PreviousYearRevenue,
       CAST(100.0 * (Revenue - PreviousYearRevenue) /
            NULLIF(PreviousYearRevenue, 0) AS decimal(10,2)) AS YoYPercent
FROM growth ORDER BY OrderYear;
-- Note: AdventureWorks may contain incomplete first/last years; interpret YoY carefully.

-- 6. Employees per CURRENT department (historical rows excluded).
SELECT d.Name AS Department, COUNT(*) AS ActiveEmployeeCount
FROM HumanResources.EmployeeDepartmentHistory AS edh
JOIN HumanResources.Department AS d ON d.DepartmentID = edh.DepartmentID
WHERE edh.EndDate IS NULL
GROUP BY d.Name ORDER BY ActiveEmployeeCount DESC;

-- 7. Basic data quality checks.
SELECT COUNT(*) AS AllOrders,
       SUM(CASE WHEN SubTotal IS NULL THEN 1 ELSE 0 END) AS MissingSubtotals,
       SUM(CASE WHEN SubTotal < 0 THEN 1 ELSE 0 END) AS NegativeSubtotals,
       COUNT(*) - COUNT(DISTINCT SalesOrderID) AS DuplicateOrderIDs
FROM Sales.SalesOrderHeader;
