SELECT * FROM category;
SELECT * FROM products;
SELECT * FROM sales;
SELECT * FROM stores;
SELECT * FROM warranty;

-- DATA CLEANING

-- CHECK FOR NULL VALUES
	-- REMOVING NULL VALUES FROM PRIMARY COLUMNS IF EXISTS
    
		DELETE FROM category 
        WHERE category_id IS NULL;
        DELETE FROM products 
        WHERE Product_ID IS NULL;
        DELETE FROM SALES 
        WHERE sale_id IS NULL;
        DELETE FROM stores 
        WHERE Store_ID IS NULL;
        DELETE FROM warranty 
        WHERE claim_id IS NULL;
        
	-- CHECKING THE NULL VALUES COUNT IN EACH TABLE
    -- CATEGORY TABLE
		SELECT 
			SUM( CASE WHEN category_id IS NULL THEN 1 ELSE 0 END) AS category_id_NULL_COUNT,
            SUM(CASE WHEN category_name IS NULL THEN 1 ELSE 0 END) AS category_name_NULL_COUNT
		FROM category; -- NO NULL VALUES
    -- PRODUCTS TABLE
		SELECT 
			SUM( CASE WHEN products.Product_ID IS NULL THEN 1 ELSE 0 END) AS Product_ID_NULL_COUNT,
            SUM( CASE WHEN products.Product_Name IS NULL THEN 1 ELSE 0 END) AS Product_Name_NULL_COUNT,
            SUM( CASE WHEN products.category_id IS NULL THEN 1 ELSE 0 END) AS Category_ID_NULL_COUNT,
            SUM( CASE WHEN products.Launch_Date IS NULL THEN 1 ELSE 0 END) AS Launch_Date_NULL_COUNT,
            SUM( CASE WHEN products.Price IS NULL THEN 1 ELSE 0 END) AS Price_NULL_COUNT   
		FROM products; -- NO NULL VALUES
    -- SALES TABLE
		SELECT 
			SUM( CASE WHEN sales.sale_id IS NULL THEN 1 ELSE 0 END) AS sale_id_NULL_COUNT,
            SUM( CASE WHEN sales.sale_date IS NULL THEN 1 ELSE 0 END) AS sale_date_NULL_COUNT,
            SUM( CASE WHEN sales.store_id IS NULL THEN 1 ELSE 0 END) AS store_id_NULL_COUNT,
            SUM( CASE WHEN sales.product_id IS NULL THEN 1 ELSE 0 END) AS product_id_NULL_COUNT,
            SUM( CASE WHEN sales.quantity IS NULL THEN 1 ELSE 0 END) AS quantity_NULL_COUNT   
		FROM sales; -- NO NULL VALUES
    -- STORES TABLE
		SELECT 
			SUM( CASE WHEN stores.Store_ID IS NULL THEN 1 ELSE 0 END) AS Store_ID_NULL_COUNT,
            SUM( CASE WHEN stores.Store_Name IS NULL THEN 1 ELSE 0 END) AS Store_Name_NULL_COUNT,
            SUM( CASE WHEN stores.City IS NULL THEN 1 ELSE 0 END) AS City_NULL_COUNT,
            SUM( CASE WHEN stores.Country IS NULL THEN 1 ELSE 0 END) AS Country_NULL_COUNT
		FROM stores; -- NO NULL VALUES
    -- WARRANTY TABLE
		SELECT 
			SUM( CASE WHEN warranty.claim_id IS NULL THEN 1 ELSE 0 END) AS claim_id_NULL_COUNT,
            SUM( CASE WHEN warranty.claim_date IS NULL THEN 1 ELSE 0 END) AS claim_date_NULL_COUNT,
            SUM( CASE WHEN warranty.sale_id IS NULL THEN 1 ELSE 0 END) AS sale_id_NULL_COUNT,
            SUM( CASE WHEN warranty.repair_status IS NULL THEN 1 ELSE 0 END) AS repair_status_NULL_COUNT
		FROM warranty; -- NO NULL VALUES
		
