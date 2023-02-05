CREATE VIEW ExpenseTreatment AS

Select Treatment.animal_tag AS AnimalTag, Treatment.date, MedicineType.name AS Medicine,
price.price AS PerUnitMedicineCost, Treatment.used_med_quantity as med_quantity,
(Treatment.used_med_quantity * price.price) AS TotalCo

FROM ((Treatment 
INNER JOIN MedicineType ON Treatment.med_id = MedicineType.id)
INNER JOIN Price ON MedicineType.item_id = price.item_id)
WHERE price.date_of_price = (SELECT MAX(price.date_of_price) FROM Price WHERE Price.item_id = MedicineType.item_id AND price.date_of_price<Treatment.date)




drop view ExpenseTreatment


-- Calculate Per Serving Cost of Forage of One Animal wrt FoodGroup
SELECT sum(total_price) AS per_serving_cost FROM price_calc GROUP BY group_name


GO;





-- No of Animals in a FoodGroup
CREATE VIEW Animals_in_Groups AS
	SELECT Animal.food_group AS FoodGroup, count(tag) AS number FROM Animal WHERE Animal.dying_date IS NULL GROUP BY Animal.food_group

GO;

SELECT * from Animals_in_Groups



-- Procedure to show bought Animal with Desending Buying Date
CREATE PROCEDURE Bought_Animals AS 
	BEGIN
	SELECT IsBought.buying_date AS BuyingDate, Animal.tag AS TagNo, IsBought.price AS Price, Unit.name
	FROM ((Animal INNER JOIN IsBought ON Animal.is_bought = IsBought.id) 
	INNER JOIN Unit ON IsBought.currency = Unit.id)
	WHERE Animal.is_bought IS NOT NULL ORDER BY BuyingDate DESC
	END;
GO;





EXEC Bought_Animals



-- Show all the Children of a Specific Animal
CREATE PROCEDURE No_of_Children @parentTag VARCHAR (255) AS
	BEGIN
	SELECT * from Animal WHERE parent_tag = @parentTag
	SELECT @@ROWCOUNT AS Total_Children
	END;
GO;
EXEC No_of_Children 'a2'



-- Show All Animals which are Born here
CREATE PROCEDURE Born_Animal AS
	BEGIN
	SELECT * from Animal WHERE parent_tag IS NOT NULL ORDER BY born_date DESC
	SELECT @@ROWCOUNT AS Total_Born_Animal
	END;
GO;
EXEC Born_Animal


-- Show All Alive Animal
CREATE PROCEDURE Alive_Animal AS
	BEGIN
	SELECT * from Animal WHERE dying_date IS NULL ORDER BY born_date DESC
	SELECT @@ROWCOUNT AS Total_Alive_Animal
	END;
GO;
EXEC Alive_Animal



-- Show All Dead Animal
CREATE PROCEDURE Dead_Animal AS
	BEGIN
	SELECT * from Animal WHERE dying_date IS NOT NULL ORDER BY dying_date DESC
	SELECT @@ROWCOUNT AS Total_Dead_Animal
	END;
GO;
EXEC Dead_Animal




-- Calculate total count of a specific specie, kind and avg age in days
CREATE PROCEDURE Animal_Specie_Breed_Age AS
	BEGIN
	SELECT Animal.specie AS Specie, Animal.kind AS Breed, count(tag) AS Total_Count, AVG(DATEDIFF(day,Animal.born_date,GETDATE())) AS Avg_Age_in_Days
	from Animal GROUP BY Animal.specie, Animal.kind ORDER BY Animal.specie
	END;
GO;
EXEC Animal_Specie_Breed_Age




drop function 
-- Calculate Total Serving Cost on a Specific Date
CREATE FUNCTION FoodGroupCost (@date date) RETURNS TABLE AS
	RETURN(
	SELECT FoodGroup.group_name, IngredientData.item_id, IngredientData.weight, Price.price, price.date_of_price,(IngredientData.weight * Price.price) AS TotalCost
	FROM ((FoodGroup
	INNER JOIN IngredientData 
	ON FoodGroup.ing_id=IngredientData.fgroup_id)
	INNER JOIN Price ON Price.item_id = IngredientData.item_id) 
	WHERE Price.date_of_price = (SELECT MAX(price.date_of_price) FROM Price WHERE Price.item_id = IngredientData.item_id AND price.date_of_price <= @date)
	)



-- Calculate Total Serving Cost on a Specific Date
drop procedure FoodGroupCost_OneDay
CREATE PROCEDURE FoodGroupCost_OneDay @GivenDate date AS
	BEGIN
	SELECT group_name AS FoodGroup, sum(TotalCost) AS TotalServingCost FROM FoodGroupCost(@GivenDate) GROUP BY group_name
	END
GO;

