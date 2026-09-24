# Product & Category Management (SQL)

A small relational database project that models an electronics store's **products** and the **categories** they belong to. It demonstrates core SQL skills: table design with constraints, CRUD operations (`INSERT`, `UPDATE`, `DELETE`), `JOIN`s, aggregation with `GROUP BY` / `HAVING`, and subqueries.

---

## Table of Contents

1. [Project Structure](#project-structure)
2. [Database Schema](#database-schema)
3. [Sample Data](#sample-data)
4. [How to Run](#how-to-run)
5. [Operations Demonstrated](#operations-demonstrated)
6. [Queries Explained](#queries-explained)
7. [Notes & Known Issues](#notes--known-issues)

---

## Project Structure

| File | Purpose |
|------|---------|
| `Product & Category Management.sql` | Main script: creates the database, tables, inserts data, and runs all queries |
| `Category.csv` | Category data (4 rows) in CSV form |
| `Product.csv` | Product data in CSV form |

---

## Database Schema

**Database name:** `Task2`

### Entity Relationship

```
┌──────────────────┐         ┌──────────────────────┐
│     Category     │ 1     * │       Product        │
├──────────────────┤─────────├──────────────────────┤
│ Category_ID (PK) │         │ Product_ID (PK)      │
│ Category_Name    │         │ Product_Name         │
│ Description      │         │ Category_ID (FK)     │
└──────────────────┘         │ Price                │
                             │ Stock_Quantity       │
                             └──────────────────────┘
```

One category can contain many products; each product belongs to exactly one category.

### `Category` table

| Column | Type | Constraints |
|--------|------|-------------|
| `Category_ID` | `INT` | Primary key |
| `Category_Name` | `VARCHAR(50)` | `NOT NULL`, `UNIQUE` |
| `Description` | `VARCHAR(255)` | Optional |

### `Product` table

| Column | Type | Constraints |
|--------|------|-------------|
| `Product_ID` | `INT` | Primary key |
| `Product_Name` | `VARCHAR(100)` | `NOT NULL` |
| `Category_ID` | `INT` | `NOT NULL`, foreign key → `Category(Category_ID)` |
| `Price` | `INT` | `NOT NULL`, must be `> 0` (`check_price`) |
| `Stock_Quantity` | `INT` | `NOT NULL`, must be `>= 0` (`check_stock`) |

**Why these constraints matter**

- **Primary keys** guarantee every row can be uniquely identified.
- **`UNIQUE` on `Category_Name`** prevents duplicate categories such as two "Laptop" rows.
- **Foreign key (`link`)** ensures a product can only reference a category that exists.
- **`CHECK` constraints** block invalid data (free or negative-priced items, negative stock).

---

## Sample Data

**4 categories:** Laptop, Mobile, Headphones, Keyboard.

**12 products** are loaded initially (3 per category), for example:

| Category | Products |
|----------|----------|
| Laptop | HP Pavilion, Dell Inspiron 15, Lenovo IdeaPad Slim 3 |
| Mobile | Samsung Galaxy A55, OnePlus Nord CE 4, iPhone 15 |
| Headphones | Sony WH-CH520, JBL Tune 770NC, Boat Rockerz 450 |
| Keyboard | Logitech K380, Redragon K552, HP Wireless Keyboard |

Prices are whole numbers (INR-scale values, e.g. `55000`).

---

## How to Run

**Requirements:** MySQL 8.0.16+ or MariaDB 10.2.1+ (earlier MySQL versions parse but ignore `CHECK` constraints).

### Option 1: MySQL command line

```bash
mysql -u <your_username> -p < "Product & Category Management.sql"
```

### Option 2: MySQL Workbench

1. Open the `.sql` file (File → Open SQL Script).
2. Click the lightning-bolt icon to execute the script.

> **Tip:** Run the script from top to bottom, since later statements depend on earlier ones (tables must exist before data is inserted, and so on). If you re-run it, first execute `DROP DATABASE Task2;` to avoid "already exists" errors.

### Loading from the CSV files (optional)

If you prefer importing instead of using the `INSERT` statements, load `Category.csv` **first**, then `Product.csv`. The order matters because of the foreign key.

---

## Operations Demonstrated

The script walks through a complete data lifecycle:

| Step | Operation | Description |
|------|-----------|-------------|
| 1 | `CREATE DATABASE` / `CREATE TABLE` | Sets up `Task2` with both tables and constraints |
| 2 | `INSERT` | Adds 4 categories and 12 products |
| 3 | `INSERT` (single row) | Adds product 113, *Acer Aspire 5*, at ₹48,000 |
| 4 | `UPDATE` | Changes the price of product 113 to ₹50,000 |
| 5 | `DELETE` | Removes product 113 |

---

## Queries Explained

### 1. Products with their category (`JOIN` + `ORDER BY`)

Combines both tables to show each product beside its category name, sorted by category and then product name.

```sql
SELECT Category.Category_Name, Product.Product_Name,
       Product.Price, Product.Stock_Quantity
FROM Category
JOIN Product ON Category.Category_ID = Product.Category_ID
ORDER BY Category.Category_Name, Product.Product_Name;
```

### 2. Product count per category (`GROUP BY`)

Groups products by category and counts them. This returns 3 for each category once product 113 has been deleted.

```sql
SELECT Category.Category_Name, COUNT(Product.Product_ID) AS Product_Count
FROM Category
JOIN Product ON Category.Category_ID = Product.Category_ID
GROUP BY Category.Category_ID, Category.Category_Name
ORDER BY Category.Category_Name;
```

### 3. Categories with more than 5 products (`HAVING`)

`HAVING` filters *after* grouping (unlike `WHERE`, which filters rows *before*). With the current data, no category has more than 5 products, so this returns **no rows**. It is written twice in the script: once with full table names and once with aliases (`c`, `p`).

### 4. Most expensive product (subquery)

The inner query finds the highest price; the outer query returns the product(s) matching it.

```sql
SELECT Product_Name, Price
FROM Product
WHERE Price = (SELECT MAX(Price) FROM Product);
```

**Expected result:** `iPhone 15` at `65000`.

---

## Notes & Known Issues

1. **Syntax error in the script.** In the first product-count query, the line `Category.Category_Name=,` contains a stray `=`. It should be `Category.Category_Name,`. As written, MySQL will reject that statement.
2. **CSV vs. SQL mismatch.** `Product.csv` contains 13 rows, including product 113 (*Acer Aspire 5*, price `50000`), which is the state *after* the `UPDATE` but *before* the `DELETE` in the SQL script. After running the full script, the database holds only 12 products. Remove row 113 from the CSV if you want the two to match.
3. **Duplicate queries.** The "categories with more than 5 products" and "product count per category" queries each appear twice. This is harmless, but one copy of each can be removed.
4. **Data type for `Price`.** `INT` is fine for whole-number prices. For real-world use with decimals, consider `DECIMAL(10,2)`.

---

## Possible Extensions

- Add an `Orders` / `Order_Items` table to track sales.
- Use `LEFT JOIN` to include categories that have no products.
- Add `ON DELETE` / `ON UPDATE` rules to the foreign key.
- Create a view for a low-stock report (e.g. `Stock_Quantity < 15`).
