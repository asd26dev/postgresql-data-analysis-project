-- Create Database
CREATE DATABASE OnlineBookstore;

-- Switch to the database
\c OnlineBookstore;

-- Create Tables
DROP TABLE IF EXISTS Books;
CREATE TABLE Books (
    Book_ID SERIAL PRIMARY KEY,
    Title VARCHAR(100),
    Author VARCHAR(100),
    Genre VARCHAR(50),
    Published_Year INT,
    Price NUMERIC(10, 2),
    Stock INT
);
DROP TABLE IF EXISTS customers;
CREATE TABLE Customers (
    Customer_ID SERIAL PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(15),
    City VARCHAR(50),
    Country VARCHAR(150)
);
DROP TABLE IF EXISTS orders;
CREATE TABLE Orders (
    Order_ID SERIAL PRIMARY KEY,
    Customer_ID INT REFERENCES Customers(Customer_ID),
    Book_ID INT REFERENCES Books(Book_ID),
    Order_Date DATE,
    Quantity INT,
    Total_Amount NUMERIC(10, 2)
);

SELECT * FROM Books;
SELECT * FROM Customers;
SELECT * FROM Orders;


-- Import Data into Books Table
COPY Books(Book_ID, Title, Author, Genre, Published_Year, Price, Stock) 
FROM 'C:\Users\LENOVO\Desktop\A... java  notes\Skill Course 2026\SQL\SQL Project Practice File\Practice Files SQL Projects\Books.csv' 
CSV HEADER;

-- Import Data into Customers Table
COPY Customers(Customer_ID, Name, Email, Phone, City, Country) 
FROM 'C:\Users\LENOVO\Desktop\A... java  notes\Skill Course 2026\SQL\SQL Project Practice File\Practice Files SQL Projects\Customers.csv' 
CSV HEADER;

-- Import Data into Orders Table
COPY Orders(Order_ID, Customer_ID, Book_ID, Order_Date, Quantity, Total_Amount) 
FROM 'C:\Users\LENOVO\Desktop\A... java  notes\Skill Course 2026\SQL\SQL Project Practice File\Practice Files SQL Projects\Orders.csv' 
CSV HEADER;


-- 1) Retrieve all books in the "Fiction" genre:

SELECT title, genre
FROM BOOKS
WHERE genre = 'Fiction';

-- 2) Find books published after the year 1950

SELECT title,  Published_Year
FROM books
WHERE Published_year > 1950;

-- 3) List all customers from the Canada

SELECT name, Country
FROM customers
WHERE country = 'Canada';

-- 4) Show orders placed in November 2023

SELECT * FROM orders
WHERE Order_Date BETWEEN '2023-11-01' AND '2023-11-30';

-- 5) Retrieve the total stock of books available

SELECT SUM(stock) FROM BOOKS;

SELECT SUM(Stock) AS Total_Stock FROM Books;

-- 6) Find the details of the most expensive book

-- THIS IS MY TRY
SELECT *,
RANK() OVER (ORDER BY price desc) AS price_order
FROM BOOKS
WHERE price_order = 1;


-- Using a Subquery (Derived Table)

SELECT *
FROM (
    SELECT *,
           RANK() OVER (ORDER BY price DESC) AS price_order
    FROM BOOKS
) AS ranked_books
WHERE price_order = 1;

-- Using a Common Table Expression (CTE)

WITH ranked_books AS (
    SELECT *,
           RANK() OVER (ORDER BY price DESC) AS price_order
    FROM BOOKS
)
SELECT *
FROM ranked_books
WHERE price_order = 1;

-- EXPECTED ANSWER
SELECT * FROM Books ORDER BY Price DESC LIMIT 1;


-- 7) Show all customers who ordered more than 1 quantity of a book

SELECT customer_id, quantity
FROM ORDERS
WHERE quantity > 1;


-- gemini

SELECT 
    o.customer_id,
    c.name,
    o.quantity
FROM ORDERS o
JOIN CUSTOMERS c 
    ON o.customer_id = c.customer_id
WHERE o.quantity > 1;
-- EXPECTED ANSWER
SELECT * FROM Orders WHERE Quantity > 1;
-- 8) Retrieve all orders where the total amount exceeds $20
SELECT * FROM ORDERS WHERE TOTAL_AMOUNT > 20;
-- 9) List all genres available in the Books table:
SELECT GENRE FROM BOOKS WHERE GENRE DISTINCT  ;
SELECT DISTINCT Genre FROM Books;
-- 10) Find the book with the lowest stock
SELECT * FROM BOOKS ORDER BY STOCK LIMIT  1;
SELECT * FROM Books ORDER BY Stock ASC LIMIT 1;
-- 11) Calculate the total revenue generated from all orders
SELECT SUM(TOTAL_AMOUNT) AS TOTAL_REVENUE FROM ORDERS;
SELECT SUM(Total_Amount) AS Total_Revenue FROM Orders;
--Advance Queries
--1) Retrieve the total number of books sold for each genre

