--C. Data Allocation Challenge

--running customer balance column that includes the impact each transaction

SELECT customer_id, txn_date, txn_type, txn_amount,
SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount
	 ELSE -txn_amount
	 END) OVER (PARTITION BY customer_id ORDER BY txn_date)
FROM customer_transactions

--customer balance at the end of each month

SELECT customer_id, 
DATEPART(month,txn_date) month_,
DATENAME(MONTH, txn_date) month_name,
SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount
	 ELSE -txn_amount
	 END) closing_balance
FROM customer_transactions
GROUP BY customer_id, DATEPART(month,txn_date), DATENAME(MONTH, txn_date)
ORDER BY customer_id

--minimum, average and maximum values of the running balance for each customer

WITH CTE AS (
SELECT customer_id, txn_date, txn_type, txn_amount,
SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount
	 ELSE -txn_amount
	 END) OVER (PARTITION BY customer_id ORDER BY txn_date) running_balance
FROM customer_transactions)

SELECT customer_id,
MIN(running_balance) MIN_VALUE,
AVG(running_balance) AVG_VALUE,
MAX(running_balance) MAX_VALUE
FROM CTE
GROUP BY customer_id