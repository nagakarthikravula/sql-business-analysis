6.What is the 3-month moving average of revenue?

Approach: 
  - In cte, calculated total revenue for every month
  - Used window function avg(), To get sum of 2 preceding rows and
    current rows used syntax in over( order by month rows between 2 preceding and curent row) which gives us average of last 2 rows and current

Concepts Used:
  Joins, Windows functions 'AVG()' , CTE

Why is this useful in Business:
  - This helps to identify the average revenue.
  - Can identify smooth fluctuations.
  - Identifying trends

***Query***
with cte as(
select 
to_char(ood.order_delivered_customer_date::timestamp,'monthYYYY') as month_name,
date_trunc('month',ood.order_delivered_customer_date :: timestamp)::date as month,
sum(ooid.price) as revenue
from
olist_orders_dataset ood 
join olist_order_items_dataset ooid 
on ood.order_id = ooid.order_id 
where ood.order_delivered_customer_date <> ''
group by month_name,month
)
select month_name,revenue, 
round(avg(revenue) over(order by month rows between 2 preceding and current row)::numeric,2) as average_revenue
from cte;
                                                                                
