use DairyFarm2





/**
-- Trying to find price of one serving of one animal of specific group based on the latest price or a specific date. (In our case group A) Also 
CREATE VIEW fgroup_details1 as
SELECT FoodGroup.group_name, IngredientData.item_id, IngredientData.weight
FROM FoodGroup 
INNER JOIN IngredientData 
ON (FoodGroup.ing_id=IngredientData.fgroup_id)
WHERE FoodGroup.group_name='A'


CREATE VIEW fgroup_details2 AS
SELECT Price.price, Price.item_id FROM Price
WHERE Price.item_id IN (SELECT item_id from fgroup_details1) AND Price.date_of_price = '6/14/2020'

CREATE VIEW price_calc AS
SELECT fgroup_details1.group_name, fgroup_details1.item_id, fgroup_details2.price, fgroup_details1.weight, 
fgroup_details1.weight * fgroup_details2.price AS total_price
FROM fgroup_details1
INNER JOIN fgroup_details2
ON (fgroup_details1.item_id = fgroup_details2.item_id)



SELECT * FROM fgroup_details1
SELECT * FROM fgroup_details2
SELECT * FROM price_calc
SELECT sum(total_price) AS per_serving_cost from price_calc GROUP BY group_name




**/

















-- 2- Report for showing total sales for meat and milk of one month, one day, one year and total data.


-- Report for all sales on a specific date, including meat and milk

CREATE VIEW Daily_Sales AS
SELECT * FROM Sales WHERE sales_date = '6/7/2020'

CREATE VIEW VIEW1 AS
SELECT Daily_Sales.id, Daily_Sales.production_id, Daily_Sales.quantity, Daily_Sales.sales_date, Production.type_id
FROM Daily_Sales
INNER JOIN Production
ON (Daily_Sales.production_id=Production.id)
SELECT * FROM VIEW1

CREATE VIEW VIEW2 AS
SELECT VIEW1.id, VIEW1.production_id, VIEW1.quantity, VIEW1.sales_date, ProductType.item_id, ProductType.name 
FROM VIEW1
INNER JOIN ProductType
ON (VIEW1.type_id=ProductType.id)

CREATE VIEW Price_View AS
SELECT Price.id as PriceID, Price.price, Price.date_of_price FROM Price
WHERE ((Price.item_id=16 OR Price.item_id=17)
AND (Price.date_of_price = '6/14/2020')) -- dates in Price table are not synchronized with sales table, otherwise this date will be equal to the date of sales or less but not after the sales date.
SELECT * FROM Price_View


CREATE VIEW VIEW3 AS
SELECT VIEW2.id,VIEW2.production_id,VIEW2.quantity,VIEW2.sales_date,VIEW2.item_id ,VIEW2.name, Price_View.price,
( VIEW2.quantity * Price_View.price ) AS total_sales FROM VIEW2
INNER JOIN Price_View
ON (VIEW2.item_id=Price_View.PriceID)