-- DUPLICATES HANDLING 
	-- CATEGORY TABLE
		SELECT 
			category_id,
            COUNT(*) AS DUP_CNT
		FROM category
        GROUP BY category_id
        HAVING DUP_CNT > 1; -- NO DUPLICATES
    -- PRODUCTS TABLE
		SELECT 
			Product_ID,
            COUNT(*) AS DUP_CNT
		FROM PRODUCTS
        GROUP BY Product_ID
        HAVING DUP_CNT > 1; -- NO DUPLICATES
	-- SALES TABLE
		SELECT 
			sale_id,
            COUNT(*) AS DUP_CNT
		FROM sales
        GROUP BY sale_id
        HAVING DUP_CNT > 1; -- NO DUPLICATES
	-- STORES TABLE
		SELECT 
			Store_ID,
            COUNT(*) AS DUP_CNT
		FROM stores
        GROUP BY Store_ID
        HAVING DUP_CNT > 1; -- NO DUPLICATES
	-- WARRANTY TABLE
		SELECT 
			claim_id,
            COUNT(*) AS DUP_CNT
		FROM warranty
        GROUP BY claim_id
        HAVING DUP_CNT > 1; -- NO DUPLICATES

-- THIS DATASET DOSE NOT HAVE ANY NULL VALUES OR ANY DUPLICATES

/*
1. Sales & Revenue Analysis 
*/
-- 1. Find the top 5 products that generated the highest revenue in the last year.  

SELECT
	products.Product_Name,
    SUM(sales.quantity * products.Price) AS TOTAL_REVENUE
FROM products
JOIN sales
	ON products.Product_ID = sales.product_id
WHERE sales.sale_date = (SELECT MAX(YEAR(sales.sale_date)) FROM sales)
GROUP BY products.Product_Name
ORDER BY TOTAL_REVENUE DESC
LIMIT 5;
    
-- 2. Calculate the monthly sales growth rate for each store. 

WITH MONTHLY_SALES AS(
SELECT 
	sales.store_id,
    date_format( SALES.SALE_DATE, '%Y-%m' ) AS SALES_MONTH,
	SUM( sales.quantity * products.Price ) AS TOTAL_REVENUE
FROM sales
JOIN products
	ON sales.product_id = products.Product_ID
GROUP BY sales.store_id, SALES_MONTH
ORDER BY SALES_MONTH
),
MONTH_GROWTH AS(
SELECT
	STORE_ID,
    SALES_MONTH,
    TOTAL_REVENUE,
    LAG(TOTAL_REVENUE) OVER (PARTITION BY STORE_ID ORDER BY SALES_MONTH) AS PREVIOUS_MONTH_REVENUE
FROM MONTHLY_SALES
)
SELECT 
	*,
    ROUND((100 * ((TOTAL_REVENUE - PREVIOUS_MONTH_REVENUE) / PREVIOUS_MONTH_REVENUE)),2) AS MONTH_GROWTH_PCT
FROM MONTH_GROWTH;

-- 3. Identify the seasonal trends in product sales (e.g., peak months).  

SELECT
	MONTH(sales.sale_date) AS SALES_MONTH,
    AVG(sales.quantity * products.Price) AS AVERAGE_REVENUE, 
    SUM(sales.quantity * products.Price) AS TOTAL_REVENUE
FROM sales
JOIN products
	ON sales.product_id = products.Product_ID
GROUP BY SALES_MONTH
ORDER BY TOTAL_REVENUE;

-- 4. Find the average selling price per category and compare across stores.

SELECT 
	products.Category_ID AS CATEGORY,
    sales.store_id AS STORE,
    AVG(sales.quantity * products.Price) AS AVG_SALES
FROM SALES
JOIN products
	ON sales.product_id = products.Product_ID
GROUP BY  CATEGORY, STORE
ORDER BY CATEGORY, STORE DESC;
	
-- 5. Determine the most profitable store based on total revenue. 

SELECT 
	stores.Store_Name AS STORE_NAME,
    SUM(sales.quantity * products.Price ) AS TOTAL_REVENUE
FROM sales
JOIN products
	ON sales.product_id = products.Product_ID
JOIN stores
	ON sales.store_id = stores.Store_ID
GROUP BY STORE_NAME
ORDER BY TOTAL_REVENUE DESC;

/*
2. Product & Category Insights	
*/

-- 6. List products that have never been sold since their launch.  

SELECT
	products.Product_Name
FROM products
LEFT JOIN sales
	ON products.Product_ID = sales.product_id
WHERE sales.product_id IS NULL;

-- 7. Find the fastest-growing category in terms of sales quantity.  

