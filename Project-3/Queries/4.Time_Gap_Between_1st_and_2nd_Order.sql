Q4: Time Gap Between 1st and 2nd Order
Tables: olist_order_dataset,olist_customers_dataset
Approach: Partitioned row_number() by customer_unique_id
          in cte, Used LEAD() to get 2nd order date,
          Calculated days gap between 1st order and 2nd order
Concepts: CTE, ROW_NUMBER(),LEAD(), <> '', Mutliple Table Join

Why is this useful in business?

Understand how quickly customers return
Helps set timing for re-engagement email campaigns
If average gap is 45 days, send a reminder on day 40
Key metric for customer loyalty analysis

***Query***
  
with cte as(
select ocd.customer_unique_id,ood.order_delivered_customer_date,
lead(ood.order_delivered_customer_date ) over(partition by ocd.customer_unique_id order by ood.order_delivered_customer_date )
,row_number() over(partition by ocd.customer_unique_id order by ood.order_delivered_customer_date )
from olist_customers_dataset ocd 
join olist_orders_dataset ood 
on ocd.customer_id = ood.customer_id 
where ood.order_delivered_customer_date <> ''
)
select customer_unique_id, 
(cte.lead::date - cte.order_delivered_customer_date::date) as Days_gap
from cte 
where lead is not null 
and row_number = 1
order by Days_gap ;
