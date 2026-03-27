5: Revenue Percentage by Product Category
Aprroach:
        1.Joined multiple tables 
        2.Calculated Total Revenue per category in CTE
        3.SUM() OVER() to calculate grand total
        4.Percentage calulcated using 'category_revenue / grand total * 100'
Concepts used: CTE, SUM() OVER(), Multiple Table join, Percentage Formula

Why is this useful in business
  - Identify which product categories are driving the most revenue
  - Helps management allocate marketing and inventory budgets
    to high-performing categories
  - Spot underperforming categories that need attention or removal

***Query***
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
