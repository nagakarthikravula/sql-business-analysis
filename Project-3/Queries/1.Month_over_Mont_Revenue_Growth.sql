Question 1: Month-over-Month Revenue Growth Rate
  Tables: olist_orders_dataset, olist_order_items_dataset
  Approach: Aggregate monthly revenue using DATE_TRUNC, then use LAG()
            window function ordered by month_date to compute % change
  Concepts: CTE, DATE_TRUNC, LAG(), NULLIF, ROUND, IS NOT NULL filter

***Query*** 
  
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
select Month_Name,Month_Revenue,lag(Month_Revenue) over(order by month_date) as last_month_revenue,
concat(ROUND(
        ((month_revenue - LAG(month_revenue) OVER (ORDER BY month_date))
        / NULLIF(LAG(month_revenue) OVER (ORDER BY month_date), 0)) * 100
    , 2),'%') AS growth_rate_pct
from cte
where month_date > '2016-12-01'
order by month_date
;

Why is this useful in business?

To track whether the business is growing or shrinking.
Identify causes of months with unsual drops or spikes.
Help to set targets in upcoming months

Formula used :
Growth % = (Current_Month_Revenue - Previous_Month_Revenue ) / Previous_month_revenue * 100

