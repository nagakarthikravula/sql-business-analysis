--1.Month_over_Mont_Revenue_Growth
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


--Q2: Running Total of Revenue by Month

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


--Q3: Rank Products Within Each Category by Total Revenue

with cte as (
select pcnt.product_category_name_english as category_name,ooid.product_id as product,sum(ooid.price) as revenue 
from olist_order_items_dataset ooid 
left join olist_products_dataset opd 
on ooid.product_id  = opd.product_id
left join product_category_name_translation pcnt on opd.product_category_name = pcnt.product_category_name 
where opd.product_category_name <> ''
group by category_name,product 
)
select cte.category_name,cte.product,cte.revenue,dense_rank() over(partition by cte.category_name order by cte.revenue desc)
as rank from cte;


--Q4: Time Gap Between 1st and 2nd Order
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



--Q5: Revenue_%_per_Category
with cte as(
select pcnt.product_category_name_english as category,sum(ooid.price) as Category_Revenue
from olist_order_items_dataset ooid 
join olist_products_dataset opd 
on ooid.product_id = opd.product_id 
left join product_category_name_translation pcnt 
on opd.product_category_name = pcnt.product_category_name 
where pcnt.product_category_name_english <> ''
group by category
)
select cte.category
,round(cte.category_revenue::numeric,1) as category_revenue
,sum(category_revenue) over() as Total_Revenue
,round(((round(cte.category_revenue::numeric,1)/sum(category_revenue) over())*100)::numeric,3)
from cte
order by category_revenue desc;


--Q6: Which customers have made purchases in 3 or more consecutive months?

with cte as (
select ood.customer_id,
date_trunc('month', ood.order_purchase_timestamp::timestamp)::date as order_month,count(*) as cnt
from olist_orders_dataset ood group by customer_id,order_month ) 
,
cte2 as (
select 
cte.customer_id,cte.order_month,cnt,
row_number() over(partition by cte.customer_id order by cte.order_month) as rn
from cte
),
grouped AS (
    SELECT 
        customer_id,
        order_month,
        (order_month - (rn * INTERVAL '1 month')) AS grp
    FROM cte2
)
SELECT 
    customer_id
FROM grouped
GROUP BY customer_id, grp
HAVING COUNT(*) >= 3;


--7.What is the 3-month moving average of revenue?
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


--Q8.Average revenue of customer 1st 3 orders vs last 3 orders
select 
ocd.customer_unique_id,count(ood.order_id )
from olist_customers_dataset ocd 
join olist_orders_dataset ood 
on ocd.customer_id = ood.customer_id 
group by ocd.customer_unique_id
having count(*) >= 6


select 
*
from olist_customers_dataset ocd 
join olist_orders_dataset ood 
on ocd.customer_id = ood.customer_id 
where ocd.customer_unique_id = '12f5d6e1cbf93dafd9dcc19095df0b3d'
