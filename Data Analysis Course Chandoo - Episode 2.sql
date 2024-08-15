-- 10 Practical Advanced Queries


# The # symbol can also be used for single line comments
-- When we use double dash symbol we need to ensure that we place a comma after the second dash for MySQL to recognize the pattern.
/* This syntax is used for
	multiple line comments */
    
    
USE sakila;

# If we want to see how the ERD of our database looks like we can use keyboard shortcut Ctrl R or Go to Database -> Reverse engineer. Then just choose the schema you like.

# 1) All films with PG-13 films with rental rate of 2.99 or lower.

SELECT * FROM film; -- Let's take a look at all the films that we have.

SELECT *
FROM film
WHERE rating = 'PG-13' AND rental_rate <= 2.99; # We can use = equal operator instead of the like operator as we want to get the exact match

SELECT *
FROM film f # When we use aliases we need to refer to them. We can no longer use the actual name.
WHERE f.rating LIKE 'PG-13' AND f.rental_rate <= 2.99; # Returns the very same output. 

SELECT *
FROM film
WHERE rating REGEXP '^PG-13$' AND rental_rate <= 2.99; # We can also use REGEX to get what we want. ^ means that the sting needs to start with the given value and the $ means that it needs to also end with it.

# 2)  All films that have deleted scenes

SELECT *
FROM film f
WHERE f.special_features LIKE '%deleted scenes%';

SELECT *
FROM film f
WHERE f.special_features REGEXP 'deleted scenes';

# EER - Enhanced Entity Relationship (Diagram) is an abbreviation for EERD and represents an enhanced version of the ERD diagram.

# The output pane at the bottom shows the status of queries and operations we executed. In case of a query it also shows the count of rows that were returned. When we limit the output, even if the query could return
# more records the output pane will still just show the limited count

SELECT *
FROM film f
WHERE f.special_features LIKE '%deleted scenes%' AND f.title LIKE 'c%';

# 3) All active customers

SELECT *
FROM customer c
WHERE c.active = 1;

SELECT COUNT(*)
FROM customer c
WHERE c.active = 1;

SELECT COUNT(customer_id)
FROM customer c
WHERE c.active = 1;

# 4) Names of customers who rented a movie on 26th July 2005.alter

SELECT r.rental_id, r.rental_date, c.customer_id, CONCAT( c.first_name, ' ',  c.last_name ) AS "Full name" -- The CONCAT() function in MySQL is not limited to two arguments only.
FROM rental r INNER JOIN customer c ON r.customer_id = c.customer_id
WHERE DATE(r.rental_date) = '2005-07-26'; -- Use YYYY-MM-DD for MySQL. This is the preferred date format

# 5) Distinct names of customers who rented a movie on the 26th July 2005

SELECT DISTINCT c.customer_id, CONCAT( c.first_name, ' ',  c.last_name ) AS "Full name" 
FROM rental r INNER JOIN customer c ON r.customer_id = c.customer_id
WHERE DATE(r.rental_date) = '2005-07-26';

# HW1) How many distinct last names we have in our data?

SELECT DISTINCT COUNT(last_name)
FROM customer;

# 6) How many rentals we do on each day?

SELECT DATE( rental_date ) AS 'Rental date', COUNT( rental_id ) AS 'Rental count'
FROM rental
GROUP BY DATE( rental_date )
ORDER BY COUNT( rental_id ) DESC; -- aliasy nie działają


# HW2) What is the busiest day in our business so far?

WITH rentals_by_date AS
	( SELECT DATE( rental_date ) AS RentalDate, COUNT( rental_id ) AS 'Rental count'
		FROM rental
        GROUP BY DATE( rental_date )
        ORDER BY COUNT( rental_id ) DESC
        LIMIT 1
	)
SELECT RentalDate AS 'Renatal date'
FROM rentals_by_date;

# HW3) How many films do we rent each weekday on average?

WITH helper AS 
	( SELECT DATE( rental_date ) AS RentalDate, COUNT( rental_id ) AS Cnt
		FROM rental
        GROUP BY RentalDate
	)
SELECT DAYOFWEEK( RentalDate ) AS '#', DAYNAME( RentalDate ) AS 'Weekday', ROUND( AVG( Cnt ), 2 ) AS 'Average rentals'
FROM helper
GROUP BY DAYOFWEEK( RentalDate ), DAYNAME( RentalDate )
ORDEr BY DAYOFWEEK( RENTALDate );

# 7) All the Sci-Fi films in our database

SELECT * FROM film_category;
SELECT * FROM category;

UPDATE film_category
SET film_id = 1
WHERE film_id = 2 AND category_id = 11; -- I needed to see how the query will behave knowing that some films can be assigned to many categories

SELECT f.title AS "Film title", c.name AS "Category" -- It turns out that when a film has multiple catoegories assigned, the film will appear as many times as it has categories - thanks to the film_category table and connection
FROM film f INNER JOIN film_category fc ON f.film_id = fc.film_id INNER JOIN category c ON fc.category_id = c.category_id
WHERE c.name = "Sci-Fi"
ORDER BY 1 ASC, 2 ASC;

# 8) Customers and how many movies they rented from us.

SELECT c.customer_id AS "Customer", CONCAT( c.first_name, " ", c.last_name ) AS "Customer", c.email AS "Customer e-mail", COUNT( r.rental_id ) AS "Rental count"
FROM customer c LEFT OUTER JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id
ORDER BY COUNT( r.rental_id ) DESC; -- When we are sorting ASCENDING we do not have to write ASC, the default is ASC.

# 9) Which movies should we discontinue from our catalogue (less than 6 lifetime rentals)?

