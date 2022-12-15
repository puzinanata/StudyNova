#Preparation step DROP DB
DROP DATABASE getpresent;
#1 Step. Create DB
CREATE DATABASE getpresent;
#2. Select new DB
USE getpresent;
#3. Create DB tables

-- CUSTOMER--
create table if not exists `CUSTOMER` (
	`customer_ID` integer unsigned auto_increment not null,
    `customer_name` varchar(100) default null,
    `country_code_phone` varchar(3) default null,
    `phone_number` varchar(10) default null,
    `email_address` varchar(50) not null,
    `invoice_address` varchar(100) default null,
    `loyalty_programm` tinyint unsigned default null,
     `discount_rate` decimal(4,2) not null,
    primary key (`customer_ID`)
);

-- SUPPLIER--
create table if not exists `SUPPLIER` (
	`supplier_ID` integer unsigned auto_increment not null,
    `supplier_category` tinyint default null,
    `supplier_name` varchar(100) default null,
    `country_code_phone` varchar(3) default null,
    `phone_number` varchar(10) default null,
    `email_address` varchar(50) not null,
    `registered_address` varchar(100) default null,
    `discount_rate` decimal(4,2) not null,
    `invoice_tax_rate` decimal(4,2) not null,
    primary key (`supplier_ID`)
);

-- WAREHOUSE (products available for sale)--
create table if not exists `WAREHOUSE` (
	`product_ID` INTEGER unsigned auto_increment NOT NULL,
    `product_name` varchar(30) DEFAULT NULL,
    `product_category` varchar(10) DEFAULT NULL,
    `number_in_stock` INTEGER unsigned NOT NULL,
    `price_per_item` decimal(6,2) NOT NULL,
    primary key (`product_ID`)
);

-- SALES INVOICE (customer´s order - initiation and status)--
create table if not exists `SALES_INVOICE`(
	`sales_invoice_ID` integer unsigned auto_increment not null,
    `customer_ID` integer unsigned not null,
    `booking_date` date not null,
    `delivery_date` date default null,
	`delivery_address` varchar(100) not null,
    `payment_status` boolean default false,
    `invoice_date` date not null,
    `invoice_tax_rate` decimal(4,2) default 15,
    primary key (`sales_invoice_ID`)
);

-- PURCHASE INVOICE (order of items from supplier - initiation and status)--
create table if not exists `PURCHASE_INVOICE`(
	`purchase_invoice_ID` integer unsigned auto_increment not null,
    `supplier_ID` integer unsigned not null,
    `booking_date` date not null,
    `delivery_date` date default null,
	`delivery_address` varchar(100) not null,
    `payment_status` boolean default false,
    `invoice_date` date not null,
     primary key (`purchase_invoice_ID` )
);

-- PURCHASE ORDER (purchase invoice - details)--
create table if not exists `PURCHASE_ORDER`(
	`purchase_order_ID` integer unsigned auto_increment not null,
	`purchase_invoice_ID` integer unsigned not null,
    `product_ID` INTEGER unsigned NOT NULL,
    `number_of_items` integer unsigned not null,
	`price_per_item` decimal(6,2) NOT NULL,
    `total_amount` decimal(8,2) default NULL,
    primary key (`purchase_order_ID`)
);

-- SALES ORDER (sales invoice - details)--
create table if not exists `SALES_ORDER`(
	`sales_order_ID` integer unsigned auto_increment not null,
    `sales_invoice_ID` integer unsigned not null,
    `product_ID` integer unsigned NOT NULL,
    `number_of_items` integer unsigned not null,
	`product_rating` decimal(2,1) default NULL,
    `total_amount` decimal(8,2) default NULL,
    primary key (`sales_order_ID`)
);

alter table Customer
add `city_name` varchar(20);

create table if not exists `SERVICE_REVIEW` (
	`review_ID` integer unsigned auto_increment not null,
    `review_date` date default null,
    `review_rate` tinyint default null,
    `sales_invoice_ID` integer unsigned not null,
    primary key (`review_ID`)
);

#4 ASSIGN FOREIGN KEYS, APPLY CONSTRAINTS, DELETION AND UPDATE SET UP
-- SALES INVOICE –

Alter table `SALES_INVOICE`
add constraint `fk_sales_invoice_customer`
	foreign key (`customer_ID`) references `CUSTOMER` (`customer_ID`)
		on delete no action
		on update cascade;

-- PURCHASE INVOICE –
 Alter table `PURCHASE_INVOICE`
