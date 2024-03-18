--Data Exploration

--1.What day of the week is used for each week_date value?

select DISTINCT
DATENAME(weekday, week_date) day_
from [dbo].[current_weekly_sales]

--2.What range of week numbers are missing from the dataset?


--3.How many total transactions were there for each year in the dataset?

select
calendar_year,
SUM(transactions) total_transaction
from [dbo].[current_weekly_sales]
GROUP BY [calendar_year]
ORDER BY [calendar_year] 

--4.What is the total sales for each region for each month?

select
[region],[month_number], SUM([sales]) total_sales
from [dbo].[current_weekly_sales]
GROUP BY [region], [month_number]
ORDER BY [region], [month_number]

--5.What is the total count of transactions for each platform?

SELECT
[platform], SUM([transactions]) total_cout_txn
FROM [dbo].[current_weekly_sales]
GROUP BY [platform]

--6.What is the percentage of sales for Retail vs Shopify for each month?

WITH CTE AS (
SELECT 
[calendar_year],[month_number], [platform], sum([sales]) as monthly_sales
FROM [dbo].[current_weekly_sales]
GROUP BY [calendar_year],[month_number], [platform] 
)
SELECT [calendar_year], [month_number],
CAST(100.00*SUM(CASE WHEN [platform]='Retail' THEN monthly_Sales END)/ SUM(monthly_sales) AS decimal(5,2)) AS RETAIL,
CAST(100.00*SUM(CASE WHEN [platform]='Shopify' THEN monthly_Sales END)/ SUM(monthly_sales) AS decimal(5,2)) AS SHOPIFY
FROM CTE
GROUP BY [calendar_year], [month_number]

--7.What is the percentage of sales by demographic for each year in the dataset?

WITH CTE AS (
SELECT 
[calendar_year], [demographic], sum([sales]) as yearly_sales
FROM [dbo].[current_weekly_sales]
GROUP BY [calendar_year],[demographic]
)
SELECT [calendar_year], 
CAST(100.00*SUM(CASE WHEN [demographic]='Couples' THEN yearly_Sales END)/ SUM(yearly_sales) AS decimal(5,2)) AS COUPLE,
CAST(100.00*SUM(CASE WHEN [demographic]='Families' THEN yearly_Sales END)/ SUM(yearly_sales) AS decimal(5,2)) AS FAMILIES,
CAST(100.00*SUM(CASE WHEN [demographic]='unknown' THEN yearly_Sales END)/ SUM(yearly_sales) AS decimal(5,2)) AS UNKNOWN
FROM CTE
GROUP BY [calendar_year]

--8.Which age_band and demographic values contribute the most to Retail sales?

select*from [dbo].[current_weekly_sales]

DECLARE @retailsales AS BIGINT
SET @retailsales=(SELECT SUM(sales) FROM [dbo].[current_weekly_sales] WHERE [platform]= 'Retail')

select [age_band], [demographic], 
SUM([sales]) as Retail_sales,
CAST(100.00*SUM([sales])/@retailsales as decimal(5,2)) as CONT
from [dbo].[current_weekly_sales] 
WHERE [platform]= 'Retail'
GROUP BY [age_band], [demographic]

--9.Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

SELECT [calendar_year], [platform], 
AVG(avg_transaction) avg_transaction_row,
SUM(sales)/SUM(transactions) measure_grup FROM [dbo].[current_weekly_sales] 
GROUP BY [calendar_year], [platform]

