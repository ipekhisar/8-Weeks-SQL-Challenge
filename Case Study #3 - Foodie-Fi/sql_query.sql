A.  CUSTOMER JOURNEY
	
Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

select customer_id, plan_name, start_date from subscriptions S
INNER JOIN plans P on P.plan_id=S.plan_id

B. DATA ANALYSIS QUESTIONS
	
Q1.How many customers has Foodie-Fi ever had?

SELECT COUNT(DISTINCT customer_id) AS TOTAL_CUSTOMER FROM subscriptions

Q2.What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

WITH CTE AS (
SELECT customer_id, plan_id, start_date, DATEPART(MONTH, start_date) month_ ,ROW_NUMBER() OVER(PARTITION BY customer_id order by start_date) row FROM subscriptions)

select month_, COUNT(*) count_of_cust from CTE
where row=1
group by month_
order by MONTH_

Q3.What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

select s.plan_id, plan_name, COUNT(customer_id) count_2021 from subscriptions S 
INNER JOIN plans P ON P.plan_id=S.plan_id
where DATEPART(YEAR, start_date) > 2020
GROUP BY s.plan_id,plan_name
ORDER BY count_2021

Q4.What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

select COUNT(DISTINCT customer_id) as churned_count,
ROUND((CAST(COUNT(DISTINCT customer_id) AS FLOAT)/(SELECT COUNT(DISTINCT customer_id) from subscriptions))*100,2)
from subscriptions where plan_id=4	
  
Q5.How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
 
select*from subscriptions

WITH CTE AS (SELECT customer_id, plan_name, start_date ,ROW_NUMBER() OVER(PARTITION BY customer_id order by start_date) row FROM subscriptions S
INNER JOIN plans P ON P.plan_id=S.plan_id)
SELECT 
COUNT(DISTINCT customer_id),
(Select COUNT(DISTINCT customer_id) from subscriptions),
ROUND(COUNT(DISTINCT customer_id)*100/(Select COUNT(DISTINCT customer_id) from subscriptions),1)
FROM CTE 
WHERE row=2 and plan_name='churn'

Q6.What is the number and percentage of customer plans after their initial free trial?

WITH CTE AS (SELECT customer_id, plan_name, start_date ,ROW_NUMBER() OVER(PARTITION BY customer_id order by start_date) row FROM subscriptions S
INNER JOIN plans P ON P.plan_id=S.plan_id)

SELECT plan_name, COUNT(DISTINCT customer_id) COUNT_OF_CUSTOMER,
ROUND(COUNT(DISTINCT customer_id)*100.0/(Select COUNT(DISTINCT customer_id) from subscriptions),1) PERCENTAGE_OF_CUSTOMER
FROM CTE 
wHERE row=2
GROUP BY plan_name
ORDER BY COUNT_OF_CUSTOMER DESC

Q7.What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

WITH CTE AS (SELECT customer_id, plan_name, start_date ,ROW_NUMBER() OVER(PARTITION BY customer_id order by start_date DESC) row FROM subscriptions S
INNER JOIN plans P ON P.plan_id=S.plan_id
Where start_date<='2020-12-31')
select plan_name, COUNT(*) count_of_customer,
ROUND(COUNT(DISTINCT customer_id)*100.0/(Select COUNT(DISTINCT customer_id) from subscriptions),1) PERCENTAGE_OF_CUSTOMER
from CTE where row=1
GROUP BY plan_name

Q8.How many customers have upgraded to an annual plan in 2020?

WITH CTE AS (SELECT customer_id, plan_name, start_date ,ROW_NUMBER() OVER(PARTITION BY customer_id order by start_date DESC) row FROM subscriptions S
INNER JOIN plans P ON P.plan_id=S.plan_id
Where DATEPART(YEAR, start_date)='2020')
SELECT COUNT(*) FROM CTE WHERE row='1' and plan_name='pro annual'

Q9.How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

SELECT*FROM subscriptions