Add constraint `fk_purchase_order_supplier`
	FOREIGN KEY (`supplier_ID`) REFERENCES `SUPPLIER` (`supplier_ID`)
		on delete no action
		on update cascade;

-- SALES ORDER—
 alter table `SALES_ORDER`
add constraint `fk_sales_order_sales_invoice`
	foreign key (`sales_invoice_ID`) references `SALES_INVOICE` (`sales_invoice_ID`)
		on delete no action
		on update cascade,
add constraint `fk_sales_order_warehouse`
	foreign key (`product_ID`) references `WAREHOUSE` (`product_ID`) 
		on delete no action
		on update cascade;


-- PURCHASE ORDER—
 alter table `PURCHASE_ORDER`
add constraint `fk_purchase_order_purchase_invoice`
foreign key (`purchase_invoice_ID`) references `PURCHASE_INVOICE` (`purchase_invoice_ID`)
		on delete no action
		on update cascade,
add constraint `fk_purchase_order_warehouse`
	foreign key (`product_ID`) references `WAREHOUSE` (`product_ID`) 
		on delete no action
		on update cascade;
        
-- SERVICE REVIEW--
Alter table `SERVICE_REVIEW`
Add constraint `fk_service_review_sales_invoice`
	foreign key (`sales_invoice_ID`) references `SALES_INVOICE` (`sales_invoice_ID`)
		on delete no action
		on update cascade;

####
#Solve bug with foreign key drow
CREATE INDEX any_name ON CUSTOMER (customer_ID);

#Here start inserts to tables.
INSERT INTO  customer (
   customer_name,
   email_address,
   discount_rate,
   country_code_phone,
   phone_number,
   invoice_address,
   loyalty_programm,
   city_name
) SELECT  
concat( LAST_NAME, ' ', FIRST_NAME ) as customer_name,
concat( LAST_NAME, '.', FIRST_NAME, '@getpresent.pt' ) as email_address,
0 as discount_rate,
floor(RAND()*(999-1)+1) as country_code_phone,
floor(RAND()*(9897654329-9130000001)+9130000001) as phone_number,
(SELECT STREET_ADDRESS from hr.location where street_address is not null ORDER BY RAND() LIMIT 1) as STREET_ADDRESS,
floor(RAND()*(4-1)+1) as loyalty_programm,
(SELECT CITY from hr.location where city is not null ORDER BY RAND() LIMIT 1) as city_name
from hr.employee ;

update customer set customer.discount_rate=(customer.loyalty_programm*5) where customer.customer_ID > 0; 


insert into `warehouse`(`product_name`, `product_category`, `number_in_stock`, `price_per_item`)  values
('CHATEAU GRIVIERE 2010', 'wine', 15, 250.00),
('CHATEAU SAINT-PIERRE 2015', 'wine', 10, 850.00),
('DOMAINE DE LA SANGLIERE,ROSE', 'wine', 25, 150.00),
('la poza de balle 2018', 'wine', 5, 25.00),
('brunello riserva 1975', 'wine', 11, 30.00),
('lermita 2017', 'wine', 4, 58.00),
('cornas 1990', 'wine', 16, 44.00),
('CHÂTEAU LA FLEUR 2015', 'wine', 8, 1280.00),
('DOMAINE VACHERON, WHITE', 'wine', 9, 325.00),
('rose 212', 'flower', 25, 10.00),
('rose 318', 'flower', 20, 10.00),
('bouquet 1', 'flower', 5, 12.00),
('bouquet 2', 'flower', 6, 18.00),
('bouquet 4', 'flower', 10, 8.50),
('iris 12', 'flower', 16, 16.50),
('iris 18', 'flower', 18, 11.50),
('orchid 14', 'flower', 2, 20.00),
('selection 12', 'flower', 2, 30.00),
('selection 10', 'flower', 2, 220.00),
('winnie pooch', 'cake', 2, 120.00),
('alice lee', 'cake', 2, 50.00),
('black velvet', 'cake', 2, 30.00),
('homemade 1', 'cake', 2, 40.00),
('special', 'cake', 4, 60.00),
('francese', 'cake', 8, 10.50),
('opera', 'cake', 10, 15.50),
('norway', 'cake', 10, 15.50),
('chocolate', 'cake', 10, 15.50),
('chocolate 2', 'cake', 10, 15.50);

