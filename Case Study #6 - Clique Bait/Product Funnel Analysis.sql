select*from [dbo].[campaign_identifier]
select*from [dbo].[event_identifier]
select*from [dbo].[events]
select*from [dbo].[page_hierarchy]
select*from [dbo].[users]

WITH CTE AS (
SELECT visit_id, product_id, page_name as Product_name, product_category,
SUM(CASE WHEN event_type=1 THEN 1 ELSE 0 END) as countofpageview,
SUM(CASE WHEN event_type=2 THEN 1 ELSE 0 END) as countofaddtocart
FROM events E
INNER JOIN page_hierarchy PH ON PH.page_id=E.page_id
WHERE product_id IS NOT NULL
GROUP BY visit_id, product_id, page_name, product_category
)
,
CTE2 AS (
SELECT visit_id FROM events
WHERE event_type=3)
,
Combine AS (SELECT ppe.visit_id, product_id, product_name, product_category, countofpageview, countofaddtocart,
CASE WHEN pe.visit_id IS NOT NULL THEN 1 ELSE 0 END AS purchase 
FROM CTE AS ppe
LEFT JOIN CTE2 pe
ON ppe.visit_id = pe.visit_id
)
,
CTE4 AS ( 
SELECT product_name, product_category, 
SUM(countofpageview) view_,
SUM(countofaddtocart) addcart,
SUM(CASE WHEN countofaddtocart=1 AND purchase=0 THEN 1 ELSE 0 END) abandone,
SUM(CASE WHEN countofaddtocart=1 AND purchase=1 THEN 1 ELSE 0 END) purchases
FROM combine
GROUP BY product_name, product_category
)

SELECT * FROM CTE4