WITH CTE AS (SELECT customer_id, plan_name, start_date FROM subscriptions S
INNER JOIN plans P ON P.plan_id=S.plan_id
where plan_name='trial')
, CTE2 AS (SELECT customer_id, plan_name, start_date FROM subscriptions S
INNER JOIN plans P ON P.plan_id=S.plan_id
where plan_name='pro annual')

SELECT AVG(DATEDIFF(DAY,c.start_Date,c2.start_date))
from CTE C
INNER JOIN CTE2 C2 ON C.customer_id=C2.customer_id

Q10.Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

WITH CTE AS (SELECT customer_id, plan_name, start_date FROM subscriptions S
INNER JOIN plans P ON P.plan_id=S.plan_id
where plan_name='trial')
, CTE2 AS (SELECT customer_id, plan_name, start_date FROM subscriptions S
INNER JOIN plans P ON P.plan_id=S.plan_id
where plan_name='pro annual')

SELECT DISTINCT C.customer_id, c.plan_name, c.start_date, c2.plan_name, c2.start_date,
DATEDIFF(DAY,c.start_Date,c2.start_date) day_between_dates,
CASE
WHEN DATEDIFF(DAY,c.start_Date,c2.start_date) < 30 THEN '0-30 DAYS'
WHEN DATEDIFF(DAY,c.start_Date,c2.start_date) BETWEEN 30 and 60 THEN '31-60 DAYS'
WHEN DATEDIFF(DAY,c.start_Date,c2.start_date) BETWEEN 60 and 90 THEN '60-90 DAYS'
WHEN DATEDIFF(DAY,c.start_Date,c2.start_date) BETWEEN 90 and 110 THEN '90-110 DAYS'
WHEN DATEDIFF(DAY,c.start_Date,c2.start_date) BETWEEN 110 and 140 THEN '110-140 DAYS'
WHEN DATEDIFF(DAY,c.start_Date,c2.start_date) BETWEEN 140 and 180 THEN '140-180 DAYS'
ELSE 'upper 180'
END as days_
from CTE C
INNER JOIN CTE2 C2 ON C.customer_id=C2.customer_id

Q11.How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

WITH CTE AS (
SELECT customer_id, plan_name, start_date ,ROW_NUMBER() OVER(PARTITION BY customer_id order by start_date DESC) row FROM subscriptions S
INNER JOIN plans P ON P.plan_id=S.plan_id
Where DATEPART(YEAR, start_date)='2020')

SELECT COUNT(*) FROM CTE 
WHERE row=1 and plan_name='basic monthly' and row=2 and plan_name='basic monthly'

C. CHALLENGE PAYMENT QUESTIONS

The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:

WITH CTE AS (
	SELECT 
		customer_id, S.plan_id, plan_name, s.start_date as payment_date,
		CASE
			WHEN LEAD(s.start_date) OVER(PARTITION BY customer_id ORDER BY s.start_date) IS NULL THEN '2020-12-31'
			ELSE DATEADD(MONTH,
				DATEDIFF(MONTH, start_date, LEAD(start_Date) OVER(PARTITION BY customer_id ORDER BY start_date)),
				start_date) END AS last_date, 
		price AS amount
	FROM subscriptions S
	JOIN plans p on s.plan_id=p.plan_id
	WHERE plan_name NOT IN ('trial')
		AND YEAR(start_date)=2020

	UNION ALL

	SELECT 
		customer_id,
		plan_id,
		plan_name,
		DATEADD(MONTH, 1, payment_date) as payment_date,
		last_date,
		amount
	FROM CTE
	WHERE DATEADD(MONTH, 1, payment_date) <= last_date
	AND plan_name != 'pro annual'
)
SELECT
	customer_id,
	plan_id,
	plan_name,
	payment_date,
	amount,
	ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY payment_date) AS payment_order
INTO payments
FROM CTE
WHERE amount IS NOT NULL
ORDER BY customer_id
OPTION (MAXRECURSION 365)

