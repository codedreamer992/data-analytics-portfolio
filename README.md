# Data Analytics Portfolio
## Murad Akhtar

## About
Aspiring Data Analyst skilled in Excel and SQL.
Building a portfolio of real-world business analysis 
projects through a structured 30-day analytics curriculum.
Currently learning Power BI and Python.

**Core Skills:** Excel | SQL | Data Cleaning | 
Pivot Tables | Window Functions | CTEs

---

## Project 1 — Amazon E-Commerce Sales Analysis
**Tool:** Microsoft Excel  
**Dataset:** 10,000 Amazon sales orders 
(January–February 2026)  
**Categories:** Electronics, Home, Fashion  
**US States covered:** 50  

### Key Findings
- Total revenue: 642,129,105 across 10,000 orders
- Average order value: 64,212 per order
- Electronics is the highest revenue category at 219,356,274 
  despite having fewer orders than Home (3,352 vs 3,379) — 
  indicating higher spend per transaction
- High-tier customers (orders above 100,000) represent 
  22.5% of orders but generate 50% of total revenue
- January revenue (489,990,113) was significantly higher 
  than February (152,138,991) — likely due to 
  incomplete February data
- North Carolina is the highest revenue state 
  at 15,037,672
- Data quality verified: no missing values, 
  no duplicates found across all 21 columns
- 163 statistical outliers identified via IQR analysis 
  and retained as legitimate high-value orders

### Skills Demonstrated
Data cleaning and audit logging, VLOOKUP, nested IF, 
SUMIF, COUNTIF, TEXT functions, pivot tables, 
exploratory data analysis, business memo writing 
using SCR framework

---

## Project 2 — Amazon E-Commerce SQL Analysis
**Tool:** SQL (SQLite)  
**Dataset:** Same 10,000 order dataset  
**Techniques:** JOINs, Window Functions, 
CTEs, CASE WHEN, LAG, DENSE_RANK  

### Key Findings

**Customer Analysis**
- VIP customers (2,663) generate 75% of total revenue 
  at 483,717,688 — highest priority retention segment
- Top 10% of customers (602) generate 27.14% of revenue, 
  spending 3.35x more per capita than remaining 90%
- Top 10% average lifetime value: 289,528 
  vs 86,412 for remaining 90%

**Product Analysis**
- Revenue is highly fragmented — no single blockbuster 
  product exists
- Top products contribute only 0.11% to 0.12% 
  of their category total
- Top Electronics product (P901): 249,155 revenue
- Top Fashion product (P412): 240,143 revenue  
- Top Home product (P750): 248,605 revenue

**State Performance**
- Georgia and South Dakota show high order volumes 
  (189–190 orders) but below-average order values 
  of 61,000–62,000
- Massachusetts outperforms with 189 orders 
  at 73,477 average order value
- California leads all states in total revenue

**SQL Techniques Used**
- Multi-table JOINs (3 tables simultaneously)
- Window functions: ROW_NUMBER, DENSE_RANK, 
  LAG, SUM OVER, AVG OVER
- CTE chains up to 3 steps deep
- CASE WHEN for customer and order segmentation
- NTILE for customer decile analysis
- Diagnosed and resolved JOIN explosion caused 
  by non-unique product_id keys

### Strategic Recommendation
Launch a dedicated VIP retention program targeting 
the 602 highest-value customers who drive over 
a quarter of total business. Simultaneously lift 
average order values in high-volume low-yield states 
like Georgia and South Dakota through automated 
spending thresholds and tiered bundling incentives. 
Create high-ticket cross-category packages to drive 
larger transaction sizes across the entire customer base.

---

## Currently Learning
- Power BI — dashboards and DAX
- Python — Pandas, data cleaning, visualization

## Curriculum
30-day structured Data Analytics program covering 
Excel → SQL → Power BI → Python# data-analytics-portfolio
