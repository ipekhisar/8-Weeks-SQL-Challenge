--1.How many unique nodes are there on the Data Bank system?

Select count(DISTINCT node_id) as unique_node_count from customer_nodes

--2.What is the number of nodes per region?

Select region_id, COUNT(node_id) #of_nodes from customer_nodes
GROUP BY region_id
ORDER BY region_id

--3.How many customers are allocated to each region?

Select region_id, COUNT(DISTINCT customer_id) #of_cust from customer_nodes
GROUP BY region_id
ORDER BY region_id

--4.How many days on average are customers reallocated to a different node?

WITH CTE AS (
	SELECT 
	customer_id, 
	node_id, 
	SUM(DATEDIFF(DAY, start_date, end_date)) as days_in_node
	FROM customer_nodes 
	where end_date <> '9999-12-31'
	GROUP BY  customer_id, node_id)
SELECT 
AVG(days_in_node) as avg_days_in_node FROM CTE

--5.What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

WITH CTE AS (
	SELECT
	region_name,
	customer_id, 
	node_id, 
	SUM(DATEDIFF(DAY, start_date, end_date)) as days_in_node
	FROM customer_nodes C
	INNER JOIN regions as R on R.region_id=C.region_id
	where end_date <> '9999-12-31'
	GROUP BY  customer_id, node_id)
SELECT 
region_name,
AVG(days_in_node) as avg_days_in_node,
PERCENTILE_CONT(0.80) WITHIN GROUP (ORDER BY days_in_node) as pc_80,
PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY days_in_node) as pc_95,
FROM CTE
GROUP BY region_name

