--What is the total amount each customer spent at the restaurant?

select distinct customer_id
	   ,SUM(price) over (partition by customer_id) as total_spent
from sales s
	 inner join menu m on s.product_id = m.product_id 

--How many days has each customer visited the restaurant?

with cte 
as 
(
select customer_id, dense_rank() over (partition  by customer_id order by order_date) as ranked_total_days
		from sales
)
select customer_id
	   ,MAX(ranked_total_days) as total_visits
from cte
group by customer_id

--What was the first item from the menu purchased by each customer?

select customer_id
	   ,product_name
from (select s.customer_id, s.product_id, m.product_name, dense_rank() over (partition  by customer_id order by order_date, customer_id) as ranked_total_days
		from sales s inner join menu m on s.product_id=m.product_id) as source
where ranked_total_days = 1
group by customer_id, product_name

--What is the most purchased item on the menu and how many times was it purchased by all customers?

select TOP 1 product_name, COUNT(product_name) as total_sold
from sales s inner join menu m on s.product_id = m.product_id
group by product_name
order by total_sold desc

--Which item was the most popular for each customer?

With rank as
(
Select S.customer_ID ,
       M.product_name, 
       Count(S.product_id) as Count,
       Dense_rank()  Over (Partition by S.Customer_ID order by Count(S.product_id) DESC ) as Rank
From Menu m
join Sales s
On m.product_id = s.product_id
group by S.customer_id,S.product_id,M.product_name
)
Select Customer_id,Product_name,Count
From rank
where rank = 1

--Which item was purchased first by the customer after they became a member?

with ranked 
as (
select m.customer_id
	   ,men.product_name
	   ,dense_rank() over (partition by m.customer_id order by s.order_date) ranking
from members m
	 inner join sales s on m.customer_id = s.customer_id
	 inner join menu men on s.product_id = men.product_id
where s.order_date > m.join_date 
)
select customer_id,product_name
from ranked 
where ranking = 1

--Which item was purchased just before the customer became a member?
with cte
as (
select m.customer_id
	   , join_date
	   , order_date
	   , product_name
	   ,dense_rank() over (partition by m.customer_id order by s.order_date desc) ranking
from members m
	 inner join sales s on m.customer_id = s.customer_id
	 inner join menu men on s.product_id = men.product_id
where s.order_date < m.join_date 
)

select customer_id
	   ,product_name
from cte
where ranking = 1 

--What is the total items and amount spent for each member before they became a member?

select m.customer_id
	  ,COUNT(s.product_id) as total_items
	  ,SUM(price) as amount_spent
from sales s 
	 inner join members m on s.customer_id = m.customer_id
	 inner join menu men on s.product_id = men.product_id
where join_date>order_date
group by m.customer_id

--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with cte 
as (
select m. customer_id
	   ,case 
			when product_name='sushi' then price*20
			else price*10
			end as points
from sales s 
	 inner join members m on s.customer_id = m.customer_id
	 inner join menu men on s.product_id = men.product_id
--where join_date<order_date
)
select customer_id
	   ,SUM(points) as total_points
from cte 
group by customer_id


--In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

Select
     s.customer_id
	,sum (CASE
             When (DATEDIFF(DAY, me.join_date, s.order_date) between 0 and 7) or (m.product_name = 'sushi') Then m.price * 20
             Else m.price * 10
             END) As Points
From members as me
    Inner Join sales as s on s.customer_id = me.customer_id
    Inner Join menu as m on m.product_id = s.product_id
where s.order_date >= me.join_date and s.order_date <= CAST('2021-01-31' AS DATE)
Group by s.customer_id


--bonus

--Recreate the following table output using the available data:
select s.customer_id
	   ,s.order_date
	   ,m.product_name
	   ,m.price
	   ,case 
			when s.order_date>mem.join_date then 'Y' 
			else 'N'
			end as member
from sales s 
	 inner join menu m on s.product_id = m.product_id
	 left join members mem on s.customer_id=mem.customer_id

with cte 
as (
select s.customer_id
	   ,s.order_date
	   ,m.product_name
	   ,m.price
	   ,case 
			when s.order_date>=mem.join_date then 'Y' 
			else 'N'
			end as member
from sales s 
	 inner join menu m on s.product_id = m.product_id
	 left join members mem on s.customer_id=mem.customer_id
	 )

select customer_id
	   ,order_date
	   ,product_name
	   ,price
	   ,member
	   ,case
			when member = 'Y' then dense_rank() over (PARTITION by customer_id,member order by order_date) 
			else NULL 
			end as ranking
from cte

