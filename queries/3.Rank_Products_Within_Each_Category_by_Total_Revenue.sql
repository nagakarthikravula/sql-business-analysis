Q3. Rank Products Within Each Category by Total Revenue
Tables: olist_order_items_dataset, olist_products_dataset, product_category_name_translation
Approach: Grouped category and product to calculate revenue in cte,
          Then used DENSE_RANK() to paritioned by category, order by
          revenue in descending order.
Concepts: CTE, RANK(), <> '', Mutliple Table Join

***Query***


with cte as (
select pcnt.product_category_name_english as category_name,ooid.product_id as product,sum(ooid.price) as revenue 
from olist_order_items_dataset ooid 
left join olist_products_dataset opd 
on ooid.product_id  = opd.product_id
left join product_category_name_translation pcnt on opd.product_category_name = pcnt.product_category_name 
where opd.product_category_name <> ''
group by category_name,product 
order by category_name
)
select cte.category_name,cte.product,dense_rank() over(partition by cte.catgeory_name order by cte.revenue desc) from cte;
