# AdventureWorks2022 — SQL, Python & Power BI Sales Analytics

A portfolio redevelopment of an educational SQL knowledge check, using Microsoft's historical AdventureWorks2022 sample. The original work covered T-SQL joins, basic reporting and a Python confidence interval. This package extends it with reproducible KPI queries, data quality tests, a SQL-to-Python notebook, and **Power BI build materials**.

## Business questions
1. How do sales revenue, order counts and average order value change over time?
2. Which territories contribute most revenue?
3. Which products lead by units and line revenue?
4. How complete and consistent are the source data?

## Contents
| File | Purpose |
| --- | --- |
| `analysis.sql` | SQL metrics and data quality checks |
| `sales_analysis.ipynb` | Python exploration, chart and descriptive statistics |
| `export_powerbi.py` | Read-only SQL extraction to four reproducible CSVs |
| `powerbi/model.sql` | SQL definitions for order and order-line fact tables, product and territory dimensions |
| `powerbi/measures.dax` | KPI measure templates and Date-table DAX |
| `powerbi/BUILD_GUIDE.md` | Power BI layout, relationships and QA checklist |
| `exports/README.md` | Location for generated CSVs (none bundled) |
| `requirements.txt` | Python dependencies |

## Run
1. Restore `AdventureWorks2022` in Microsoft SQL Server (not included).
2. Execute `analysis.sql` in SSMS against that database.
3. Install Python requirements with `pip install -r requirements.txt`.
4. Set `SQL_SERVER` to your instance. Windows PowerShell example: `$env:SQL_SERVER="YOUR_SERVER\SQLEXPRESS"` (substitute your actual instance).
5. Run the notebook from top to bottom. It reads live SQL data; screenshots/outputs are not prefilled.
6. `python export_powerbi.py` writes CSVs to `exports/`.
7. Follow `powerbi/BUILD_GUIDE.md` to author the actual `.pbix` in Power BI Desktop.

## Key metric definitions
- **Revenue / AOV**: order-level `SalesOrderHeader.SubTotal`; excludes taxes and freight.
- **Units sold**: `SalesOrderDetail.OrderQty`, **not** `SalesYTD`.
- **Product revenue**: `SalesOrderDetail.LineTotal`; line-level, not order-level subtotals duplicated by joins.
- **Confidence interval**: illustrative inference about average order subtotal, subject to sampling assumptions. Since this database represents a historical sample, a t-interval is not proof of business improvement, causality or the real company's outcomes.
- **Year-over-year**: partial first and last calendar years should be flagged before comparing.

## Validation and limits
The notebook and SQL are intended for a local AdventureWorks2022 instance. No database backup or executed exports were provided; no output numbers or actual Power BI `.pbix` are claimed. Before publishing numerical findings, run checks and manually reconcile monthly/territory/product totals. Historical/demo data only, no current production facts.

## Resume description (Swedish)
Analyserade historiska försäljningsdata från AdventureWorks2022 med T-SQL och Python. Byggde SQL-frågor för omsättning, ordervärde, regioner och produkter samt underlag för Power BI med dimensionsmodell och DAX-mått. Arbetade med datavalidering och dokumentation av nyckeltal och analysbegränsningar.
