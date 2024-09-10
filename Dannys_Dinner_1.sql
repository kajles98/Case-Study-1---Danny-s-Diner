--What is the total amount each customer spent at the restaurant?

SELECT DISTINCT customer_id
      ,SUM(price) OVER (PARTITION BY customer_id) AS total_spent
FROM sales s
      INNER JOIN menu m ON s.product_id = m.product_id 

--How many days has each customer visited the restaurant?

with cte 
as 
(
SELECT customer_id
      ,DENSE_RANK() OVER (PARTITION BY customer_id order by order_date) AS ranked_total_days
FROM sales
)
SELECT customer_id
	   ,MAX(ranked_total_days) as total_visits
FROM cte
GROUP BY customer_id

--What was the first item from the menu purchased by each customer?

SELECT customer_id
	   ,product_name
FROM (
      SELECT s.customer_id
            ,s.product_id
            ,m.product_name
            ,DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY order_date, customer_id) AS ranked_total_days
		  FROM sales s
            INNER JOIN menu m ON s.product_id=m.product_id
     ) AS source
WHERE ranked_total_days = 1
GROUP BY customer_id, product_name

--What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT TOP 1 product_name, 
	     COUNT(product_name) AS total_sold
FROM sales s 
	    INNER JOIN menu m ON s.product_id = m.product_id
GROUP BY product_name
ORDER BY total_sold desc

--Which item was the most popular for each customer?

With ranking as
(
SELECT s.customer_id
       ,m.product_name
       ,COUNT(s.product_id) AS items_count
       ,DENSE_RANK()  OVER (PARTITION BY s.customer_id ORDER BY COUNT(s.product_id) DESC ) AS ranked
FROM menu m
	 JOIN sales s ON m.product_id = s.product_id
GROUP BY s.customer_id,s.product_id,m.product_name
)
SELECT customer_id
	   ,product_name
	   ,items_count
FROM ranking
WHERE ranked = 1

--Which item was purchased first by the customer after they became a member?

with ranked 
as (
SELECT m.customer_id
	   ,men.product_name
	   ,DENSE_RANK() OVER (PARTITION BY m.customer_id ORDER BY s.order_date) ranking
FROM members m
	 INNER JOIN sales s ON m.customer_id = s.customer_id
	 INNER JOIN menu men ON s.product_id = men.product_id
WHERE s.order_date > m.join_date 
)
SELECT customer_id,product_name
FROM ranked 
WHERE ranking = 1

--Which item was purchased just before the customer became a member?
with cte
as (
SELECT m.customer_id
	    ,join_date
	    ,order_date
	    ,product_name
	    ,DENSE_RANK() OVER (PARTITION BY m.customer_id ORDER BY s.order_date DESC) ranking
FROM members m
  	INNER JOIN sales s ON m.customer_id = s.customer_id
	  INNER JOIN menu men ON s.product_id = men.product_id
WHERE s.order_date < m.join_date 
)

SELECT customer_id
	    ,product_name
FROM cte
WHERE ranking = 1

--What is the total items and amount spent for each member before they became a member?

SELECT m.customer_id
	  ,COUNT(s.product_id) AS total_items
	  ,SUM(price) AS amount_spent
FROM sales s 
	 INNER JOIN members m ON s.customer_id = m.customer_id
	 INNER JOIN menu men ON s.product_id = men.product_id
WHERE join_date>order_date
GROUP BY m.customer_id

--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with cte 
as (
SELECT m. customer_id
	   ,CASE 
			WHEN product_name='sushi' THEN price*20
			ELSE price*10
			END AS points
FROM sales s 
	 INNER JOIN members m ON s.customer_id = m.customer_id
	 INNER JOIN menu men ON s.product_id = men.product_id
WHERE join_date<order_date
)
SELECT customer_id
	   ,SUM(points) AS total_points
FROM cte 
GROUP BY customer_id


--In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

WITH dates 
AS (
   SELECT *, 
		  DATEADD(DAY, 6, join_date) AS valid_date, 
          EOMONTH('2021-01-31') AS last_date
          FROM members 
)
SELECT s.customer_id, 
       SUM(
	         CASE 
		       WHEN m.product_ID = 1 THEN m.price*20
			     WHEN s.order_date BETWEEN d.join_date AND d.valid_date THEN m.price*20
			     ELSE m.price*10
			     END 
		       ) AS Points
FROM dates d
	JOIN sales ON d.customer_id = s.customer_id
	JOIN menu m ON m.product_id = s.product_id
WHERE s.order_date < d.last_date
GROUP BY s.customer_id


--bonus

--Recreate the following table output using the available data:
SELECT s.customer_id
	   ,s.order_date
	   ,m.product_name
	   ,m.price
	   ,CASE
		WHEN s.order_date>mem.join_date THEN 'Y' 
		ELSE 'N'
		END AS member
FROM sales s 
	 INNER JOIN menu m ON s.product_id = m.product_id
	 LEFT JOIN members mem ON s.customer_id=mem.customer_id

with cte 
as (
SELECT s.customer_id
	   ,s.order_date
	   ,m.product_name
	   ,m.price
	   ,CASE
		WHEN s.order_date>=mem.join_date THEN 'Y' 
	        ELSE 'N'
		END AS member
FROM sales s 
	 INNER JOIN menu m ON s.product_id = m.product_id
	 LEFT JOIN members mem ON s.customer_id=mem.customer_id
	 )

SELECT customer_id
	   ,order_date
	   ,product_name
	   ,price
	   ,member
	   ,CASE
		WHEN member = 'Y' THEN DENSE_RANK() OVER (PARTITION BY customer_id,member ORDER BY order_date) 
		ELSE NULL 
		END AS ranking
FROM cte