SELECT f.title AS 'Film', COUNT( r.rental_id ) AS 'Rental count'
FROM film f LEFT OUTER JOIN inventory i ON f.film_id = i.film_id LEFT OUTER JOIN rental r ON i.inventory_id = r.inventory_id -- We need two LEFT OUTER JOINS so what we are sure that films that were never rented will also be included.
GROUP BY f.title
HAVING COUNT( r.rental_id ) <= 5
ORDER BY 2;

INSERT INTO film
	VALUES ( 1001, "Test", "No desc", 2024, 1, NULL, 3, 5.99, 60, 20.00, "PG-13", "Commentaries", NOW() );

with low_rentals as 
	(select i.film_id, count(*) AS cnt
	from rental r
    right join inventory i on i.inventory_id = r.inventory_id
	group by i.film_id
	having count(*)<=5)
select low_rentals.film_id, f.title, low_rentals.cnt
 from low_rentals
inner join film f on f.film_id = low_rentals.film_id; -- This CTE example will not show films with zero rentals, as we groupped on the inventory film id where only films that were rented are listed.

# 10) Which movies have not been retured yet?

SELECT c.customer_id AS 'Customer ID', c.email AS 'Customer e-mail', r.rental_date AS 'Rental date', i.inventory_id AS 'Inventory ID', f.title AS 'Film'
FROM customer c INNER JOIN rental r ON c.customer_id = r.customer_id INNER JOIN inventory i ON r.inventory_id = i.inventory_id INNER JOIN film f ON f.film_id = i.film_id
WHERE r.return_date IS NULL
ORDER BY 1 ASC;

# HW4) How much money and rentals we make for Store 1 by day? 

SELECT * FROM store;
SELECT * FROM film;
SELECT DATE(r.rental_date) AS "Date", COUNT(r.rental_id) AS "Total rentals", SUM( f.rental_rate ) AS "Total Sales"
FROM rental r INNER JOIN inventory i ON r.inventory_id = i.inventory_id INNER JOIN film f ON i.film_id = f.film_id INNER JOIN staff s ON r.staff_id = s.staff_id
WHERE s.store_id = 1
GROUP BY DATE(r.rental_date)
ORDER BY 3 DESC;

-- Check:
SELECT f.film_id, f.rental_rate
FROM rental r INNER JOIN staff s ON r.staff_id = s.staff_id INNER JOIN inventory i ON r.inventory_id = i.inventory_id INNER JOIN film f ON f.film_id = i.film_id
WHERE DATE(rental_date) = "2005-05-24" AND s.store_id = 1;

# HW5) What are the three top earning days so far at store 1 (refer to the query above)?

WITH sales_by_date_store1 AS
	( SELECT DATE(r.rental_date) AS "Date", COUNT(r.rental_id) AS "Total rentals", SUM( f.rental_rate ) AS "Total Sales"
	  FROM rental r INNER JOIN inventory i ON r.inventory_id = i.inventory_id INNER JOIN film f ON i.film_id = f.film_id INNER JOIN staff s ON r.staff_id = s.staff_id
      WHERE s.store_id = 1
      GROUP BY DATE(r.rental_date)
      ORDER BY 3 DESC
	)
SELECT * FROM sales_by_date_store1
LIMIT 3; -- 31.07.2005, 02.08.2005 and 22.08.2005

-- Does Power Query send actual sql queries to the data source or only when we specify so within the connector (database connector)
/*

In Power Query (used in tools like Microsoft Power BI and Excel), the handling of M code and SQL is distinct but interrelated, depending on the context of your data source.

Power Query M Code vs. SQL
Power Query M Code
Purpose: M code is used for defining data transformation queries in Power Query. It allows you to build and manipulate data queries through a functional language that provides a range of data transformation capabilities.

Execution: When you create a query in Power Query using the M language, it operates on the data in-memory before loading it into the destination (e.g., Power BI data model, Excel worksheet).

SQL Queries
Purpose: SQL queries are used for querying and manipulating data directly within a relational database system. SQL can be used to fetch data, create or alter database structures, and perform other database-specific operations.

Execution: When using a database connector in Power Query, you can write custom SQL queries to retrieve or manipulate data directly from the database. This approach leverages the database engine's capabilities and executes SQL queries directly against the database.

Interaction Between M Code and SQL
Native Queries and SQL:

When connecting to a relational database in Power Query, you have the option to write SQL queries directly. This is useful when you want to perform complex queries or operations that are best handled by the database engine before data is loaded into Power Query.
These custom SQL queries are executed directly against the database server, and the results are fetched into Power Query. This approach often improves performance because it offloads complex query execution to the database server.
M Code and Database Queries:

When you use Power Query to connect to a database without writing custom SQL, Power Query generates SQL queries based on the transformations you apply using the M code.
Power Query attempts to push as much of the transformation logic to the database server as possible to leverage the database's processing power. This is known as "query folding" or "query delegation."
Query Folding: Power Query translates your M code transformations into SQL queries, which are executed on the database server. The results are then returned to Power Query for further processing if needed. This process is largely hidden from the user.
Transformations and Data Load:

Once data is retrieved from the database (either through direct SQL queries or via generated SQL), further transformations are applied using M code in Power Query. These transformations occur in-memory and are not translated back into SQL.
Summary
M Code: Used for data transformations in Power Query and operates in-memory once data is loaded.
SQL Queries: Can be used to retrieve or manipulate data directly from the database when using a database connector, either through custom SQL or generated by Power Query.
Interaction: When possible, Power Query attempts to push transformations to the database via SQL (query folding) to improve performance. This SQL generation and execution are typically hidden from the user, while the M code defines transformations after data retrieval.
In essence, while M code and SQL are used in different stages of data processing, Power Query leverages SQL for efficient data retrieval and transformation and uses M code for additional in-memory data manipulation.

*/


