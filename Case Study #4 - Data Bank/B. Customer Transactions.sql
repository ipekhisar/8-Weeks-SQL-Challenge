--1.What is the unique count and total amount for each transaction type?
SELECT * FROM customer_nodes
SELECT * FROM customer_transactions
SELECT * FROM regions

SELECT txn_type, 
COUNT(customer_id) unique_count,
SUM(txn_amount) total_amount
FROM customer_transactions
GROUP BY txn_type

--2.What is the average total historical deposit counts and amounts for all customers?

WITH CTE AS
(SELECT customer_id, 
COUNT(*) deposit_counts, 
AVG(txn_amount) deposit_amounts
FROM customer_transactions
WHERE txn_type='deposit'
GROUP BY customer_id)

SELECT 
AVG(deposit_counts), 
varchar,AVG(deposit_amounts) FROM CTE

--3.For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

WITH CTE AS (SELECT DATEPART(MONTH, txn_date) month_,
customer_id,
SUM(CASE WHEN txn_type='deposit' THEN 1 ELSE 0 END) as deposit,
SUM(CASE WHEN txn_type <> 'deposit' THEN 1 ELSE 0 END) as out_deposit
FROM customer_transactions
GROUP BY  DATEPART(MONTH, txn_date), customer_id)

SELECT month_,
COUNT(customer_id) FROM CTE
WHERE deposit>1 and out_deposit=1
GROUP BY month_

--4.What is the closing balance for each customer at the end of the month?

WITH CTE AS (SELECT
CONVERT(DATE,DATEADD(month, DATEDIFF(month,0,txn_date),0)) as month_,
txn_date,
customer_id,
SUM((CASE WHEN txn_type='deposit' THEN txn_amount ELSE 0 END)
-(CASE WHEN txn_type<>'deposit' THEN txn_amount ELSE 0 END)) as balance
FROM customer_transactions
GROUP BY txn_date,customer_id,CONVERT(DATE,DATEADD(month, DATEDIFF(month,0,txn_date),0))
)
, BALANCES AS(
SELECT *,
SUM(balance) OVER(PARTITION BY customer_id ORDER BY txn_date) as cum_balanced,
ROW_NUMBER() OVER(PARTITION BY customer_id, month_ ORDER BY txn_date DESC) as rn	
FROM CTE
)

SELECT customer_id, 
DATEADD(DAY,-1,DATEADD(MONTH, 1, month_)) as end_of_months
,cum_balanced as closing_balance FROM BALANCES
WHERE rn=1

--5.What is the percentage of customers who increase their closing balance by more than 5%?

WITH CTE AS (SELECT
CONVERT(DATE,DATEADD(month, DATEDIFF(month,0,txn_date),0)) as month_,
txn_date,
customer_id,
SUM((CASE WHEN txn_type='deposit' THEN txn_amount ELSE 0 END)
-(CASE WHEN txn_type<>'deposit' THEN txn_amount ELSE 0 END)) as balance
FROM customer_transactions
GROUP BY txn_date,customer_id,CONVERT(DATE,DATEADD(month, DATEDIFF(month,0,txn_date),0))
)
, BALANCES AS(
SELECT *,
SUM(balance) OVER(PARTITION BY customer_id ORDER BY txn_date) as cum_balanced,
ROW_NUMBER() OVER(PARTITION BY customer_id, month_ ORDER BY txn_date DESC) as rn	
FROM CTE
)
, CLOSING_BALANCES AS (
SELECT customer_id, 
DATEADD(DAY, -1, DATEADD(MONTH,1,month_)) AS end_of_months,
DATEADD(DAY, -1, month_) AS previous_month,
cum_balanced as closing_balance
FROM BALANCES
where rn=1
)
, PER_INC AS(
SELECT
CB1.customer_id,
CB1.end_of_months,
CB1.closing_balance,
CB2.closing_balance AS next_month_closing_balance,
CAST(CB2.closing_balance AS decimal(7,2))/CAST(CB1.closing_balance AS decimal(7,2))-1 PERCENTAGE_INCREASE,
CASE WHEN (CB2.closing_balance>CB1.closing_balance AND
(CB2.closing_balance/CB1.closing_balance)-1 > 0.05) THEN 1 ELSE 0 END AS PERC
FROM CLOSING_BALANCES AS CB1
INNER JOIN CLOSING_BALANCES CB2 ON CB1.end_of_months=CB2.previous_month
AND CB1.customer_id=CB2.customer_id
WHERE CB1.closing_balance <>0
)

SELECT
CAST(SUM(PERC) as decimal(15,3)) / CAST(COUNT(PERC) AS decimal(15,3))
FROM PER_INC

