Create database pizzahut;

Select*from pizzas;
Select*from pizza_types;
Select*from orders;
Select*from order_details;

--Basic queries

--Retrieve the total number of orders placed.

Select 
	count (order_id) 
		as [Total_Orders]
			from orders;

--Calculate the total revenue generated from pizza sales.

Select 
	round(sum (order_details.quantity*pizzas.price),2) as [Total_Sales]
from 
	order_details 
join 
	pizzas
on 
	pizzas.pizza_id=order_details.pizza_id;

-- Identify the highest-priced pizza.

SELECT TOP 1 
    pizza_types.name,
    pizzas.price
FROM
    pizza_types
JOIN 
    pizzas
ON 
    pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY 
    pizzas.price DESC;

--Identify the most common pizza size ordered.

Select 
	pizzas.size, count(order_details.order_details_id) as [Order_Count]
from 
	pizzas 
Join
	order_details
on
	pizzas.pizza_id=order_details.pizza_id
group by
	pizzas.size
Order by
	Order_Count desc;

--List the top 5 most ordered pizza types along with their quantities.

SELECT TOP 5
    pizza_types.name, 
    SUM(order_details.quantity) AS [Qty]
FROM
    pizza_types
JOIN
    pizzas
    ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN
    order_details
    ON order_details.pizza_id = pizzas.pizza_id
GROUP BY
    pizza_types.name
ORDER BY
    [Qty] DESC;

--Intermediate queries

--Join the necessary tables to find the total quantity of each pizza category ordered.

Select
	pizza_types.category, sum( order_details.quantity)as [quantity]
From
	pizza_types Join pizzas
on 
	pizza_types.pizza_type_id=pizzas.pizza_type_id Join Order_details
on
	order_details.pizza_id=pizzas.pizza_id
Group by
	pizza_types.category Order by quantity desc;

--Determine the distribution of orders by hour of the day.
SELECT 
    DATEPART(HOUR, time) AS order_hour, 
    COUNT(order_id) AS order_count
FROM 
    orders
GROUP BY 
    DATEPART(HOUR, time)
ORDER BY 
    order_hour ASC;

--Join relevant tables to find the category-wise distribution of pizzas.

Select category, 
	count (name) as [pizza_count]
from 
	pizza_types 
group by
	category;

--Group the orders by date and calculate the average number of pizzas ordered per day.

Select avg (quantity) as [Avg_Qty]
from 
(Select 
	orders.date, sum (order_details.quantity) as [quantity]
from 
	order_details
Join
	orders
on
	order_details.order_id=orders.order_id
group by
	orders.date) as [order_quantity];

--Determine the top 3 most ordered pizza types based on revenue.

SELECT TOP 3
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS [Revenue]
FROM 
    pizza_types
JOIN 
    pizzas
    ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN 
    order_details
    ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 
    pizza_types.name ORDER BY [Revenue] DESC;

--Advanced

--Calculate the percentage contribution of each pizza type to total revenue.
Select
	pizza_types.category,
	(sum (order_details.quantity*pizzas.price)/ 
	(select  round(sum (order_details.quantity*pizzas.price),2) as [Total_Sales]
from order_details 
join pizzas
on pizzas.pizza_id=order_details.pizza_id))*100 as [Revenue]
From pizza_types
Join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
Join Order_details
on Order_details.pizza_id=pizzas.pizza_id
Group by pizza_types.category Order by Revenue desc;
	
--Analyze the cumulative revenue generated over time.
Select 
	date,
Sum (Revenue) over (order by date) as [cumulative_revenue]
from (Select
	orders.date,
sum (order_details.quantity*pizzas.price) as [Revenue]
From order_details
Join pizzas
on order_details.pizza_id=pizzas.pizza_id
Join orders
on orders.order_id=order_details.order_id
group by orders.date) as [Sales];

--Determine the top 3 most ordered pizza types based on revenue for each pizza category.

Select 
	name, revenue
From
	
(Select 
	category,name,revenue,
Rank()
over(partition by category order by revenue desc) as [rn]
from
	
(Select
	pizza_types.category,pizza_types.name,
	sum((order_details.quantity)*pizzas.price) as [Revenue]
from 
	pizza_types 
Join
	pizzas 
on	
	pizza_types.pizza_type_id=pizzas.pizza_type_id 
Join
	order_details 
on
	order_details.pizza_id=pizzas.pizza_id 
Group by
	pizza_types.category,pizza_types.name) as [A]) as [B]
where
	rn<=3;
