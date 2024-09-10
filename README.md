## Case Study #1: Danny's Diner 
<img src="https://user-images.githubusercontent.com/81607668/127727503-9d9e7a25-93cb-4f95-8bd0-20b87cb4b459.png" alt="Image" width="500" height="520">

### Business Task:
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

### Entity Relationship Diagram:

![image](https://user-images.githubusercontent.com/81607668/127271130-dca9aedd-4ca9-4ed8-b6ec-1e1920dca4a8.png)

### Case Study Questions
Each of the following case study questions can be answered using a single SQL statement:

1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

### Bonus Questions

1. Recreate the following table output using the available data:

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


2. Rank All The Things

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

