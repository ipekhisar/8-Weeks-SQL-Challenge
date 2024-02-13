# 8-Week SQL Challenge

## Case Study #1 - Danny's Diner

### Problem Statement

Danny wants to some data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. 

Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.
He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - 
additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.

### Dataset
Danny has shared with you 3 key datasets for this case study:

-sales

-menu

-members

### Case Study Questions

1. What is the total amount each customer spent at the restaurant?

2. How many days has each customer visited the restaurant?

3. What was the first item from the menu purchased by each customer?

4. What is the most purchased item on the menu and how many times was it purchased by all customers?

5. Which item was the most popular for each customer?

6. Which item was purchased first by the customer after they became a member?

7. Which item was purchased just before the customer became a member?

8. What is the total items and amount spent for each member before they became a member?

9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

### Solutions

Q1. What is the total amount each customer spent at the restaurant?
```sql
SELECT CUSTOMER_ID, SUM(PRICE) TOTAL_AMOUNT FROM SALES S
INNER JOIN MENU M ON M.PRODUCT_ID=S.PRODUCT_ID
GROUP BY CUSTOMER_ID
```
| CUSTOMER_ID | TOTAL_AMOUNT |
|-------------|--------------|
|A|76|
|B|74|
|C|36|

Q2. How many days has each customer visited the restaurant?
```sql
SELECT CUSTOMER_ID, COUNT(DISTINCT ORDER_DATE) VISITING_DAY FROM SALES
GROUP BY CUSTOMER_ID
```
| CUSTOMER_ID | VISITING_DAY |
|-------------|--------------|
|A|4|
|B|6|
|C|2|


Q3. What was the first item from the menu purchased by each customer?
```sql
WITH TABLE_ AS (
select CUSTOMER_ID, S.PRODUCT_ID, ORDER_dATE, ROW_NUMBER() OVER (PARTITION BY CUSTOMER_ID ORDER BY ORDER_dATE) AS ROW_NO from SALES S
JOIN MENU M ON M.PRODUCT_ID=S.PRODUCT_ID
)
SELECT CUSTOMER_ID, PRODUCT_ID, ORDER_DATE FROM TABLE_
WHERE ROW_NO=1
```
| CUSTOMER_ID | PRODUCT_ID | ORDER_DATE
|-------------|------------|-----------
|A|1|2021-01-01
|B|2|2021-01-01
|C|3|2021-01-01

Q4. What is the most purchased item on the menu and how many times was it purchased by all customers?

```sql
SELECT TOP 1 S.PRODUCT_ID, PRODUCT_NAME, COUNT(*) COUNT_PURCHASED FROM SALES S
JOIN MENU M ON M.PRODUCT_ID=S.PRODUCT_ID
GROUP BY S.PRODUCT_ID, PRODUCT_NAME
ORDER BY COUNT(*) DESC
```
| PRODUCT_ID | PRODUCT_NAME | COUNT_PURCHASED
|-------------|------------|-----------
|3|ramen|8

Q5. Which item was the most popular for each customer?
```sql
WITH TABLE_ AS(
SELECT CUSTOMER_ID, PRODUCT_ID, COUNT(PRODUCT_ID) COUNT_PRODUCT, ROW_NUMBER() OVER (PARTITION BY CUSTOMER_ID ORDER BY COUNT(PRODUCT_ID) DESC) AS ROW_ FROM SALES
GROUP BY CUSTOMER_ID, PRODUCT_ID)
SELECT CUSTOMER_ID, PRODUCT_ID AS POPULAR_PRODUCT FROM TABLE_
WHERE ROW_=1
```
| CUSTOMER_ID | POPULAR_PRODUCT
|-------------|------------|
|A|3|
|B|1|
|C|3|

Q6. Which item was purchased first by the customer after they became a member?
```sql
WITH TABLE_ AS(
SELECT S.CUSTOMER_ID,  S.PRODUCT_ID,PRODUCT_NAME , ORDER_DATE, JOIN_DATE, ROW_NUMBER() OVER (PARTITION BY S.CUSTOMER_ID ORDER BY ORDER_dATE) AS ROWS_ FROM SALES S
FULL JOIN MEMBERS M ON M.CUSTOMER_ID=S.CUSTOMER_ID
JOIN MENU MN ON MN.PRODUCT_ID=S.PRODUCT_ID
WHERE JOIN_DATE<=ORDER_DATE
)
SELECT CUSTOMER_ID, PRODUCT_NAME, ORDER_DATE  FROM TABLE_
WHERE ROWS_ =1
```
| CUSTOMER_ID | PRODUCT_NAME | ORDER_DATE
|-------------|------------|-----------
|A|curry|2021-01-07
|B|sushi|2021-01-11