insert into `sales_invoice` (`customer_ID`, `booking_date`, `delivery_date`, `delivery_address`, `payment_status`, `invoice_date`) values
(5,'2020-01_01', '2020-01_10', 'Vijzelmolen 33, 1622 KJ, Hoorn, Netherlands', 1, '2020-01_10'),
(2,'2020-02-05', '2020-02-12', 'Esdoornlaan 110, 7421 AX4, Deventer, Netherlands', 1, '2020-02-12'),
(3, '2020-03-07', '2020-03-12', 'Doespolderkade,  53 2355 CV,  Zuid-Holland,  Netherlands', 2, '2020-03-12'),
(4, '2020-04-02', '2020-04-18', 'Rådyrfaret 245, 1362,  Hosle, Norway', 1, '2020-04-18'),
(5, '2020-05-02', '2020-05-19', 'Persbakken 107, 6518, Kristiansund N, Norway', 1, '2020-05-19'),
(6, '2020-06-02', '2020-06-15', 'Vingersjokroken 11, 2211, Kongsvinger, Norway', 2, '2020-06-15'),
(7, '2020-07-03', '2020-07-10', 'Salacas, bld. 17, 10702, Riga, Latvia', 1, '2020-07-10'),
(8, '2020-08-09', '2020-08-16', 'Volguntes, bld. 84, 12116, Riga, Latvia', 1, '2020-08-16'),
(9, '2020-09-15', '2020-09-30', 'Vaidavas, bld. 13, 12128, Riga, Latvia', 2, '2020-09-30'),
(5, '2020-10-16', '2020-10-20', 'Saulkrasti / Paegles, bld. 9, 12168, Riga, Latvia', 1, '2020-10-20'),
(11, '2020-11-18', '2020-11-22', 'Gertrudes, bld. 57, 13364, Riga, Latvia', 1, '2020-11-22'),
(12, '2020-12-18', '2020-12-22', 'Vainodes, bld. 5/A, 12126, Riga, Latvia', 2, '2020-12-22'),
(5, '2021-01-18', '2021-01-28', 'Via Castelfidardo 30, 87070, Castroregio, Italy', 1, '2021-01-28'),
(14, '2021-02-10', '2021-02-28', 'Via Varrone 126, 95010, Carrabba, Italy', 1, '2021-02-28'),
(7, '2021-03-16', '2021-03-28', 'Via Goffredo Mameli 83, 02010, Terzone, Italy', 2, '2021-03-28'),
(16, '2021-04-12', '2021-04-22', 'Via San Domenico 99, 39040, Mareit, Italy', 2, '2021-04-22'),
(17, '2021-05-11', '2021-05-18', 'Via Piccinni 58, 82019, St.agata De Goti, Italy', 1, '2021-05-18'),
(18, '2021-06-16', '2021-06-20', 'Via Longhena 52, 00020, Pisoniano, Italy', 1, '2021-06-20'),
(19, '2021-07-16', '2021-07-22', 'R Doutor Alberto Sampaio 29, 4820-825, Padinho, Portuguese', 1, '2021-07-22'),
(20, '2021-08-15', '2021-08-22', 'Rua Diogo Cao 39, 2775-260, Parede, Portuguese', 2, '2021-08-22'),
(5, '2021-09-16', '2021-09-23', 'R Maria M Tavares 81, 7050-513, Azenha, Portuguese', 1, '2021-09-23'),
(22, '2021-10-11', '2021-10-23', 'Rua Sao Salvador 96, 4730-360, Longras, Portuguese', 1, '2021-10-23'),
(23, '2021-11-11', '2021-11-22', 'Bairro St Antonio 83, 4960-010, Secas, Portuguese', 1, '2021-11-22'),
(24, '2021-12-11', '2021-12-20', 'R Germana Tanger 118, 2725-672, Algueirao, Portuguese', 1, '2021-12-20'),
(25, '2022-01-16', '2022-01-20', 'Strada M.Eminescu 50, Olt, Romania', 1, '2022-01-20'),
(7, '2022-02-19', '2022-02-23', 'Boriaaur enparantza 46, 07518, Lloret De Vista Alegre, Spain', 2, '2022-02-23'),
(5, '2022-03-10', '2022-03-16', 'Cadiz 88, 18518, Cogollos De Guadix, Spain', 1, '2022-03-16'),
(28, '2022-04-10', '2022-04-16', 'Eusebio Davila 75, 41550, Aguadulce, Spain', 2, '2022-04-16'),
(29, '2022-05-18', '2022-05-25', 'Visitacion de la Encina 4, 37748, Sant Andreu De La Barca, Spain', 1, '2022-05-25'),
(30, '2022-06-18', '2022-06-25', 'Constitucion 7, 36890, Mondariz-balneario, Spain', 1, '2022-06-25');


