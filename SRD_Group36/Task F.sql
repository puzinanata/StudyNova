USE getpresent;

#F1.List all the customer’s names, dates, and products bought by these customers in a range of two dates.
SELECT c.customer_name, 
       si.delivery_date, 
       w.product_name,
       w.product_category 
FROM   customer as c
       JOIN sales_invoice as si
         ON c.customer_id = si.customer_id 
       JOIN sales_order as so 
         ON si.sales_invoice_id = so.sales_invoice_id 
       JOIN warehouse as w
         ON so.product_id = w.product_id 
WHERE  si.delivery_date BETWEEN '2020-01-01' AND '2021-06-30' 
GROUP  BY c.customer_name, 
          si.delivery_date, 
          w.product_name,
          w.product_category;
 
#F2. Top-3 the most ordered product
SELECT 
sales_order.product_id, 
sales_order.number_of_items,
sales_order.product_rating,
warehouse.product_name
FROM sales_order 
JOIN warehouse on sales_order.product_id = warehouse.product_id
ORDER BY sales_order.number_of_items DESC LIMIT 3;

#F3.Get the average amount of sales for a period that involves 2 or more years

# Intermediate views for generation invoice and for task F.
DROP VIEW IF EXISTS sorderdetailed;
CREATE VIEW sorderdetailed AS
    SELECT
    sales_order.sales_order_ID, 
    sales_order.sales_invoice_id,
    sales_order.product_id,
    sales_order.number_of_items,
    warehouse.product_name,
    warehouse.product_category,
    warehouse.price_per_item,
    (sales_order.number_of_items * warehouse.price_per_item) as Total_so_amount
FROM sales_order
JOIN warehouse ON sales_order.product_id = warehouse.product_id;

#SELECT * FROM sorderdetailed;
#SELECT * FROM sorderdetailed where sales_invoice_ID = 1;

DROP VIEW IF EXISTS sinvoicefin;
Create view sinvoicefin as
select
si.sales_invoice_ID,
si.customer_ID,
so.Total_so_amount,
c.discount_rate,
si.invoice_tax_rate,
round((so.Total_so_amount * c.discount_rate /100),2) as Discount_amount,
(so.Total_so_amount - round((so.Total_so_amount * c.discount_rate /100),2)) as Subtotal_net_discount,
round(((so.Total_so_amount - round((so.Total_so_amount * c.discount_rate /100),2)) * si.invoice_tax_rate /100),2) as Tax_amount,
so.Total_so_amount - round((so.Total_so_amount * c.discount_rate /100),2) - round(((so.Total_so_amount - round((so.Total_so_amount * c.discount_rate /100),2)) * si.invoice_tax_rate /100),2) as Invoice_total
from sales_invoice as si
join customer as c on si.customer_id = c.customer_id
join sorderdetailed as so on so.sales_invoice_id = si.sales_invoice_id;

#SELECT * FROM sinvoicefin where sales_invoice_id=1;


DROP VIEW IF EXISTS ttl_sales;
CREATE VIEW ttl_sales AS
SELECT 
sinvoicefin.invoice_total,
sales_invoice.invoice_date
from sinvoicefin
JOIN sales_invoice on sinvoicefin.sales_invoice_id = sales_invoice.sales_invoice_id;

#SELECT * from ttl_sales;

#Generation of table with total and average sales.
DROP VIEW IF EXISTS avg_sales;
CREATE VIEW avg_sales AS
SELECT 
concat(DATE_FORMAT(min(invoice_date), '%m/%Y'), '-', DATE_FORMAT(max(invoice_date), '%m/%Y')) as PeriodOfSales,
 concat(round(sum(invoice_total),0), ' €') as 'TotalSales (euros)',
 concat(round(sum(invoice_total)/(select count(*) from (select distinct Year(invoice_date) as lol from ttl_sales group by Year(invoice_date)) as countOfYears),0),' €') as 'YearlyAverage (of the given period',
 concat(round(sum(invoice_total)/(select count(*) from (select distinct DATE_FORMAT(invoice_date, '%m/%Y') as lol from ttl_sales group by DATE_FORMAT(invoice_date, '%m/%Y')) as countOfMonth),0),' €') as 'MonthlyAverage (of the given period)'
 from ttl_sales;
 SELECT * FROM avg_sales;

#F4 -Get the total sales by city/country
DROP VIEW IF EXISTS sales_by_locations;
CREATE VIEW sales_by_locations AS
SELECT 
sum(sinvoicefin.invoice_total) as ttl_sales_by_locations,
substring_index(substring_index(delivery_address, ',', -2), ',', 1) as city
from sinvoicefin
JOIN sales_invoice on sinvoicefin.sales_invoice_id = sales_invoice.sales_invoice_id
GROUP BY city;

SELECT * from sales_by_locations;


#F5 -List all the locations where products were sold, and the product has customer’s ratings

SELECT 
       substring_index(substring_index(delivery_address, ',', -2), ',', 1) as city,
       substring_index(delivery_address, ',', -1) as country
       FROM   sales_invoice
       JOIN sales_order 
         ON sales_invoice.sales_invoice_id = sales_order.sales_invoice_id 
         WHERE sales_order.product_rating is not null
GROUP  BY country, city;        
