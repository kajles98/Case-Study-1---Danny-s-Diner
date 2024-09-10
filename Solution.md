
### 1. What is the total amount each customer spent at the restaurant?

````sql
SELECT DISTINCT customer_id
      ,SUM(price) OVER (PARTITION BY customer_id) AS total_spent
FROM sales s
      INNER JOIN menu m ON s.product_id = m.product_id 
````

#### Answer:
| Customer_id | Total_sales |
| ----------- | ----------- |
|     A       |      76     |
|     B       |      74     |
|     C       |      36     |

- Customer A, B and C spent $76, $74 and $36.

***

### 2. How many days has each customer visited the restaurant?

````sql
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
````
#### Answer:
| customer_id | total_visits |
| ----------- | -----------  |
|     A       |       4      |
|     B       |       6      |
|     C       |       2      |

- Customer A visited the restaurant 4 times, customer B 6 times and customer C 2 times.

***

### 3. What was the first item from the menu purchased by each customer?

````sql 
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
````
#### Answer:
| customer_id | product_name |
| ----------- | -----------  |
|     A       |    curry     |
|     A       |    sushi     |
|     B       |    curry     |
|     C       |    ramen     |

- The first item purchased by customer A was curry and sushi, customer B chose curry and customer C - ramen.

***

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
SELECT TOP 1 product_name, 
	     COUNT(product_name) AS total_sold
FROM sales s 
	    INNER JOIN menu m ON s.product_id = m.product_id
GROUP BY product_name
ORDER BY total_sold desc
````
#### Answer:
| product_name | total_sold |
| -----------  | -----------|
|    ramen     |      8     |

- The most purchased item on the menu was ramen. It was bought 8 times.
  
 ***

### 5. Which item was the most popular for each customer?
 
````sql
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
````

#### Answer: 
| customer_id | product_name | items_count |
|-------------| -----------  | ------------|
|      A      |    ramen     |      3      |
|      B      |    sushi     |      2      |
|      B      |    curry     |      2      |
|      B      |    ramen     |      2      |
|      C      |    ramen     |      3      |

- The most popular item for customers A and C  was ramen, customer B enjoyed all the items on the menu.

*** 

### 6. Which item was purchased first by the customer after they became a member?

````sql
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
````

#### Answer:
| customer_id  | product_name |
| -----------  | -------------|
|      A       |     ramen    |
|      B       |     sushi    |

- After becoming a member, first items purchased by customer A and B were ramen and sushi, respectively.

***

### 7. Which item was purchased just before the customer became a member?

````sql
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
````

#### Answer:
| customer_id  | product_name |
| -----------  | -------------|
|      A       |     sushi    |
|      A       |     curry    |
|      B       |     sushi    |

- Just before becoming a member customer A purchased sushi and curry, customer B chose sushi.

  ***

### 8. What is the total items and amount spent for each member before they became a member?

````sql
SELECT m.customer_id
	  ,COUNT(s.product_id) AS total_items
	  ,SUM(price) AS amount_spent
FROM sales s 
	 INNER JOIN members m ON s.customer_id = m.customer_id
	 INNER JOIN menu men ON s.product_id = men.product_id
WHERE join_date>order_date
GROUP BY m.customer_id
````

#### Answer:
| customer_id  | total_items  | amount_spent |
| -----------  | -------------|--------------|
|      A       |       2      |      25      |
|      B       |       3      |      40      |

- Before becoming a member customer A spent 25$ on 2 items and customer B spent 40$ on 3 items.

***

### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

````sql
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
````
#### Answer: 
| customer_id  | total_points |
| -----------  | -------------|
|      A       |      360     |
|      B       |      440     |

- Counting from the join_date customer A would have 360 points and customer B would have 440 points.

***

### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

````sql
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
````
#### Answer: 
| customer_id  | total_points |
| -----------  | -------------|
|      A       |      1370    |
|      B       |      820     |

- At the end of January customer A and B have 1370 and 820 points, respectively.
***

### BONUS TASKS

--Recreate the following table output using the available data:

#### #1 Output:
| customer_id | order_date | product_name | price | member |
|-------------|------------|--------------|-------|--------|
|      A      | 2021-01-01 |     curry    |   15  |    N   | 
|      A      | 2021-01-01 |     sushi    |   10  |    N   | 
|      A      | 2021-01-07 |     curry    |   15  |    Y   | 
|      A      | 2021-01-10 |     ramen    |   12  |    Y   | 
|      A      | 2021-01-11 |     ramen    |   12  |    Y   | 
|      A      | 2021-01-11 |     ramen    |   12  |    Y   | 
|      B      | 2021-01-01 |     curry    |   15  |    N   | 
|      B      | 2021-01-02 |     curry    |   15  |    N   | 
|      B      | 2021-01-04 |     sushi    |   10  |    N   | 
|      B      | 2021-01-11 |     sushi    |   10  |    Y   | 
|      B      | 2021-01-16 |     ramen    |   12  |    Y   | 
|      B      | 2021-02-01 |     ramen    |   12  |    Y   | 
|      C      | 2021-01-01 |     ramen    |   12  |    N   | 
|      C      | 2021-01-01 |     ramen    |   12  |    N   | 
|      C      | 2021-01-07 |     ramen    |   12  |    N   | 

#### Answer:
````sql
SELECT s.customer_id
	   ,s.order_date
	   ,m.product_name
	   ,m.price
	   ,CASE 
			  WHEN s.order_date>mem.join_date then 'Y' 
			  ELSE 'N'
			  END AS member
FROM sales s 
	 INNER JOIN menu m ON s.product_id = m.product_id
	 LEFT JOIN members mem ON s.customer_id=mem.customer_id
````

#### #2 Output:
| customer_id | order_date | product_name | price | member | ranking |
|-------------|------------|--------------|-------|--------|---------
|      A      | 2021-01-01 |     curry    |   15  |    N   |   null  |
|      A      | 2021-01-01 |     sushi    |   10  |    N   |   null  |
|      A      | 2021-01-07 |     curry    |   15  |    Y   |    1    |
|      A      | 2021-01-10 |     ramen    |   12  |    Y   |    2    |
|      A      | 2021-01-11 |     ramen    |   12  |    Y   |    3    |
|      A      | 2021-01-11 |     ramen    |   12  |    Y   |    3    |
|      B      | 2021-01-01 |     curry    |   15  |    N   |   null  |
|      B      | 2021-01-02 |     curry    |   15  |    N   |   null  |
|      B      | 2021-01-04 |     sushi    |   10  |    N   |   null  |
|      B      | 2021-01-11 |     sushi    |   10  |    Y   |    1    |
|      B      | 2021-01-16 |     ramen    |   12  |    Y   |    2    |
|      B      | 2021-02-01 |     ramen    |   12  |    Y   |    3    |
|      C      | 2021-01-01 |     ramen    |   12  |    N   |   null  |
|      C      | 2021-01-01 |     ramen    |   12  |    N   |   null  |
|      C      | 2021-01-07 |     ramen    |   12  |    N   |   null  |

#### Answer:

````sql
with cte 
as (
SELECT s.customer_id
	   ,s.order_date
	   ,m.product_name
	   ,m.price
	   ,CASE 
		    	WHEN s.order_date>=mem.join_date then 'Y' 
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
		    	WHEN member = 'Y' then DENSE_RANK() OVER (PARTITION BY customer_id,member ORDER_BY order_date) 
			ELSE NULL 
			END AS ranking
FROM cte
````
