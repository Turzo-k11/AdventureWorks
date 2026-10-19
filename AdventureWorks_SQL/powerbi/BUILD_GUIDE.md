# Power BI dashboard — build guide

## 1. Load data
Run `python export_powerbi.py` after setting `SQL_SERVER` and database access. Import all four CSV files from `exports/` into Power BI Desktop, setting IDs to whole number and dates to Date. Alternatively import the corresponding SQL queries from `powerbi/model.sql` directly using SQL Server.

## 2. Model (single-direction relationships)
- `fact_orders[SalesOrderID]` **1 → many** `fact_lines[SalesOrderID]` (filter from order to line).
- `dim_products[ProductID]` **1 → many** `fact_lines[ProductID]`.
- `dim_territories[TerritoryID]` **1 → many** `fact_orders[TerritoryID]`.
- `dim_date[Date]` **1 → many** `fact_orders[OrderDate]`.
Keep cross-filter direction single; avoid introducing ambiguous paths. Unassigned territories can remain unmatched; document the excluded breakdown rows. For territory-specific product revenue, filter territory → orders → lines. Make sure no other relationship creates multiple paths.

## 3. Measures
Add each DAX measure from `measures.dax` one by one; the date table and its columns are separate expressions. Mark `dim_date` as the date table. Sort `Month Name` by `Month Number`.

## 4. Page 1 — Executive Sales Overview
- Header: AdventureWorks | Historical Sales Overview.
- Cards: Total Revenue, Total Orders, Average Order Value, Unique Customers.
- Line chart: X = dim_date[Year Month], Y = Total Revenue. Sort ascending.
- Bar chart: Territory, Total Revenue (descending).
- Slicers: Year and RegionGroup.
- Footer: Historical demo data; revenue means SubTotal excluding tax and freight.

## 5. Page 2 — Product Performance
- Horizontal bar: ProductName by Product Line Revenue; Top N=10.
- Matrix: Category, Subcategory, ProductName with Units Sold, Product Line Revenue.
- Use explicit line-item revenue here (not summed order revenue duplicated across product lines).

## 6. QA checklist
- Compare Total Orders with SQL KPI query in `analysis.sql`.
- Compare overall Total Revenue with `SUM(Sales.SalesOrderHeader.SubTotal)`.
- Compare Units Sold with `SUM(Sales.SalesOrderDetail.OrderQty)`.
- Monthly totals should reconcile to headline revenue.
- Do not interpret year-over-year percentages as comparable for partial years without filtering.
- Confirm relationships and slicers filter measures as expected.

**Note:** `.pbix` is authored in Power BI Desktop. This repository delivers reproducible data/model/measure/build assets; it does not claim a Power BI report has been produced or validated without SQL Server and Power BI Desktop.