--
SELECT B.GENRE, SUM(QUANTITY)
FROM BOOKS B
JOIN ORDERS O
	ON O.CUSTOMER_ID = B.BOOK_ID

	GROUP BY B.GENRE,SUM(QUANTITY)


	-- GEMINI

SELECT 
    b.genre,
    SUM(o.quantity) AS total_books_sold
FROM BOOKS b
JOIN ORDERS o 
    ON o.book_id = b.book_id
GROUP BY b.genre
ORDER BY total_books_sold DESC;

-- 
SELECT b.Genre, 
SUM(o.Quantity) AS Total_Books_Sold
FROM Orders o
JOIN Books b 
    ON o.Book_ID = b.Book_ID
GROUP BY b.Genre;

--2) Find the average price of books in the "Fantasy" genre
SELECT GENRE , 
AVG(PRICE)
FROM BOOKS
WHERE GENRE = 'Fantasy'
group by genre
;


-- 
SELECT AVG(Price) AS Average_Price
FROM Books
WHERE Genre = 'Fantasy';

--3) List customers who have placed at least 2 orders

SELECT CUSTOMER_ID, QUANTITY  
FROM ORDERS 
WHERE QUANTITY >=2;   -- Filters item quantity, not order count SO WRONG

SELECT Customer_ID, COUNT(Order_ID) AS Order_Count
FROM Orders
GROUP BY Customer_ID
HAVING COUNT(Order_ID) >= 2;


--4) Find the most frequently ordered book

SELECT Book_ID, COUNT(Order_ID) AS Order_Count
FROM Orders
GROUP BY Book_ID
ORDER BY Order_Count DESC LIMIT 1;





--5) Show the top 3 most expensive books of 'Fantasy' Genre


SELECT  GENRE ,PRICE AS TOP_3_EXPENSIVE
FROM BOOKS
WHERE GENRE = 'Fantasy'
ORDER BY PRICE DESC LIMIT 3;
--
SELECT * FROM Books 
WHERE Genre = 'Fantasy'
ORDER BY Price DESC LIMIT 3;


--6) Retrieve the total quantity of books sold by each author


SELECT b.AUTHOR, SUM(o.quantity) AS total_quantity_sold
FROM BOOKS b
JOIN ORDERS o
 ON o.book_id = b.book_id
GROUP BY b.AUTHOR
ORDER BY total_quantity_sold DESC;






--7) List the cities where customers who spent over $30 are located

SELECT c.city, o.total_amount
FROM CUSTOMERS c
JOIN ORDERS o
 ON o.customer_id = c.customer_id
WHERE total_amount > 30;

SELECT DISTINCT c.City
FROM Orders o
JOIN Customers c ON o.Customer_ID = c.Customer_ID
WHERE o.Total_Amount > 30;



--8) Find the customer who spent the most on orders


SELECT c.name, SUM(o.total_amount) AS amount_spent_by_customer
FROM CUSTOMERS c
JOIN ORDERS o 
 ON o.customer_id = c.customer_id
GROUP BY c.name
ORDER BY amount_spent_by_customer DESC LIMIT 1;

--
SELECT c.Customer_ID, c.Name, SUM(o.Total_Amount) AS Total_Spent
FROM Orders o
JOIN Customers c ON o.Customer_ID = c.Customer_ID
GROUP BY c.Customer_ID, c.Name
ORDER BY Total_Spent DESC LIMIT 1;





--9) Calculate the stock remaining after fulfilling all orders

SELECT b.Book_ID, b.Title, b.Stock - COALESCE(SUM(o.Quantity), 0) AS Remaining_Stock
FROM Books b
LEFT JOIN Orders o ON b.Book_ID = o.Book_ID
GROUP BY b.Book_ID;


SELECT b.Book_ID, b.Title, b.Stock, COALESCE(SUM(o.Quantity), 0) AS order_quantity, 
		b.Stock - COALESCE(SUM(o.Quantity), 0) AS Remaining_stock
FROM Books b
LEFT JOIN Orders o ON b.Book_ID = o.Book_ID
GROUP BY b.Book_ID;

