Q1. How many pizzas were ordered?

select*from CUSTOMER_ORDERS select*from RUNNER_ORDERS
select COUNT(*) countofpizza from CUSTOMER_ORDERS
 
Q2. How many unique customer orders were made?
 
select COUNT(DISTINCT customer_id) countofuniquepizza from CUSTOMER_ORDERS
 
Q3. How many successful orders were delivered by each runner?
 
select runner_id, COUNT(*) successfulorder from RUNNER_ORDERS where cancellation = ''
group by runner_id
 
Q4. How many of each type of pizza was delivered?
 
select pizza_name, count(RO.order_id) count_pýzza from RUNNER_ORDERS RO
INNER JOIN CUSTOMER_ORDERS co on co.order_id=RO.order_id
INNER JOIN PIZZA_NAMES PN ON PN.pizza_id=co.pizza_id
where cancellation = ''
GROUP BY pizza_name

Q5. How many Vegetarian and Meatlovers were ordered by each customer?
 
select*from CUSTOMER_ORDERS
select customer_id, pizza_name, count(*) from CUSTOMER_ORDERS CO
INNER JOIN PIZZA_NAMES PN ON PN.pizza_id=CO.pizza_id
GROUP BY pizza_name, customer_id

Q6. What was the maximum number of pizzas delivered in a single order?
 
select*from CUSTOMER_ORDERS
select top 1 order_id, COUNT(pizza_id) count_of from CUSTOMER_ORDERS
group by order_id
order by count_of desc
 
Q7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

select*from CUSTOMER_ORDERS
select*from RUNNER_ORDERS

select customer_id, 
SUM(CASE WHEN exclusions <> '0' OR extras <> '0' THEN 1 ELSE 0 END) AS with_change,
SUM(CASE WHEN exclusions = '0' AND extras = '0' THEN 1 ELSE 0 END) AS with_NO_change
FROM CUSTOMER_ORDERS CO
JOIN RUNNER_ORDERS RO ON RO.order_id=CO.order_id
WHERE cancellation = ''
group by customer_id

Q8. How many pizzas were delivered that had both exclusions and extras?

select count(RO.order_id) from RUNNER_ORDERS RO 
INNER JOIN CUSTOMER_ORDERS CO ON CO.order_id=ro.order_id
WHERE exclusions <> '0' and extras <> '0'AND  cancellation = ''

Q9. What was the total volume of pizzas ordered for each hour of the day?

SELECT*FROM CUSTOMER_ORDERS

SELECT DATEPART(HOUR, order_time) HOUR_, COUNT(pizza_id) TOTAL_PIZZA from CUSTOMER_ORDERS CO
GROUP BY DATEPART(HOUR, order_time)

Q10. What was the volume of orders for each day of the week?

SELECT DATENAME(WEEKDAY, order_time) DAY_, SUM(*) VOLUME_OF_PIZZA FROM CUSTOMER_ORDERS
GROUP BY DATENAME(WEEKDAY, order_time)
ORDER BY VOLUME_OF_PIZZA DESC