insert into `sales_order` (`sales_invoice_ID`, `product_ID`, `number_of_items`, `product_rating`) values
(1, 9, 1, 4.5), 
(1, 21, 1, 4.0), 
(1, 20, 1, 4.7),
(2, 15, 2, 3.8),
(3, 8, 1, 3.8),
(4, 11, 5, 4.4), 
(4, 6, 2, 2.7),
(5, 2, 1, 3.9), (5, 15, 2, 4.9),
(6, 27, 5, 4.4),
(7, 8, 2, 3.3), (7, 14, 2, 3.6),
(8,  20, 1, 4.4),
(9, 18, 3, 3.5), (9, 7, 1, 3.9),
(10, 2, 1, 4.9),
(11, 4, 2, 4.8), (11, 13, 1, 4.4),
(12, 22, 2, 3.6),
(13, 12, 20, 4.5),
(14, 12, 2, 4.8), (14, 7, 2, 3.7),
(15, 23, 4, 4.4), (14, 4, 2, 4.2),
(16, 5, 2, 4.3),
(17, 17, 10, 4.9),
(18, 26, 4, 4.4),
(18, 13, 2, 2.8),
(19, 22, 1, 3.8),
(19, 10, 1, 4.4),
(20, 10, 3, 4.4),
(21, 15, 2, 4.6),
(22, 24, 1, 3.9), 
(22, 9, 1, 4.4),
(23, 5, 2, 4.4),
(24, 12, 10, 4.8),
 (24, 29, 1, 4.5),
(25, 27, 2, 4.4),
 (25, 6, 2, 3.3),
(26, 19, 1, 3.3),
 (26, 6, 1, 3.3),
(27, 29, 2, 4.4),
(28, 28, 3, 4.4), 
(28, 16, 5, 3.6),
(29, 9, 1, 4.4),
(30, 17, 5, 3.3),
(30, 6, 5, 4.1);


SELECT * from customer;
SELECT * from warehouse;
SELECT * from sales_invoice;
SELECT * from sales_order;



# Trigger automatically updates of discount rate if level of loyalty programm changes
# Creation of table for inserting data to trigger with different levels of loyalty program and discount rate 

drop table if exists `loyalty_level`;
CREATE TABLE IF NOT EXISTS `loyalty_level` (
	`loyalty_level` INTEGER unsigned NOT NULL,
    `discount_level` INTEGER unsigned NOT NULL,
    primary key (`loyalty_level`)
);

insert into loyalty_level(`loyalty_level`,`discount_level`) values (1,5);
insert into loyalty_level(`loyalty_level`,`discount_level`) values (2,10);
insert into loyalty_level(`loyalty_level`,`discount_level`) values (3,15);

DROP TRIGGER if exists discount_rate_update;
DELIMITER $$
create trigger discount_rate_update
before update
On customer
For each row
begin
	 Set new.discount_rate = (
      SELECT discount_level FROM loyalty_level where loyalty_level.loyalty_level=new.loyalty_programm
	 );
end $$
DELIMITER ;


#Trigger Log table. This table fills automatically when a discount_rate of customer changes.

drop table if exists `log_discount_rate`;
CREATE TABLE IF NOT EXISTS `log_discount_rate` (
	`log_ID` INTEGER unsigned auto_increment NOT NULL,
    `customer_ID` INTEGER unsigned NOT NULL,
    `old_discount_rate` decimal(8,2) NOT NULL,
    `new_discount_rate` decimal(8,2) NOT NULL,
    `update_date` date not null,
    primary key (`log_ID`)
);
Alter table `log_discount_rate`
Add constraint `fk_log_discount_rate_customer`
	FOREIGN KEY (`customer_ID`) REFERENCES `CUSTOMER` (`customer_ID`)
		on delete no action
		on update cascade;

DROP TRIGGER if exists insert_discount_update_log;
delimiter $$
create trigger insert_discount_update_log after update
on customer
for each row
begin
	if OLD.discount_rate != NEW.discount_rate then
		insert into log_discount_rate(`customer_ID`, `old_discount_rate`, `new_discount_rate`, `update_date`) values
		(NEW.customer_ID, OLD.discount_rate, NEW.discount_rate, now());
    end if;
end $$

delimiter ;
