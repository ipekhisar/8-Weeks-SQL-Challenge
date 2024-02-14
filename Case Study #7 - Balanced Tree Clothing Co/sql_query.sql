HIGH LEVEL SALES ANALYSIS
	
1-What was the total quantity sold for all products?

SELECT SUM(qty) AS total_quantity from balanced_tree_sales

2-What is the total generated revenue for all products before discounts?

select SUM(qty*price) as total_amount_without_discount from balanced_tree_sales

3-What was the total discount amount for all products?

SELECT SUM(qty*price*discount*0.01) as Total_Discount_Amount FROM balanced_tree_sales

TRANSACTION ANALYSIS
	
Q1-How many unique transactions were there?

SELECT COUNT (DISTINCT txn_id) AS COUNT_TRANSACTIONS FROM balanced_tree_sales

Q2-What is the average unique products purchased in each transaction?
	
SELECT AVG(PRODUCT_COUNT) AS AVG_UNIQUE_PRODUCTS FROM 
(
SELECT txn_id, COUNT(DISTINCT prod_id) AS PRODUCT_COUNT FROM balanced_tree_sales
GROUP BY txn_id
) AS TEMP

Q3-What are the 25th, 50th and 75th percentile values for the revenue per transaction?


Q4-What is the average discount value per transaction?

SELECT CAST(AVG(TOTAL_DISCOUNT) AS DECIMAL(5,1)) AS AVG_DISC_VALUE_PER_TXN FROM
(SELECT txn_id, SUM(qty*price*discount*.01) TOTAL_DISCOUNT from balanced_tree_sales	
GROUP BY txn_id) AS TEMP

Q5-What is the percentage split of all transactions for members vs non-members?

SELECT CAST(100.0*COUNT (DISTINCT CASE WHEN member = 1 THEN txn_id END)/COUNT(DISTINCT txn_id) AS decimal(4,2)) AS MEMBER,
	   CAST(100.0*COUNT (DISTINCT CASE WHEN member = 0 THEN txn_id END)/COUNT(DISTINCT txn_id) AS decimal(4,2)) AS NONMEMBER
FROM balanced_tree_sales

Q6-What is the average revenue for member transactions and non-member transactions?

SELECT CAST(1.0*SUM(CASE WHEN member=1 THEN (qty*price) END)/COUNT(DISTINCT CASE WHEN MEMBER=1 THEN txn_id END) AS DECIMAL(5,2)) AS AVG_REV_FOR_MEMBER,
	   CAST(1.0*SUM(CASE WHEN member=0 THEN (qty*price) END)/COUNT(DISTINCT CASE WHEN MEMBER=0 THEN txn_id END) AS DECIMAL(5,2)) AS AVG_REV_FOR_NON_MEMBER
FROM balanced_tree_sales

PRODUCT ANALYSIS
	
Q1-What are the top 3 products by total revenue before discount?

Select TOP 3 product_name, SUM(qty*BTS.price) AS TOTAL_REVENUE from balanced_tree_sales BTS
INNER JOIN balanced_tree_product_details BTPB ON BTPB.product_id=BTS.prod_id
GROUP BY product_name
ORDER BY 2 DESC

Q2-What is the total quantity, revenue and discount for each segment?

select segment_name, SUM(qty) TOTAL_QUANTITY, SUM(qty*bts.price) TOTAL_REVENUE, SUM(qty*bts.price*discount*.01) TOTAL_DISCOUNT from balanced_tree_sales BTS
INNER JOIN balanced_tree_product_details BTPD on BTPD.product_id=BTS.prod_id
GROUP BY segment_name
ORDER BY 3 DESC

Q3-What is the top selling product for each segment?

select*from balanced_tree_sales
select*from balanced_tree_product_details

SELECT NEW_TABLE.segment_name, NEW_TABLE.product_name, COUNT_ FROM 
(SELECT BTPD.segment_name, BTPD.product_name, SUM(qty) COUNT_, 
DENSE_RANK() OVER (PARTITION by BTPD.SEGMENT_NAME ORDER BY SUM(qty) DESC) AS RNK
FROM balanced_tree_sales BTS
JOIN balanced_tree_product_details BTPD ON BTPD.product_id=BTS.prod_id
GROUP BY BTPD.segment_name, BTPD.product_name) AS NEW_TABLE
WHERE RNK=1

Q4-What is the total quantity, revenue and discount for each category?

