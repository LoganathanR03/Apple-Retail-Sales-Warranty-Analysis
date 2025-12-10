# 💻 Apple Retail Sales & Warranty Analysis SQL Project

### Overview

This project is a comprehensive analysis of a retail dataset covering sales, products, stores, categories, and warranty claims. The goal is to derive actionable business intelligence by examining key performance indicators (KPIs) across four major domains: Sales & Revenue, Product & Category Insights, Store Performance, and Warranty & Quality.
The entire analysis was performed using SQL, including advanced techniques like Window Functions (e.g., LAG, RANK) and Common Table Expressions (CTEs) for complex calculations like monthly growth rate and claim ratios.

### 📂 Dataset Schema

The analysis is based on five interconnected tables:
| Table | Description | Primary Key | Key Columns |
|---|---|---|---|
| category | Product groupings. | category_id | category_name |
| products | Product details and pricing. | Product_ID | Product_Name, Price, category_id (FK) |
| sales | Transactional sales records. | sale_id | sale_date, store_id (FK), product_id (FK), quantity |
| stores | Store locations and names. | Store_ID | Store_Name, City, Country |
| warranty | Product warranty claim details. | claim_id | claim_date, sale_id (FK), repair_status |

### 🛠️ Methodology and Data Cleaning

 * Initial Schema Review: Identified relationships and key metrics for analysis.
 * Data Quality Check: A rigorous check was performed on all core tables.
   * Null Value Handling: Verified and confirmed no NULL values in all primary key columns and critical foreign key columns.
   * Duplicate Handling: Verified and confirmed no duplicate entries based on primary keys across all tables.
 * Advanced Analysis: Employed complex SQL logic to calculate derived metrics (e.g., sales growth percentage, claim rate, average time-to-claim).

### 🎯 Key Analysis Areas & Insights

The project is structured around 20 specific business questions grouped into four major areas.
1. Sales & Revenue Analysis
| Q | Analysis Question | Key Insight Metric |
|---|---|---|
| 1 | Top 5 products by revenue in the last year. | Total Revenue |
| 2 | Monthly sales growth rate for each store. | Growth Rate Percentage |
| 3 | Seasonal trends in product sales (peak months). | Total Revenue by Month |
| 4 | Average selling price per category and store. | AVG(Revenue) |
| 5 | Most profitable store based on total revenue. | Total Revenue |
> Potential Insight: Identifying the top revenue generators helps in inventory planning and marketing focus. Analyzing monthly growth rates highlights underperforming or rapidly scaling stores.
> 
2. Product & Category Insights
| Q | Analysis Question | Key Insight Metric |
|---|---|---|
| 6 | Products that have never been sold since launch. | Unsold Products List |
| 7 | Fastest-growing category by sales quantity. | Category Sales Growth Rate |
| 8 | Products with high revenue but low sales quantity (High Value). | Revenue vs. Quantity comparison |
| 9 | Average warranty claims per category (to spot quality issues). | AVG(Claim Count) per Category |
| 10 | Top 3 categories contributing to overall revenue. | Total Revenue |
> Potential Insight: A high average claim count in a category (Q9) suggests systemic quality issues that need R&D attention, while Q8 identifies premium/niche products.
> 
3. Store Performance
| Q | Analysis Question | Key Insight Metric |
|---|---|---|
| 11 | Rank stores by sales per city. | RANK() over City Partition |
| 12 | Stores selling high-value products but with low warranty claims. | Store Name (Efficiency Indicator) |
| 13 | Stores with the highest warranty claim ratio. | Claims/Sales Ratio |
| 14 | Compare sales performance across countries. | Total Sales & Quantity by Country |
| 15 | Store with maximum product diversity (unique products sold). | COUNT(DISTINCT Product_ID) |
> Potential Insight: High Claim Ratio (Q13) highlights poor quality assurance at specific locations, while diversity (Q15) indicates successful regional merchandising.
> 
4. Warranty & Quality Analysis
| Q | Analysis Question | Key Insight Metric |
|---|---|---|
| 16 | Average time gap between sale date and claim date. | AVG(DATEDIFF) in Days/Months |
| 17 | Products with highest 'Pending' repair status claims. | Pending Claim Count |
| 18 | Calculate the claim rate per product (claims/sales). | Claim Rate (%) |
| 19 | Top 5 products with the worst warranty performance. | Highest Claim Rate |
| 20 | High-value products with high warranty claims. | Product IDs (High Risk, High Cost) |
> Potential Insight: The average time gap (Q16) is crucial for managing warranty reserve funds. High-value, high-claim products (Q20) represent the most significant financial risk.
> 
🚀 How to Replicate
 * Database: Load the 5 tables (category, products, sales, stores, warranty) into your preferred SQL environment (MySQL, PostgreSQL, etc.).
 * Scripts: The entire project script, including data cleaning and all 20 analysis queries, is available in the main project file (e.g., analysis_script.sql).
 * Run Queries: Execute the queries sequentially to replicate the results shown in the PowerPoint presentation.
