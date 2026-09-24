CREATE DATABASE Task2;
USE Task2;

CREATE TABLE Category (
    Category_ID INT PRIMARY KEY,
    Category_Name VARCHAR(50) NOT NULL UNIQUE,
    Description VARCHAR(255)
);

CREATE TABLE Product (
    Product_ID INT PRIMARY KEY,
    Product_Name VARCHAR(100) NOT NULL,
    Category_ID INT NOT NULL,
    Price INT NOT NULL,
    Stock_Quantity INT NOT NULL,
    CONSTRAINT check_price CHECK (Price > 0),
    CONSTRAINT check_stock CHECK (Stock_Quantity >= 0),
    CONSTRAINT link FOREIGN KEY (Category_ID)
        REFERENCES Category(Category_ID)
);

INSERT INTO Category
(Category_ID, Category_Name, Description)
VALUES
(1, 'Laptop', 'Portable computers'),
(2, 'Mobile', 'Smartphones'),
(3, 'Headphones', 'Audio listening devices'),
(4, 'Keyboard', 'Computer keyboards');
SELECT * FROM Category;

INSERT INTO Product
(Product_ID, Product_Name, Category_ID, Price, Stock_Quantity)
VALUES
(101, 'HP Pavilion', 1, 55000, 10),
(102, 'Dell Inspiron 15', 1, 60000, 15),
(103, 'Lenovo IdeaPad Slim 3', 1, 52000, 12),
(104, 'Samsung Galaxy A55', 2, 32000, 20),
(105, 'OnePlus Nord CE 4', 2, 25000, 18),
(106, 'iPhone 15', 2, 65000, 8),
(107, 'Sony WH-CH520', 3, 4500, 25),
(108, 'JBL Tune 770NC', 3, 5500, 14),
(109, 'Boat Rockerz 450', 3, 1800, 30),
(110, 'Logitech K380', 4, 2800, 22),
(111, 'Redragon K552', 4, 3000, 16),
(112, 'HP Wireless Keyboard', 4, 1800, 20);
SELECT * FROM Product;

INSERT INTO Product
(Product_ID, Product_Name, Category_ID, Price, Stock_Quantity)
VALUES
(113, 'Acer Aspire 5', 1, 48000, 10);
SELECT * FROM Product;

UPDATE Product
SET Price = 50000
WHERE Product_ID = 113;

SELECT * FROM Product
WHERE Product_ID = 113;

DELETE FROM Product
WHERE Product_ID = 113;
SELECT * FROM Product;

SELECT
    Category.Category_Name,
    Product.Product_Name,
    Product.Price,
    Product.Stock_Quantity
FROM Category
JOIN Product
ON Category.Category_ID = Product.Category_ID
ORDER BY Category.Category_Name, Product.Product_Name;

SELECT
    Category.Category_Name=,
    COUNT(Product.Product_ID) AS Product_Count
FROM Category
JOIN Product
ON Category.Category_ID = Product.Category_ID
GROUP BY Category.Category_ID, Category.Category_Name
ORDER BY Category.Category_Name;

SELECT
    Category.Category_Name,
    COUNT(Product.Product_ID) AS Product_Count
FROM Category
JOIN Product
ON Category.Category_ID = Product.Category_ID
GROUP BY Category.Category_ID, Category.Category_Name
HAVING COUNT(Product.Product_ID) > 5;

SELECT
    Product_Name,
    Price
FROM Product
WHERE Price = (
    SELECT MAX(Price)
    FROM Product
);

SELECT
    c.Category_Name,
    COUNT(p.Product_ID) AS Product_Count
FROM Category c
JOIN Product p
ON c.Category_ID = p.Category_ID
GROUP BY c.Category_ID, c.Category_Name
HAVING COUNT(p.Product_ID) > 5;

SELECT
    Category.Category_Name,
    COUNT(Product.Product_ID) AS Product_Count
FROM Category
JOIN Product
ON Category.Category_ID = Product.Category_ID
GROUP BY Category.Category_ID, Category.Category_Name
ORDER BY Category.Category_Name;