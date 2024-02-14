select*from CUSTOMER_ORDERS
--update the customer_orders
UPDATE CUSTOMER_ORDERS
SET exclusions=0 where exclusions='' or exclusions='null'
UPDATE CUSTOMER_ORDERS
SET extras=0 where extras='' or extras='null' or extras='NaN'


--update the runner_orders
select*from RUNNER_ORDERS
UPDATE RUNNER_ORDERS
SET cancellation='' where cancellation='NaN' or cancellation='null'
UPDATE RUNNER_ORDERS
SET distance='' where distance='null'
UPDATE RUNNER_ORDERS
SET pickup_time='' where pickup_time='null'
UPDATE RUNNER_ORDERS
SET duration='' where duration='null'
UPDATE RUNNER_ORDERS
SET distance=TRIM('km' from distance) where distance LIKE '%km'
UPDATE RUNNER_ORDERS
SET duration=TRIM('minutes' from duration) where duration LIKE '%minutes%'
UPDATE RUNNER_ORDERS
SET duration=TRIM('mins' from duration) where duration LIKE '%mins%'
UPDATE RUNNER_ORDERS
SET duration=TRIM('minute' from duration) where duration LIKE '%minute%'

ALTER TABLE RUNNER_ORDERS
ALTER COLUMN pickup_time DATETIME2
ALTER TABLE RUNNER_ORDERS
ALTER COLUMN distance FLOAT
ALTER TABLE RUNNER_ORDERS
ALTER COLUMN duration INT

CREATE TABLE pizza_recipes_new (
   "pizza_id" INTEGER,
  "toppings" INTEGER
)
INSERT INTO pizza_recipes_new
("pizza_id", "toppings")
SELECT pizza_id, cast((LTRIM(RTRIM(toppings))) as int) as topping_id from (
select pizza_id, value as toppings
from PIZZA_RECIPES PR
	cross apply string_split(CONVERT(varchar(max),toppings), ',')) as TX

DROP TABLE PIZZA_RECIPES


CREATE TABLE EXTRA (order_id int, extra int)
INSERT INTO EXTRA		
SELECT * FROM (
SELECT order_id, value as extra FROM CUSTOMER_ORDERS
cross apply string_split(convert(varchar(max), extras), ',')) as asd
CREATE TABLE EXCLUTION (order_id int, exclution int)
INSERT INTO EXCLUTION		
SELECT * FROM (
SELECT order_id, value as exclution FROM CUSTOMER_ORDERS
cross apply string_split(convert(varchar(max), exclusions), ',')) as asd