EXEC FoodGroupCost_OneDay '6/15/2020'




-- Calculate total serving cost of one food group
drop function FoodCost
CREATE FUNCTION FoodCost(@StartDate date,@EndDate date, @FoodGroup VARCHAR (255)) RETURNS 
	
	@FCost TABLE(
		Date date, FoodGroup VARCHAR(255), Cost DECIMAL (10,2)
	) AS
	BEGIN 
	DECLARE @Cost DECIMAL (10,2)


		WHILE (@StartDate <= @EndDate)
		BEGIN

			SELECT @Cost = sum(TotalCost) FROM FoodGroupCost(@StartDate) WHERE group_name = @FoodGroup;

			INSERT INTO @FCost VALUES (@StartDate,@FoodGroup,@Cost)

			SET @StartDate = DATEADD(DAY, 1, @StartDate);

		END

	RETURN
	END




-- Calculate total serving cost of all food groups between given dates

CREATE FUNCTION FoodCost_Groups(@STARTDATE date, @ENDDATE date) RETURNS TABLE AS RETURN(
	SELECT * FROM FoodCost(@STARTDATE,@ENDDATE, 'A')
	UNION ALL
	SELECT * FROM FoodCost(@STARTDATE,@ENDDATE, 'B')
	UNION ALL
	SELECT * FROM FoodCost(@STARTDATE,@ENDDATE, 'C')
	)




-- Calculate total serving cost of all food groups between given dates
CREATE PROCEDURE FoodCost_BetweenDates @STARTDATE date, @ENDDATE date AS 

	BEGIN
	Select (SELECT number from Animals_in_Groups where FoodGroup = 'G1') AS No_of_Animals, 
	(SELECT number from Animals_in_Groups where FoodGroup = 'G1') * sum(Cost) AS Total_Serving_Cost 
	from FoodCost_Groups(@STARTDATE, @ENDDATE) WHERE FoodGroup = 'A'
	UNION ALL 
	Select (SELECT number from Animals_in_Groups where FoodGroup = 'G2') AS No_of_Animals, 
	(SELECT number from Animals_in_Groups where FoodGroup = 'G2') * sum(Cost) AS Total_Serving_Cost 
	from FoodCost_Groups(@STARTDATE, @ENDDATE) WHERE FoodGroup = 'B'
	UNION ALL 
	Select (SELECT number from Animals_in_Groups where FoodGroup = 'G3') AS No_of_Animals, 
	(SELECT number from Animals_in_Groups where FoodGroup = 'G3') * sum(Cost) AS Total_Serving_Cost 
	from FoodCost_Groups(@STARTDATE, @ENDDATE) WHERE FoodGroup = 'C'
	END

EXEC FoodCost_BetweenDates '05/01/2020','06/29/2020'

GO;






-- Treatment Expenses
CREATE PROCEDURE Treatment_Expense AS
BEGIN
Select Treatment.animal_tag AS AnimalTag, Treatment.date, MedicineType.name AS Medicine,
price.price AS PerUnitMedicineCost, Treatment.used_med_quantity as med_quantity,
(Treatment.used_med_quantity * price.price) AS TotalCo

FROM ((Treatment 
INNER JOIN MedicineType ON Treatment.med_id = MedicineType.id)
INNER JOIN Price ON MedicineType.item_id = price.item_id)
WHERE price.date_of_price = (SELECT MAX(price.date_of_price) FROM Price WHERE Price.item_id = MedicineType.item_id AND price.date_of_price<Treatment.date)

END

EXEC Treatment_Expense

GO;


-- Calculate Cost of Each Treatment of a given Animal
CREATE PROCEDURE Single_Animal_Treatment @tag VARCHAR (255) AS 
BEGIN
select * FROM ExpenseTreatment WHERE AnimalTag = @tag
END

EXEC Single_Animal_Treatment 'a9'


GO;

-- Calculate Total Cost All Treatments of Each Animal
CREATE PROCEDURE Total_TreatmentCost_Separately AS
BEGIN
SELECT AnimalTag, sum(TotalCo) AS TotalTreatmentCost FROM ExpenseTreatment GROUP BY AnimalTag
END

EXEC Total_TreatmentCost_Separately

GO;


drop procedure Treatments_Datewise
-- Calculate Total Cost All Treatments of All Animals between Given Dates
CREATE PROCEDURE Treatments_Datewise @STARTDATE date, @ENDDATE date AS
BEGIN
select Date,sum(TotalCo) AS TreatmentCost FROM ExpenseTreatment
WHERE Date BETWEEN @STARTDATE AND  @ENDDATE  GROUP BY Date


END

EXEC Treatments_Datewise '2021/06/01', '2022/06/19'

GO;





