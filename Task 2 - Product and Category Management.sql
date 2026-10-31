USE flipkart_database;

-- ============ 1. CREATE TABLES ============

-- Category table (new in Task 2)
CREATE TABLE category (
    category_id   INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description   VARCHAR(255),
    CONSTRAINT chk_category_name CHECK (CHAR_LENGTH(TRIM(category_name)) > 0)
);

-- Product table: add the Category_ID column (nullable for now, because the 10 products from Task 1 have no category yet)
ALTER TABLE product
    ADD COLUMN category_id INT AFTER product_name;

-- ============ 2. CONSTRAINTS ============
ALTER TABLE product
    ADD CONSTRAINT fk_product_category
    FOREIGN KEY (category_id) REFERENCES category(category_id);

-- ============ 3. INSERT DATA ============

INSERT INTO category (category_name, description) VALUES
('Electronics',    'Mobiles, audio devices and accessories'),        
('Fashion',        'Clothing and footwear for men and women'),       
('Home & Kitchen', 'Cookware, appliances and household items'),      
('Books',          'Fiction, non-fiction and self-help books'),      
('Sports',         'Sports equipment and fitness gear'),             
('Beauty',         'Skin care and personal care products'),          
('Toys',           'Toys and games for children'),                   
('Grocery',        'Packaged food and organic groceries');           

UPDATE product SET category_id = 1 WHERE product_id IN (1, 6);   
UPDATE product SET category_id = 2 WHERE product_id = 2;         
UPDATE product SET category_id = 3 WHERE product_id IN (3, 7);   
UPDATE product SET category_id = 4 WHERE product_id = 4;         
UPDATE product SET category_id = 5 WHERE product_id = 5;         
UPDATE product SET category_id = 6 WHERE product_id = 8;         
UPDATE product SET category_id = 7 WHERE product_id = 9;         
UPDATE product SET category_id = 8 WHERE product_id = 10;        

ALTER TABLE product MODIFY category_id INT NOT NULL;

INSERT INTO product (product_name, category_id, price, stock_quantity, seller_id) VALUES
('Bluetooth Speaker',        1, 1999.00,  70, 6),
('Smart Watch',              1, 2499.00,  45, 1),
('Power Bank 20000mAh',      1, 1299.00, 100, 6),
('USB-C Fast Charger 65W',   1,  999.00,  85, 1),
('Women Kurti',              2,  699.00, 120, 2),
('Running Shoes',            2, 2299.00,  60, 2),
('Steel Water Bottle 1L',    3,  399.00, 150, 3),
('Atomic Habits (Book)',     4,  499.00,  90, 4),
('Yoga Mat',                 5,  699.00,  75, 5),
('Moisturizer 200ml',        6,  349.00, 140, 8);

DESCRIBE category;
DESCRIBE product;
SELECT * FROM category;
SELECT * FROM product;

-- ============ 4. CRUD OPERATIONS ============

INSERT INTO category (category_name, description)
VALUES ('Stationery', 'Pens, notebooks and office supplies');
SET @new_category_id = LAST_INSERT_ID();

INSERT INTO product (product_name, category_id, price, stock_quantity, seller_id)
VALUES ('Gel Pen Pack (10)', @new_category_id, 120.00, 200, 4);
SET @new_product_id = LAST_INSERT_ID();

-- ---- READ (SELECT) ----
SELECT * FROM category;
SELECT product_id, product_name, price, stock_quantity FROM product WHERE price > 1000;
SELECT p.product_id, p.product_name, c.category_name, p.price, p.stock_quantity
FROM product p
JOIN category c ON p.category_id = c.category_id
WHERE p.product_id = @new_product_id;

-- ---- UPDATE ----
UPDATE product  SET price = 140.00 WHERE product_id = @new_product_id;
UPDATE product  SET price = 1799.00 WHERE product_id = 11;                    
UPDATE product  SET stock_quantity = stock_quantity + 25 WHERE product_id = 12; 
UPDATE category SET description = 'Packaged food, staples and organic groceries' WHERE category_id = 8;

-- ---- DELETE ----
DELETE FROM product  WHERE product_id  = @new_product_id;
DELETE FROM category WHERE category_id = @new_category_id;

-- ============ 5. CATEGORY-WISE QUERIES ============

-- 5.1 Display products category-wise
SELECT c.category_name, p.product_id, p.product_name, p.price, p.stock_quantity
FROM category c
JOIN product p ON c.category_id = p.category_id
ORDER BY c.category_name, p.product_name;

-- 5.2 Count products in each category
SELECT c.category_name, COUNT(p.product_id) AS total_products
FROM category c
LEFT JOIN product p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
ORDER BY total_products DESC, c.category_name;

-- 5.3 Highest-priced product (overall)
SELECT p.product_id, p.product_name, c.category_name, p.price
FROM product p
JOIN category c ON p.category_id = c.category_id
WHERE p.price = (SELECT MAX(price) FROM product);

-- 5.3b Highest-priced product in each category
SELECT c.category_name, p.product_name, p.price
FROM product p
JOIN category c ON p.category_id = c.category_id
WHERE p.price = (SELECT MAX(p2.price) FROM product p2 WHERE p2.category_id = p.category_id)
ORDER BY c.category_name;

-- 5.4 Categories having more than 5 products
SELECT c.category_name, COUNT(p.product_id) AS total_products
FROM category c
JOIN product p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
HAVING COUNT(p.product_id) > 5;

-- 5.5 Average product price (overall)
SELECT ROUND(AVG(price), 2) AS average_price FROM product;

-- 5.5b Average product price in each category
SELECT c.category_name, ROUND(AVG(p.price), 2) AS average_price
FROM category c
JOIN product p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
ORDER BY average_price DESC;

-- 5.6 Category-wise summary (used for the analysis report in the document)
SELECT c.category_name,
       COUNT(p.product_id)          AS total_products,
       MIN(p.price)                 AS lowest_price,
       MAX(p.price)                 AS highest_price,
       ROUND(AVG(p.price), 2)       AS average_price,
       SUM(p.stock_quantity)        AS total_stock
FROM category c
JOIN product p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
ORDER BY total_products DESC, c.category_name;