--3. Before & After Analysis

--1.What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?

SELECT*FROM [dbo].[current_weekly_sales]

DECLARE @wknumber AS int
SET @wknumber=(
SELECT DISTINCT week_number FROM [dbo].[current_weekly_sales]
WHERE week_date='2020-06-15')

;WITH CTE (before_date, after_date) AS
(
SELECT 
SUM(CASE WHEN week_number BETWEEN @wknumber-4 AND @wknumber-1 THEN SALES END) before_date,
SUM(CASE WHEN week_number BETWEEN @wknumber AND @wknumber+3 THEN SALES END) after_date
FROM [dbo].[current_weekly_sales]
WHERE calendar_year='2020'
)

SELECT before_date, after_date, 
CAST(100.00*(after_date-before_date)/before_date AS decimal(5,2)) AS perc
FROM CTE

--2.What about the entire 12 weeks before and after?

DECLARE @wknumber AS int
SET @wknumber=(
SELECT DISTINCT week_number FROM [dbo].[current_weekly_sales]
WHERE week_date='2020-06-15')

;WITH CTE (before_date, after_date) AS
(
SELECT 
SUM(CASE WHEN week_number BETWEEN @wknumber-12 AND @wknumber-1 THEN SALES END) before_date,
SUM(CASE WHEN week_number BETWEEN @wknumber AND @wknumber+11 THEN SALES END) after_date
FROM [dbo].[current_weekly_sales]
WHERE calendar_year='2020'
)

SELECT before_date, after_date, 
CAST(100.00*(after_date-before_date)/before_date AS decimal(5,2)) AS perc
FROM CTE

--3.How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

DECLARE @wknumber AS int
SET @wknumber=(
SELECT DISTINCT week_number FROM [dbo].[current_weekly_sales]
WHERE week_date='2020-06-15')

;WITH CTE (calendar_year, before_date, after_date) AS
(
SELECT calendar_year,
SUM(CASE WHEN week_number BETWEEN @wknumber-3 AND @wknumber-1 THEN SALES END) before_date,
SUM(CASE WHEN week_number BETWEEN @wknumber AND @wknumber+3 THEN SALES END) after_date
FROM [dbo].[current_weekly_sales]
GROUP BY calendar_year
)

SELECT calendar_year, before_date, after_date, 
CAST(100.00*(after_date-before_date)/before_date AS decimal(5,2)) AS perc
FROM CTE
