create  DATABASE food_app_project;
use food_app_project;

--create table  customers where colunms are- customer_id, name, city, signup date, gender
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(100),
    signup_date DATE,
    gender varchar(10)
);

-- 2 create table resturants 
CREATE TABLE restaurants (
    restaurant_id INT PRIMARY KEY,
    restaurant_name VARCHAR(255),
    city VARCHAR(255),
    cuisine VARCHAR(100),
    rating decimal(3, 2)
);



-- 3 create table delivery agents
CREATE TABLE delivery_agents (
    agent_id INT PRIMARY KEY,
    agent_name VARCHAR(255),
    city VARCHAR(255),
    joining_date DATE,
    rating decimal(3, 2)
     
);

-- 4 create table orders
create table orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    order_date DATE,
    order_amount decimal(10, 2),
    discount decimal(5, 2),
    payment_method varchar(50),
    delivery_time int,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

-- 5 create table order items
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    item_name VARCHAR(255),
    quantity INT,
    price decimal(10, 2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);