Q2: Running Total of Revenue by Month
Tables: olist_orders_dataset, olist_order_items_dataset
Approach: Aggregate monthly revenue using DATE_TRUNC, then use  SUM()
            to get running total of this month and previuos month
            ordered by month_date
Concepts: CTE, DATE_TRUNC, SUM(), IS NOT NULL filter


Query:

with cte as (
select to_char(ood.order_delivered_customer_date::timestamp, 'MonthYYYY') as Month_Name,
DATE_TRUNC('month', ood.order_delivered_customer_date::timestamp)::DATE AS month_date,
sum(ooid.price)::numeric as Month_Revenue
from olist_orders_dataset ood join olist_order_items_dataset ooid
on ood.order_id  = ooid.order_id
where ood.order_delivered_customer_date <> ''
GROUP BY
    month_name,month_date
)
select Month_Name,Month_Revenue,sum(Month_Revenue) over(order by month_date) as running_total
from cte
where month_date > '2016-12-01'
order by month_date
;
