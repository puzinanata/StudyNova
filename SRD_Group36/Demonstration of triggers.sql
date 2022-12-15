USE getpresent;

# Demonstration of 1st trigger (Trigger automatically updates of discount rate if level of loyalty programm changes)

#SELECT * from customer WHERE loyalty_programm=1 LIMIT 1;
#next q by customer_id from previous q 
#update customer set customer.loyalty_programm=3 where customer_id=6;
#select * from customer where customer_id=6;

SELECT * from customer where loyalty_programm=1 LIMIT 1;
set @CUSTOMER_ID_WITH_RATE_1 = (SELECT customer_id from customer where loyalty_programm=1 LIMIT 1);
#next q by customer_id from previous q 

update customer set customer.loyalty_programm=2 where customer_id=@CUSTOMER_ID_WITH_RATE_1;
select * from customer where customer_id=@CUSTOMER_ID_WITH_RATE_1;



#Demonstration of trigger Log table. This table fills automatically when a discount_rate of customer changes.

SELECT * from log_discount_rate;