Q7. Which item was purchased just before the customer became a member?
```sql
WITH TABLE_ AS(
SELECT S.CUSTOMER_ID,S.PRODUCT_ID, PRODUCT_NAME, ORDER_DATE, JOIN_DATE, ROW_NUMBER() OVER (PARTITION BY S.CUSTOMER_ID ORDER BY ORDER_dATE DESC) AS ROWS_ FROM SALES S
FULL JOIN MEMBERS M ON M.CUSTOMER_ID=S.CUSTOMER_ID
FULL JOIN MENU MN ON MN.PRODUCT_ID=S.PRODUCT_ID
WHERE JOIN_DATE>ORDER_DATE
)
SELECT CUSTOMER_ID, PRODUCT_ID, PRODUCT_NAME, ORDER_DATE FROM TABLE_
WHERE ROWS_ =1
```
| CUSTOMER_ID |PRODUCT_ID | PRODUCT_NAME | ORDER_DATE
|-------------|------------|-----------|------
|A|1|sushi|2021-01-01
|B|1|sushi|2021-01-04

Q8. What is the total items and amount spent for each member before they became a member?
```sql
WITH TABLE_ AS(
SELECT S.CUSTOMER_ID AS CUST_ID,S.PRODUCT_ID, PRODUCT_NAME, JOIN_DATE, PRICE FROM SALES S
FULL JOIN MEMBERS M ON M.CUSTOMER_ID=S.CUSTOMER_ID
FULL JOIN MENU MN ON MN.PRODUCT_ID=S.PRODUCT_ID
WHERE JOIN_DATE>ORDER_DATE
)
SELECT CUST_ID, COUNT(PRODUCT_ID) TOTAL_ITEMS, SUM(PRICE) SUM_PRICE FROM TABLE_
GROUP BY CUST_ID
```
| CUSTOMER_ID | TOTAL_ITEMS | SUM_PRICE
|-------------|------------|-----------
|A|2|25
|B|3|40

Q9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

```sql
SELECT CUSTOMER_ID, SUM 
(CASE
WHEN PRODUCT_NAME='sushi' THEN (PRICE*10*2)
ELSE (PRICE*10)
END) AS POINT 
FROM SALES S
JOIN MENU MN ON MN.PRODUCT_ID=S.PRODUCT_ID
GROUP BY CUSTOMER_ID
```
| CUSTOMER_ID | POINT 
|-------------|------------
|A|860
|B|940
|C|360

Q10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?


### BONUS QUESTION

Join All The Things
The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.
Recreate the following table output using the available data.

```sql
WITH TABLE_1 AS (
SELECT S.CUSTOMER_ID, ORDER_DATE, PRODUCT_NAME, PRICE, JOIN_DATE,
(CASE 
WHEN JOIN_DATE <= ORDER_DATE THEN 'Y'
ELSE 'N'
END) AS MEMBER_
FROM SALES S
FULL JOIN MEMBERS ME ON ME.CUSTOMER_ID=S.CUSTOMER_ID
INNER JOIN MENU MN ON MN.PRODUCT_ID=S.PRODUCT_ID
)

SELECT CUSTOMER_ID, ORDER_DATE, PRODUCT_NAME, PRICE, MEMBER_,
(CASE
WHEN MEMBER_='N' THEN NULL
ELSE RANK() OVER (PARTITION BY CUSTOMER_ID, MEMBER_ ORDER BY ORDER_DATE)
END) AS RANKING
FROM TABLE_1
```
| CUSTOMER_ID | ORDER_DATE | PRODUCT_NAME | PRICE | MEMBER_ | RANKING |
|-------------|------------|--------------|-------|---------|---------|
|A|	2021-01-01|	sushi|	10|	N	|NULL
|A|	2021-01-01|	curry|	15|	N|	NULL
|A|	2021-01-07|	curry|	15|	Y|	1
|A|	2021-01-10|	ramen|	12|	Y|	2
|A|	2021-01-11|	ramen|	12|	Y|	3
|A|	2021-01-11|	ramen|	12|	Y|	3
|B|	2021-01-01|	curry|	15|	N|	NULL
|B|	2021-01-02|	curry|	15|	N|	NULL
|B|	2021-01-04|	sushi|	10|	N|	NULL
|B|	2021-01-11|	sushi|	10|	Y|	1
|B|	2021-01-16|	ramen|	12|	Y|	2
|B|	2021-02-01|	ramen|	12|	Y|	3
|C|	2021-01-01|	ramen|	12|	N|	NULL
|C| 2021-01-01|	ramen|	12|	N|	NULL
|C|	2021-01-07|	ramen|	12|	N|	NULL