-- Reproduction Expense
CREATE VIEW reproductionExpense AS
SELECT rep.animal_tag AS Animal,
medt.name AS Medicine_Used,
rep.insemination_date AS Insemination_Date,
rep.used_med_amount AS Medicine_Qty,
p.price AS Medicine_Price,
rep.used_med_amount * p.price AS Cost
FROM Reproduction rep INNER JOIN MedicineType medt ON (rep.med_id = medt.id)
INNER JOIN Price p ON (p.item_id = medt.item_id AND p.date_of_price = (SELECT MAX(date_of_price) FROM PRICE))

SELECT * FROM reproductionExpense



-- Calculate Reproduction Expense Datewise
CREATE PROCEDURE Repro_Expense_Datewise @STARTDATE date, @ENDDATE date AS
	BEGIN
	SELECT Insemination_Date, SUM(Cost) AS "Total Cost" FROM reproductionExpense 
	WHERE  Insemination_Date BETWEEN @STARTDATE AND  @ENDDATE GROUP BY Insemination_Date

	END

EXEC Repro_Expense_Datewise '01/01/2016','06/20/2022'




-- Calculate All Expenses
drop procedure Calc_Expense
CREATE PROCEDURE Calc_Expense @STARTDATE date, @ENDDATE date AS 

BEGIN
DECLARE @F TABLE (No_of_Animal INT, Total_SERVING_Cost DECIMAL(10,2))
insert @F EXEC FoodCost_BetweenDates @STARTDATE,@ENDDATE

DECLARE @T TABLE (DATE date, TreatmentCost DECIMAL (10,2))
INSERT @T EXEC Treatments_Datewise @STARTDATE,@ENDDATE


DECLARE @R TABLE (DATE date, ReproCost DECIMAL (10,2))
INSERT @R EXEC Repro_Expense_Datewise  @STARTDATE,@ENDDATE

DECLARE @food_expense DECIMAL(10,2)
DECLARE @treatment_expense DECIMAL(10,2)
DECLARE @reproduction_expense DECIMAL(10,2)
DECLARE @total_expenses DECIMAL(10,2)
DECLARE @total_sales DECIMAL(10,2)


SET @food_expense = (SELECT SUM(Total_Serving_Cost) AS Total_Expense FROM @F)
SET @treatment_expense = (SELECT SUM(TreatmentCost) FROM @T)
SET @reproduction_expense = (SELECT SUM(ReproCost) FROM @R)
SET @total_expenses = (SELECT @food_expense + @treatment_expense + @reproduction_expense)
SET @total_sales = (SELECT SUM(revenue) FROM get_sales_range(@STARTDATE, @ENDDATE))

SELECT @total_sales - @total_expenses as Profit, @total_expenses as total_expenses, @total_sales as total_Sales
SELECT SUM(Total_Serving_Cost) AS Total_Expense FROM @F
UNION ALL
SELECT SUM(TreatmentCost) FROM @T
UNION ALL
SELECT SUM(ReproCost) FROM @R




END

EXEC Calc_Expense '01/01/2016','06/20/2022'


CREATE VIEW Total_Sales AS
	SELECT Sales.sales_date, Sales.id, Sales.quantity, Price.price,Price.date_of_price, Price.price * Sales.quantity AS revenue 
		FROM Sales
		INNER JOIN Production ON Sales.production_id = Production.id
		INNER JOIN ProductType ON Production.type_id = ProductType.id
		INNER JOIN Price ON ProductType.item_id = Price.item_id 
		WHERE price.date_of_price = (SELECT MAX(price.date_of_price) FROM Price WHERE Price.date_of_price <= Sales.sales_date)
		

	CREATE FUNCTION get_sales_range(@start_date DATE, @end_date DATE) RETURNS TABLE AS
	RETURN
		SELECT * FROM Total_Sales WHERE Total_Sales.sales_date BETWEEN @start_date and @end_date






/* TRIGGER ON REPRODUCTION THAT WILL FIRE WHEN INSEMINATION DATE IS ADDED TO A ANIMAL */
CREATE PROCEDURE addAnimalToReproduction (@animal_tag VARCHAR(255)) AS
BEGIN
	INSERT INTO Reproduction (animal_tag, med_id, used_med_amount, on_heat_date, insemination_date, dry_date)
	VALUES (@animal_tag, 3, 25.25, '8/2/2016', '8/12/2016', '2/15/2017')
END

SELECT * FROM Animal
SELECT * FROM Reproduction

EXEC addAnimalToReproduction 'a15'

CREATE TRIGGER changePregnancyStatus ON Reproduction AFTER INSERT
AS
	IF (UPDATE (insemination_date))
		BEGIN
			
			UPDATE Reproduction SET pregnancy_status = 'YES' WHERE animal_tag = (SELECT animal_tag FROM inserted)
		END