select category_name, SUM(qty) TOTAL_QUANTITY, SUM(qty*bts.price) TOTAL_REVENUE, SUM(qty*bts.price*discount*.01) TOTAL_DISCOUNT from balanced_tree_sales BTS
INNER JOIN balanced_tree_product_details BTPD on BTPD.product_id=BTS.prod_id
GROUP BY category_name
ORDER BY 3 DESC

Q5-What is the top selling product for each category?

SELECT NEW_TABLE.category_name, NEW_TABLE.product_name, COUNT_ FROM 
(SELECT BTPD.category_name, BTPD.product_name, SUM(qty) COUNT_, 
DENSE_RANK() OVER (PARTITION by BTPD.CATEGORY_NAME ORDER BY SUM(qty) DESC) AS RNK
FROM balanced_tree_sales BTS
JOIN balanced_tree_product_details BTPD ON BTPD.product_id=BTS.prod_id
GROUP BY BTPD.category_name, BTPD.product_name) AS NEW_TABLE
WHERE RNK=1

Q6-What is the percentage split of revenue by product for each segment? 

WITH CTE_PRODUCT_REVENUE AS(
	SELECT DISTINCT product_name, segment_name, SUM(qty*BTS.price) AS REVENUE_EACH_PROD
	FROM balanced_tree_product_details PD
	JOIN balanced_tree_sales BTS ON PD.product_id=BTS.prod_id
	GROUP BY product_name, segment_name
)

SELECT product_name, segment_name, CAST(100.0*REVENUE_EACH_PROD/(SUM(REVENUE_EACH_PROD) OVER (PARTITION BY segment_name)) as decimal(4,2)) AS PERCENTAGE_OF FROM CTE_PRODUCT_REVENUE
ORDER BY segment_name

Q7-What is the percentage split of revenue by segment for each category?

WITH CTE_PRODUCT_REVENUE AS(
	SELECT DISTINCT segment_name, category_name, SUM(qty*BTS.price) AS REVENUE_EACH_PROD
	FROM balanced_tree_product_details PD
	JOIN balanced_tree_sales BTS ON PD.product_id=BTS.prod_id
	GROUP BY segment_name, category_name
)

SELECT segment_name, category_name, CAST(100.0*REVENUE_EACH_PROD/(SUM(REVENUE_EACH_PROD) OVER (PARTITION BY CATEGORY_NAME)) as decimal(4,2)) AS PERCENTAGE_OF FROM CTE_PRODUCT_REVENUE
ORDER BY category_name 

Q8-What is the percentage split of total revenue by category?

SELECT category_name, CAST(100.0*sum(qty*BTS.price)/(SELECT SUM(qty*price) FROM balanced_tree_sales) AS decimal(4,2)) AS REVENUE FROM balanced_tree_sales BTS
JOIN balanced_tree_product_details PD ON PD.product_id=BTS.prod_id
GROUP BY category_name

Q9-What is the total transaction  penetration  for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)

SELECT prod_id, product_name, CAST(100.0*COUNT(txn_id)/(SELECT COUNT (DISTINCT txn_id) AS COUNT_Txn FROM balanced_tree_sales) AS decimal(4,2)) as PERCENTAGE_TXN FROM balanced_tree_sales BTS
JOIN balanced_tree_product_details PD ON PD.product_id=BTS.prod_id
GROUP BY prod_id, product_name
ORDER BY PERCENTAGE_TXN DESC

Q10-What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?

WITH PROD_PER_TXN AS(
SELECT txn_id, prod_id, product_name, qty, COUNT(PB.product_id) OVER (PARTITION BY txn_id) as count_ FROM balanced_tree_sales BTS
JOIN balanced_tree_product_details PB ON PB.product_id=BTS.prod_id
),

combinations AS(
	SELECT 
		STRING_AGG(prod_id,',') WITHIN GROUP (ORDER BY prod_id) AS product_ids,
		STRING_AGG(product_name,',') WITHIN GROUP (ORDER BY prod_id) AS product_names
	FROM PROD_PER_TXN
	where COUNT_=3
	GROUP BY txn_id
),

combination_count AS(
	SELECT 
		product_ids, product_names, COUNT(*) as common_combination
	FROM combinations
	GROUP BY product_ids,product_names
)

SELECT product_ids, product_names FROM combination_count 
where common_combination= (SELECT MAX(common_combination) FROM combination_count)
