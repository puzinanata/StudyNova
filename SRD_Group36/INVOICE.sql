USE getpresent;
# check github
#Creation of intermediate views for generation invoices
DROP VIEW IF EXISTS sinvoicefin;
Create view sinvoicefin as
select
sales_invoice.sales_invoice_ID,
sales_invoice.customer_ID,
sorderdetailed.Total_so_amount,
customer.discount_rate,
sales_invoice.invoice_tax_rate,
round((sorderdetailed.Total_so_amount * customer.discount_rate /100),2) as Discount_amount,
(sorderdetailed.Total_so_amount - round((sorderdetailed.Total_so_amount * customer.discount_rate /100),2)) as Subtotal_net_discount,
round(((sorderdetailed.Total_so_amount - round((sorderdetailed.Total_so_amount * customer.discount_rate /100),2)) * sales_invoice.invoice_tax_rate /100),2) as Tax_amount,
sorderdetailed.Total_so_amount - round((sorderdetailed.Total_so_amount * customer.discount_rate /100),2) - round(((sorderdetailed.Total_so_amount - round((sorderdetailed.Total_so_amount * customer.discount_rate /100),2)) * sales_invoice.invoice_tax_rate /100),2) as Invoice_total
from sales_invoice
join customer on sales_invoice.customer_id = customer.customer_id
join sorderdetailed on sorderdetailed.sales_invoice_id = sales_invoice.sales_invoice_id;

#SELECT * FROM sinvoicefin where sales_invoice_id=4;

#Creation of intermediate views for generation invoices
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

#SELECT * from sorderdetailed where sales_invoice_id=4;

#G1 - INVOICE view for the head

DROP VIEW IF EXISTS head_sales_invoice;
CREATE VIEW head_sales_invoice AS
select 
'Getpresent Ltd, Avenida 25 Abril 85, 3510-871, Viseu , Vila Cha Do Monte , Portugal, +351 212 32 55, getpresent@eu.com\pt, getpresent.eu' as 'Invoiced by',
sales_invoice.sales_invoice_ID as 'INVOICE NUMBER',
sales_invoice.invoice_date as 'ISSUE DATE',
sales_invoice.delivery_date as 'DELIVERED ON',
customer.customer_name as 'INVOICED TO',
customer.invoice_address as 'ADDRESS',
customer.city_name as 'ÇITY',
sum(sorderdetailed.Total_so_amount) as 'SUBTOTAL, EUR',
sum(sinvoicefin.Discount_amount) as 'DISCOUNT, EUR',
sinvoicefin.invoice_tax_rate as '(TAX RATE, %)',
sum(sinvoicefin.Tax_amount) as 'TAX, EUR',
sum(sinvoicefin.Invoice_total) as 'TOTAL, EUR'
from sorderdetailed
join sales_invoice on sorderdetailed.sales_invoice_id = sales_invoice.sales_invoice_id
join customer on sales_invoice.customer_ID = customer.customer_ID
join sinvoicefin on sorderdetailed.sales_invoice_id = sinvoicefin.sales_invoice_id
where sorderdetailed.Total_so_amount=sinvoicefin.Total_so_amount
group by `INVOICE NUMBER`;

# Display of invoice head
SELECT * FROM head_sales_invoice where `INVOICE NUMBER`=4; 


#G2 - INVOICE view for the details.
DROP VIEW IF EXISTS detailed_sales_invoice;
CREATE VIEW detailed_sales_invoice AS
select
sorderdetailed.product_name  as 'GOODS PURCHASED',
sorderdetailed.product_category as 'CATEGORY',
sorderdetailed.number_of_items as 'QUANTITY',
sorderdetailed.price_per_item as 'PRICE PER ITEM, EUR',
sorderdetailed.Total_so_amount as 'SUBTOTAL, EUR',
sorderdetailed.sales_invoice_id
from sorderdetailed;

# Display of invoice details.
SELECT
`GOODS PURCHASED`,
CATEGORY,
QUANTITY,
`PRICE PER ITEM, EUR`,
`SUBTOTAL, EUR`
 FROM detailed_sales_invoice where sales_invoice_ID = 4;
 