WITH SALES_DETAILS AS(
SELECT
	category.category_name AS CATEGORY_NAME,
    date_format(sales.sale_date,'%Y-%m') AS SALES_MONTH,
    SUM(sales.quantity) AS QUANTITY
FROM sales
JOIN products
	ON products.Product_ID = sales.product_id
JOIN category
	ON products.Category_ID = category.category_id
GROUP BY CATEGORY_NAME, SALES_MONTH
ORDER BY CATEGORY_NAME, SALES_MONTH
),
GROWTH_DETAILS AS(
SELECT
	*,
    LAG(QUANTITY) OVER (PARTITION BY CATEGORY_NAME ORDER BY CATEGORY_NAME, SALES_MONTH) AS PREVIOUS_MONTH_QUANTITY
FROM SALES_DETAILS
)
SELECT 
	*,
    ( 100 * (QUANTITY - PREVIOUS_MONTH_QUANTITY) / PREVIOUS_MONTH_QUANTITY) AS GROWTH_RATE
FROM GROWTH_DETAILS
ORDER BY GROWTH_RATE DESC;

-- 8. Identify products with high revenue with low sales quantity.  

WITH SALES_QTY AS(
SELECT
	products.Product_ID AS PRODUCT_ID,
    SUM(sales.quantity) AS QTY,
    SUM(products.Price * sales.quantity) AS REVENUE
FROM sales
JOIN products
	ON sales.product_id = products.Product_ID
GROUP BY PRODUCT_ID
),
AVERAGES AS(
SELECT
	AVG(QTY) AS AVG_QTY,
    AVG(REVENUE) AS AVG_REVENUE
FROM SALES_QTY
)
SELECT
	PRODUCT_ID,
    QTY,
    REVENUE
FROM SALES_QTY
CROSS JOIN AVERAGES
WHERE QTY < AVG_QTY AND REVENUE > AVG_REVENUE
ORDER BY REVENUE;
	
-- 9. Compare the average warranty claims per category to spot quality issues.  

WITH CLAIM_DETAILS AS(
SELECT 
    products.Product_ID AS PRODUCT_ID,
    products.Product_Name AS PRODUCT_NAME,
	category.Category_ID AS CATEGORY_ID,
    category.category_name AS CATEGORY_NAME,
    COUNT(warranty.claim_id) AS CLAIM_COUNT
FROM warranty
JOIN sales
	ON warranty.sale_id = sales.sale_id
JOIN products
	ON sales.product_id = products.Product_ID
JOIN category
	ON products.Category_ID = category.category_id
GROUP BY PRODUCT_ID, PRODUCT_NAME, CATEGORY_ID, CATEGORY_NAME
)
SELECT
	CLAIM_DETAILS.CATEGORY_ID AS CATEGORY_ID,
    CLAIM_DETAILS.CATEGORY_NAME AS CATEGORY_NAME,
    AVG(CLAIM_DETAILS.CLAIM_COUNT) AS AVG_CLAIM_COUNT
FROM CLAIM_DETAILS
GROUP BY CATEGORY_ID, CATEGORY_NAME
ORDER BY CATEGORY_ID, CATEGORY_NAME;
    
-- 10. Find the top 3 categories contributing to overall revenue.  

SELECT
	category.category_name AS CATEGORY_NAME,
    SUM(sales.quantity * products.Price) AS TOTAL_REVENUE
FROM sales
JOIN products
	ON sales.product_id = products.Product_ID
JOIN category
	ON products.Category_ID = category.category_id
GROUP BY CATEGORY_NAME
ORDER BY TOTAL_REVENUE DESC
LIMIT 3;
	
/*
3. Store Performance
*/

-- 11. Rank stores by sales per city (City-level aggregation).  

SELECT 
	stores.City AS CITY,
    stores.Store_Name AS STORE_NAME,
    SUM(sales.quantity * products.Price) AS REVENUE,
    RANK() OVER (PARTITION BY CITY ORDER BY SUM(sales.quantity * products.Price) DESC) AS RNK
FROM sales
JOIN stores
	ON sales.store_id = stores.Store_ID
JOIN products
	ON sales.product_id = products.Product_ID
GROUP BY CITY, STORE_NAME;

-- 12. Find stores that sell high-value products but have low warranty claims.

