Q4: Time Gap Between 1st and 2nd Order


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
