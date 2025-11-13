-- Challenge 03 – Customers and Orders
CREATE SCHEMA IF NOT EXISTS c03_customers_orders;
SET search_path TO c03_customers_orders,public;

DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS expected_output CASCADE;

-- 1️⃣ Customers table
CREATE TABLE customers (
    id BIGINT PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    city TEXT,
    address TEXT,
    phone_number TEXT
);

-- 2️⃣ Orders table
CREATE TABLE orders (
    id BIGINT PRIMARY KEY,
    cust_id BIGINT,
    order_date DATE,
    order_details TEXT,
    total_order_cost BIGINT
);

-- 3️⃣ Expected output
CREATE TABLE expected_output (
    first_name TEXT,
    last_name TEXT,
    city TEXT,
    order_details TEXT
);

-- 🧩 Seed customers
INSERT INTO customers (id, first_name, last_name, city, address, phone_number) VALUES
(8,  'John',   'Joseph',  'San Francisco', '123 Market St', '928-386-8164'),
(7,  'Jill',   'Michael', 'Austin',         '52 South Ln',   '813-297-0692'),
(4,  'William','Daniel',  'Denver',         '9 W St',        '813-368-1200'),
(5,  'Henry',  'Jackson', 'Miami',          '71 Ocean Dr',   '808-601-7513'),
(13, 'Emma',   'Isaac',   'Miami',          '45 Pine Ave',   '808-690-5201'),
(3,  'Eva',    'Lucas',   'Arizona',        '64 Desert Rd',  '801-333-9087'),
(9,  'Farida', 'Joseph',  'San Francisco',  '9 Bay St',      '928-386-8164');

-- 🧩 Seed orders
INSERT INTO orders (id, cust_id, order_date, order_details, total_order_cost) VALUES
(1, 3, '2019-03-04', 'Coat', 100),
(2, 3, '2019-03-01', 'Shoes', 80),
(3, 3, '2019-03-07', 'Skirt', 30),
(4, 7, '2019-02-01', 'Coat', 25),
(5, 7, '2019-03-10', 'Shoes', 80);

-- 🧩 Expected output – derived from LEFT JOIN logic
INSERT INTO expected_output (first_name, last_name, city, order_details)
SELECT c.first_name, c.last_name, c.city, o.order_details
FROM customers c
LEFT JOIN orders o ON o.cust_id = c.id
ORDER BY c.first_name, o.order_details;
