select
CONVERT(date,week_date,3) week_date ,
DATEPART(WEEK,CONVERT(date,week_date,3)) week_number ,
DATEPART(MONTH,CONVERT(date,week_date,3)) month_number ,
DATEPART(YEAR,CONVERT(date,week_date,3)) calendar_year ,
region,
platform,
segment,
CASE WHEN RIGHT(segment,1) = '1' THEN 'Young Adults'
	 WHEN RIGHT(segment,1) = '2' THEN 'Middle Aged'
	 WHEN RIGHT(segment,1) IN('3','4') THEN 'Retirees'
	 ELSE 'unknown'
	 END AS age_band,
CASE WHEN LEFT(segment,1) = 'C' THEN 'Couples'
	 WHEN LEFT(segment,1) = 'F' THEN 'Families'
	 ELSE 'unknown'
	 END AS demographic,
customer_type,
transactions,
CAST(sales AS bigint) AS sales,
ROUND(CAST(sales AS FLOAT)/transactions, 2) AS avg_transaction
INTO current_weekly_sales
from [dbo].[WEEKLY_SALES]