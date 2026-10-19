"""Export AdventureWorks source tables for Power BI. Requires read-only SQL access."""
import os
from pathlib import Path
import pandas as pd
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL

server = os.environ.get("SQL_SERVER")
if not server:
    raise SystemExit("Set SQL_SERVER to the SQL Server instance hostname before running.")
driver = os.environ.get("SQL_ODBC_DRIVER", "ODBC Driver 17 for SQL Server")
url = URL.create("mssql+pyodbc", host=server, database="AdventureWorks2022", query={"driver": driver, "trusted_connection": "yes", "TrustServerCertificate": "yes"})
engine = create_engine(url)
queries = {
    "fact_orders": """SELECT SalesOrderID, CAST(OrderDate AS date) AS OrderDate, CustomerID, TerritoryID,
      OnlineOrderFlag, SubTotal, TaxAmt, Freight, TotalDue FROM Sales.SalesOrderHeader""",
    "fact_lines": """SELECT SalesOrderID, SalesOrderDetailID, ProductID, OrderQty, UnitPrice,
      UnitPriceDiscount, LineTotal FROM Sales.SalesOrderDetail""",
    "dim_products": """SELECT p.ProductID, p.Name AS ProductName, p.ProductNumber,
      s.Name AS Subcategory, c.Name AS Category FROM Production.Product AS p
      LEFT JOIN Production.ProductSubcategory AS s ON p.ProductSubcategoryID = s.ProductSubcategoryID
      LEFT JOIN Production.ProductCategory AS c ON s.ProductCategoryID = c.ProductCategoryID""",
    "dim_territories": """SELECT TerritoryID, Name AS Territory, CountryRegionCode,
      [Group] AS RegionGroup FROM Sales.SalesTerritory"""
}
out = Path(__file__).resolve().parent / "exports"
out.mkdir(exist_ok=True)
with engine.connect() as con:
    for name, sql in queries.items():
        df = pd.read_sql(text(sql), con)
        target = out / f"{name}.csv"
        df.to_csv(target, index=False, encoding="utf-8-sig")
        print(f"{name}: {len(df):,} rows -> {target}")
print("Export completed. Open Power BI Desktop and follow powerbi/BUILD_GUIDE.md.")
