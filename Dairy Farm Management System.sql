create database DairyFarm
use DairyFarm

create table Unit(
	id VARCHAR(255) PRIMARY KEY,
	name varchar(255) NOT NULL
);

create table ItemID( -- all items in our inventory will have an ItemID
	id VARCHAR(255) PRIMARY KEY,
	name VARCHAR(255)
);

create table Price( --it will contain repeating entries based on date because we need to calculate daily profit report and the price might differ
	id VARCHAR(255) PRIMARY KEY,
	item_id VARCHAR(255) FOREIGN KEY REFERENCES ItemID(id), --will be entered manually while restocking the inventory. Price will be also entered at the same time
	price DECIMAL(10,2) NOT NULL,
	add_date DATE NOT NULL,
	unit_id VARCHAR(255) FOREIGN KEY REFERENCES Unit(id)
);

create table FoodGroup(
	id VARCHAR(255) NOT NULL,
	group_name varchar(255),
	ing_id VARCHAR(255) PRIMARY KEY
);

create table IngredientData(
	fgroup_id VARCHAR(255) FOREIGN KEY REFERENCES FoodGroup(ing_id),
	item_id VARCHAR(255) FOREIGN KEY REFERENCES ItemID(id),
	-- fetch name using item id from forage, supplements while using views to show data,
	weight DECIMAL(10,2) NOT NULL,
);

create table IsBought(
	id VARCHAR(255) PRIMARY KEY,
	price INT NOT NULL,
	currency VARCHAR(255) FOREIGN KEY REFERENCES Unit(id), -- it will be either Rs, $ etc,
	buying_date DATETIME NOT NULL,
);

create table Animal(
	tag VARCHAR(255) PRIMARY KEY,
	sex VARCHAR(255) CHECK (sex = 'M' OR sex = 'F'),
	color VARCHAR(255) NOT NULL,
	kind VARCHAR(255) NOT NULL,
	specie VARCHAR(255) CHECK (specie = 'Cow' OR specie = 'Buffalo' or specie = 'Sheep'),
	born_date DATE NOT NULL,
	calfing_Date DATE, --when it starts producing milk
	num_of_treatments INT DEFAULT(0),
	parent_tag VARCHAR(255), --it might be bought so it's not necessary if it was produced here
	is_bought VARCHAR(255) FOREIGN KEY REFERENCES IsBought(id), -- if not bought then NULL 
	food_group VARCHAR(255) NOT NULL,-- it doesn't 
);

create table ForageType(
	id VARCHAR(255) PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
);


create table Forage( -- How do we store the price of forage, because it might change on each purchase
	id INT IDENTITY(1,1),
	type_id VARCHAR(255) FOREIGN KEY REFERENCES ForageType(id),
	quantity INT NOT NULL,  -- every day it decreases but that is handled in front end.
	m_unit_id VARCHAR(255) FOREIGN KEY REFERENCES Unit(id),
	purchase_date DATE NOT NULL
);


create table SupplimentType(
	id VARCHAR(255) PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
);

create table Suppliment(
	id INT IDENTITY(1,1),
	type_id VARCHAR(255) FOREIGN KEY REFERENCES SupplimentType(id),
	quantity INT NOT NULL,
	m_unit_id VARCHAR(255) FOREIGN KEY REFERENCES Unit(id),
	purchase_date DATE NOT NULL
);

create table MedicineType(
	id VARCHAR(255) PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
);

create table Medicine(
	id INT IDENTITY(1,1),
	type_id VARCHAR(255) FOREIGN KEY REFERENCES MedicineType(id),
	quantity INT NOT NULL,
	m_unit_id VARCHAR(255) FOREIGN KEY REFERENCES Unit(id),
	purchase_date DATE NOT NULL
);


create table Treatment(
	/* Transactional Entity */
	id VARCHAR(255) PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	animal_tag VARCHAR(255) FOREIGN KEY REFERENCES Animal(tag) NOT NULL,
	med_id VARCHAR(255) FOREIGN KEY REFERENCES MedicineType(id) NOT NULL,
	date DATE NOT NULL,
);

create table Reproduction(
	/* Transactional Entity */
	id VARCHAR(255) PRIMARY KEY,
	animal_tag VARCHAR(255) FOREIGN KEY REFERENCES Animal(tag) NOT NULL,
	med_id VARCHAR(255) FOREIGN KEY REFERENCES MedicineType(id) NOT NULL,
	on_heat_date DATE NOT NULL, -- When animal reach the age of reproduction
	insemination_date DATE NOT NULL, 
	pregnancy_status VARCHAR(255) CHECK (pregnancy_status = 'YES' or pregnancy_status = 'NO'),
	delivery_date DATE NOT NULL,
	dry_date DATE NOT NULL, -- When animal stop producing milk (usually after 7 months of calfing date)
);


-- We can calculate buying and using expense using ExpenseType i.e either bought or used.
-- We have date, item_id, quantity in Expenses so we can calculate wrt date, and type.
create table ExpenseType(
	type_id VARCHAR(255) PRIMARY KEY,
	name VARCHAR(255) -- can be buying, treatment, we'll buy or use forage
);

create table Expenses(
	/* Transactional Entity */
	id VARCHAR(255) PRIMARY KEY,
	type_id VARCHAR(255) FOREIGN KEY REFERENCES ExpenseType(type_id),
	quantity INT NOT NULL,
	item_used_id VARCHAR(255) FOREIGN KEY REFERENCES ItemID(id) /* Entered Manually */,
	date DATE NOT NULL,
	miscellanous_costs INT NOT NULL, -- doctor's fee or any other fees related to treatment
	remarks TEXT,
	/* we can get both price and unit from Price table via item_used_id */
);

create table ProductType(
	id VARCHAR(255) PRIMARY KEY,
	name VARCHAR(255) NOT NULL CHECK(name = 'Milk' OR name = 'Meat')
);

create table Production(
	/* MILK ID will be presumably fixed because it has a single instance */
	id INT IDENTITY(1,1),
	animal_tag VARCHAR(255) FOREIGN KEY REFERENCES Animal(tag),
	type_id VARCHAR(255) FOREIGN KEY REFERENCES ProductType(id), -- only specified types will be added
	quantity INT NOT NULL,
	unit_id VARCHAR(255) FOREIGN KEY REFERENCES Unit(id) NOT NULL, -- so that we can 
	operation_date DATE, -- operation_date because we can track both milk and meat production without creating two dates.
);

create table Sales(
	/* Transactional Entity */
	id VARCHAR(255) PRIMARY KEY,
	item_type VARCHAR(255) FOREIGN KEY REFERENCES ProductType(id),
	quantity DECIMAL(10, 2) NOT NULL,
	unit VARCHAR(255) FOREIGN KEY REFERENCES Unit(id),
	rate VARCHAR(255) FOREIGN KEY REFERENCES Price(id)
);