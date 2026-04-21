--phase-1 exploratory analysis
 
--1 query total revenue generated bt the food delivery app

select sum(order_amount-discount) as total_revenue 
from orders;

--2 query total order per city
select r.city, count(*) as total_orders
from orders o 
join restaurants r on o.restaurant_id = r.restaurant_id
group by r.city
order by total_orders desc;

--3 query top 10 customers by spending
select c.name, sum(o.order_amount - o.discount) as total_spent
from orders o
join customers c on o.customer_id = c.customer_id
group by c.name
order by total_spent desc
limit 10;

--phase-2 customer segmentation
--4 query customer category (gold/silver/bronze) 
 select customer_id, 
 case 
 when sum(order_amount) >= 1000 then 'Gold'
 when sum(order_amount) >= 500 then 'Silver'
 else 'Bronze'
 end as customer_category
 from orders
    group by customer_id;

--phase-3 restaurant performance 
-- 5 query top 10 restaurants by revenue 
select r.restaurant_name, sum(o.order_amount - o.discount) as revenue
from orders o
join restaurants r on o.restaurant_id = r.restaurant_id
group by r.restaurant_name   
order by revenue desc
limit 10;

--6 query average rating vs revenue
SELECT r.restaurant_name,
       r.rating,
       SUM(o.order_amount) AS revenue
FROM restaurants r
JOIN orders o 
ON r.restaurant_id = o.restaurant_id
GROUP BY r.restaurant_name, r.rating;

--phase-4 delivery agent analysis
--7 query average delivery time per city
SELECT r.city,
       AVG(o.delivery_time) AS avg_delivery_time
FROM orders o
JOIN restaurants r 
ON o.restaurant_id = r.restaurant_id
GROUP BY r.city;

--8 query late deliveries(above 45 minutes)
SELECT order_id, delivery_time
FROM orders
WHERE delivery_time > 45;

--phase-5 payment & discount analysis
--9 query payment method distribution
SELECT payment_method,count(*) AS count
FROM orders
GROUP BY payment_method
ORDER BY count DESC;

--10 query discount impact on revenue
SELECT 
    SUM(order_amount) AS total_revenue,
    SUM(discount) AS total_discount,
    SUM(order_amount - discount) AS final_revenue
FROM orders;

--phase-6 advanced sql
--11 query montly revenue using cte
WITH monthly_revenue AS (
    SELECT 
        month(order_date) AS month,
        SUM(order_amount - discount) AS revenue
    FROM orders
    GROUP BY month
)
SELECT month, revenue
FROM monthly_revenue
ORDER BY month;

--12 query rank restaurants by revenue using window function
SELECT restaurant_name,
       revenue,
       RANK() OVER (ORDER BY revenue DESC) AS rank_position
FROM (
    SELECT r.restaurant_name,
           SUM(o.order_amount) AS revenue
    FROM orders o
    JOIN restaurants r 
    ON o.restaurant_id = r.restaurant_id
    GROUP BY r.restaurant_name
) t;

--13 query above average revenue restaurants(subquery)
SELECT restaurant_name, revenue
FROM (
    SELECT r.restaurant_name,
           SUM(o.order_amount) AS revenue
    FROM orders o
    JOIN restaurants r 
    ON o.restaurant_id = r.restaurant_id
    GROUP BY r.restaurant_name
) t
WHERE revenue > (
    SELECT AVG(total_rev)
    FROM (
        SELECT SUM(order_amount) AS total_rev
        FROM orders
        GROUP BY restaurant_id
    ) avg_table
);

--phase-7 database objects
--14 query create revenue view
CREATE VIEW restaurant_revenue AS
SELECT r.restaurant_name,
       SUM(o.order_amount) AS total_revenue
FROM orders o
JOIN restaurants r 
ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name;

--15 query stored  proceddure :get top N restaurant
CREATE PROCEDURE GetTopRestaurants(IN top_n INT)
SELECT r.restaurant_name,
       SUM(o.order_amount) AS revenue
FROM orders o
JOIN restaurants r 
ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name
ORDER BY revenue DESC
LIMIT top_n;

--phase-8 performance optimization
--16 query index on order_date (for monthly report)
CREATE INDEX idx_order_date ON orders(order_date);

--17 query index on customer name 

CREATE INDEX idx_customer_name ON customers(name);

--18 query index on restaurant name 

CREATE INDEX idx_restaurant_name ON restaurants(restaurant_name);

--phase-9- automation logic


--19 query TRIGGER 1- PREVENT NEGATIVE DISCOUNT


CREATE TRIGGER prevent_negative_discount
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    IF NEW.discount < 0 THEN
        SET NEW.discount = 0;
    END IF;
END ;

--20 query TRIGGER 2- delivery dealy warning


CREATE TRIGGER delivery_warning
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    IF NEW.delivery_time > 45 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Delivery time exceeds 45 minutes!';
    END IF;
END ;