WITH HIGH_VALUE_PRODUCTS AS (
SELECT 
	products.Product_ID AS PRODUCT_ID,
    products.Price AS PRODUCT_PRICE
FROM products
WHERE products.Price > (SELECT AVG(PRICE) FROM products) -- AVG PRICE = 1078.0787
),
COSTLY_SALES_STORE AS (
SELECT 
	HIGH_VALUE_PRODUCTS.PRODUCT_ID,
    sales.store_id AS STORE_ID
FROM HIGH_VALUE_PRODUCTS
LEFT JOIN sales
	ON HIGH_VALUE_PRODUCTS.PRODUCT_ID = sales.product_id
),
STORE_CLAIM_COUNT AS (
SELECT 
	sales.store_id AS STORE_ID,
    COUNT(warranty.claim_id) AS CLAIM_COUNT_PER_STORE
FROM SALES
JOIN warranty
	ON sales.sale_id = warranty.sale_id
GROUP BY STORE_ID
ORDER BY CLAIM_COUNT_PER_STORE
),
STORE_LOW_CLAIM_COUNT AS (
SELECT 
	STORE_ID,
    CLAIM_COUNT_PER_STORE
FROM STORE_CLAIM_COUNT 
WHERE CLAIM_COUNT_PER_STORE < (	SELECT 
									AVG(CLAIM_COUNT_PER_STORE) -- AVG CLAIM COUNT = 400.0000
								FROM STORE_CLAIM_COUNT)
)
SELECT 
	DISTINCT COSTLY_SALES_STORE.STORE_ID,
    stores.Store_Name AS STORE_NAME
FROM COSTLY_SALES_STORE
INNER JOIN STORE_LOW_CLAIM_COUNT
	ON COSTLY_SALES_STORE.STORE_ID = STORE_LOW_CLAIM_COUNT.STORE_ID
JOIN stores
	ON COSTLY_SALES_STORE.STORE_ID = stores.Store_ID;

-- 13. Identify stores with highest warranty claim ratio.  

WITH STORE_SALES_COUNT AS (
SELECT
	sales.store_id AS STORE_ID,
    COUNT(sales.sale_id) AS SALES_COUNT
FROM SALES
GROUP BY STORE_ID
),
STORE_CLAIM_COUNT AS (
SELECT 
	sales.store_id AS STORE_ID,
    COUNT(warranty.claim_id) AS CLAIM_COUNT
FROM warranty
JOIN sales
	ON warranty.sale_id = sales.sale_id
GROUP BY STORE_ID
)
SELECT 
	DISTINCT sales.store_id AS STORE_ID,
    STORE_SALES_COUNT.SALES_COUNT AS SALES_COUNT,
    STORE_CLAIM_COUNT.CLAIM_COUNT AS CLAIM_COUNT,
    ROUND((STORE_SALES_COUNT.SALES_COUNT / STORE_CLAIM_COUNT.CLAIM_COUNT),2) AS CLAIM_RATIO
FROM STORE_SALES_COUNT
JOIN sales
	ON sales.store_id = STORE_SALES_COUNT.STORE_ID
JOIN STORE_CLAIM_COUNT
	ON sales.store_id = STORE_CLAIM_COUNT.STORE_ID
ORDER BY CLAIM_RATIO DESC;



-- 14. Compare sales performance across countries.  

SELECT
	stores.Country AS COUNTRY,
    SUM(sales.quantity) AS TOTAL_QUANTITY,
    SUM(sales.quantity * products.Price) AS TOTAL_SALES
FROM sales
JOIN products
	ON sales.product_id = products.Product_ID
JOIN stores
	ON sales.store_id = stores.Store_ID
GROUP BY COUNTRY
ORDER BY TOTAL_SALES DESC;



-- 15. Find the store with maximum product diversity (unique products sold).

SELECT
	sales.store_id AS STORE_ID,
    COUNT(DISTINCT sales.product_id) AS UNIQUE_PRODUCTS_COUNT
FROM sales
GROUP BY STORE_ID
ORDER BY UNIQUE_PRODUCTS_COUNT DESC;

/*
4. Warranty & Quality Analysis
*/

-- 16. Find the average time gap between saledate and claimdate.  

SELECT
	ROUND(AVG(DATEDIFF(warranty.claim_date, sales.sale_date)),2) AS AVG_GAP_DAYS,
    ROUND(AVG((DATEDIFF(warranty.claim_date, sales.sale_date) / 30)),2) AS AVG_GAP_MONTHS,
    ROUND(AVG((DATEDIFF(warranty.claim_date, sales.sale_date) / 365)),2) AS AVG_GAP_YEAR
FROM warranty
JOIN sales
	ON warranty.sale_id = sales.sale_id;

-- 17. Identify products with highest repair_status = 'Pending' claims.  

SELECT
	sales.product_id AS PRODUCT_ID,
    COUNT(warranty.repair_status) AS COUNT
FROM warranty
JOIN sales
	ON warranty.sale_id = sales.sale_id
