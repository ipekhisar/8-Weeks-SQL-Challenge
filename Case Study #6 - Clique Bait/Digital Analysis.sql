--Digital Analysis

--1.How many users are there?

SELECT COUNT(DISTINCT[user_id]) AS #ofcustomer FROM [dbo].[users]

--2.How many cookies does each user have on average?

SELECT * FROM users

WITH CTE AS (SELECT [user_id], COUNT([cookie_id]) AS countofcookie
FROM users 
GROUP BY [user_id])

SELECT AVG(countofcookie) FROM CTE

--3.What is the unique number of visits by all users per month?

SELECT DATEPART(MONTH,event_time) month, COUNT(DISTINCT visit_id) visit FROM [dbo].[events]
GROUP BY DATEPART(MONTH,event_time)
ORDER BY 1

--4.What is the number of events for each event type?

SELECT event_type, COUNT(visit_id) FROM events
GROUP BY event_type
ORDER BY 1

--5.What is the percentage of visits which have a purchase event?

SELECT 
100.00*SUM(CASE WHEN event_name = 'Purchase' THEN 1 END)/ COUNT(DISTINCT visit_id)
FROM events E
INNER JOIN event_identifier EI ON EI.event_type=E.event_type

--6.What is the percentage of visits which view the checkout page but do not have a purchase event?

WITH CTE AS (SELECT 
SUM (CASE WHEN page_id=12 AND event_type != 3 THEN 1 ELSE 0 END) as checkout,
SUM (CASE WHEN event_type=3 THEN 1 ELSE 0 END) as total_purchase
FROM events 
)
SELECT checkout, total_purchase, 
100-CAST(100*total_purchase/checkout AS decimal(5,2)) FROM CTE

--7.What are the top 3 pages by number of views?

SELECT TOP 3  page_id, COUNT(visit_id) countofvisit FROM events
GROUP BY page_id
ORDER BY countofvisit desc

--8.What is the number of views and cart adds for each product category?

SELECT product_category as category_names,
SUM(CASE WHEN event_type='1' THEN 1 ELSE 0 END) page_view,
SUM(CASE WHEN event_type='2' THEN 1 ELSE 0 END) add_cart
FROM events E
INNER JOIN page_hierarchy PH ON PH.page_id=E.page_id
WHERE product_category != 'NULL'
GROUP BY product_category