WHERE warranty.repair_status = 'Pending'
GROUP BY PRODUCT_ID
ORDER BY COUNT DESC;


-- 18. Calculate the claim rate per product (claims/sales).  

WITH PRODUCT_CLAIM_COUNT AS (
SELECT 
	sales.product_id AS PRODUCT_ID,
    COUNT(warranty.repair_status) AS CLAIM_COUNT
FROM warranty
JOIN sales
	ON warranty.sale_id = sales.sale_id
GROUP BY PRODUCT_ID
),
PRODUCT_SALES_COUNT AS (
SELECT 
	sales.product_id AS PRODUCT_ID,
    COUNT(sales.sale_id) AS SALES_COUNT
FROM sales
GROUP BY PRODUCT_ID
)
SELECT
	PRODUCT_CLAIM_COUNT.PRODUCT_ID,
    PRODUCT_CLAIM_COUNT.CLAIM_COUNT,
    PRODUCT_SALES_COUNT.SALES_COUNT,
    (PRODUCT_CLAIM_COUNT.CLAIM_COUNT / PRODUCT_SALES_COUNT.SALES_COUNT) * 100 AS CLAIM_RATE
FROM PRODUCT_CLAIM_COUNT
LEFT JOIN PRODUCT_SALES_COUNT
	ON PRODUCT_CLAIM_COUNT.PRODUCT_ID = PRODUCT_SALES_COUNT.PRODUCT_ID
ORDER BY CLAIM_RATE DESC;

-- 19. Find the top 5 products with the worst warranty performance.  

WITH PRODUCT_CLAIM_COUNT AS (
SELECT 
	sales.product_id AS PRODUCT_ID,
    COUNT(warranty.repair_status) AS CLAIM_COUNT
FROM warranty
JOIN sales
	ON warranty.sale_id = sales.sale_id
GROUP BY PRODUCT_ID
),
PRODUCT_SALES_COUNT AS (
SELECT 
	sales.product_id AS PRODUCT_ID,
    COUNT(sales.sale_id) AS SALES_COUNT
FROM sales
GROUP BY PRODUCT_ID
)
SELECT
	PRODUCT_CLAIM_COUNT.PRODUCT_ID,
    PRODUCT_CLAIM_COUNT.CLAIM_COUNT,
    PRODUCT_SALES_COUNT.SALES_COUNT,
    (PRODUCT_CLAIM_COUNT.CLAIM_COUNT / PRODUCT_SALES_COUNT.SALES_COUNT) * 100 AS CLAIM_RATE
FROM PRODUCT_CLAIM_COUNT
LEFT JOIN PRODUCT_SALES_COUNT
	ON PRODUCT_CLAIM_COUNT.PRODUCT_ID = PRODUCT_SALES_COUNT.PRODUCT_ID
ORDER BY CLAIM_RATE DESC
LIMIT 5;

-- 20. Find the high-value products with high warranty claims.

WITH HIGH_VALUE_PRODUCTS AS (
SELECT
	products.Product_ID AS PRODUCT_ID
FROM products
WHERE products.Price > (SELECT AVG(products.Price) FROM products) -- AVG PRODUCT PRICE = 1078.0787
),
CLAIM_PRODUCTS AS (
SELECT
	sales.Product_ID AS PRODUCT_ID,
    COUNT(warranty.claim_id) AS CLAIM_COUNT
FROM warranty
LEFT JOIN sales
	ON warranty.sale_id = sales.sale_id
GROUP BY PRODUCT_ID
),
HIGH_CLAIM_PRODUCTS AS (
SELECT
	CLAIM_PRODUCTS.PRODUCT_ID AS PRODUCT_ID,
    CLAIM_PRODUCTS.CLAIM_COUNT AS CLAIM_COUNT
FROM CLAIM_PRODUCTS
WHERE CLAIM_PRODUCTS.CLAIM_COUNT > (SELECT AVG(CLAIM_COUNT) FROM CLAIM_PRODUCTS)
)
SELECT
	HIGH_VALUE_PRODUCTS.Product_ID AS PRODUCT_ID,
    HIGH_CLAIM_PRODUCTS.CLAIM_COUNT AS CLAIM_COUNT
FROM HIGH_VALUE_PRODUCTS
INNER JOIN HIGH_CLAIM_PRODUCTS
	ON HIGH_VALUE_PRODUCTS.PRODUCT_ID = HIGH_CLAIM_PRODUCTS.PRODUCT_ID;

