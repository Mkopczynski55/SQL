-- Lesson 1 --
/* Key concepts:
1. Database - a structured collection of data that is stored and accessed electronically from a computer system.
   The primary purpose of a database is to organize, store, and retrieve large amounts of data efficiently.
   There are several types of databases:
    a) Relational databases - these use a table-based format and SQL for data manipulation. For example MySQL, Oracle, PostgreSQL
	b) NoSQL databases - these are designed for a specific data models such as document, key-value, graph stores. For example: MongoDB, Cassandra

2. DBMS - Database Managemnet System is a software that interacts with the database, allowing users to create, read,
   update, and delete data. Examples of DBMS include MySQL, Oracle
   DBMS often come with sophisticated Design and Administration Tools - softwares that an actual user uses to
   work with the data inside databases. For example: MySQL Workbench, Oracle SQL Developer.
   
3. Schema - a schema is a different name for a table.

4. sakila and world databases - preinstalled databases that come as sample databases with the installation
of MySQL. MySQL also offers an easy way to display a limited number of returned rows from a query.

5. CTE (Common Table Expressions) -  Common Table Expression (CTE) is a temporary result set in SQL that you can reference within a SELECT,
INSERT, UPDATE, or DELETE statement. It is defined using the WITH keyword and can be used to simplify complex queries, especially those
involving recursive data or multiple references to the same subquery. Example below:
*/
WITH cte AS 
( SELECT * FROM sakila.customer 
	WHERE customer_id < 20
)
SELECT * FROM cte
	WHERE store_id = 1;
    
/*
6. CRUD operations - CRUD stands for Create, Read, Update, and Delete.
These are the four basic operations that can be performed on any data or resource, typically in the context of database management and persistent storage.

Create: Adds new data or a new resource.
Read: Retrieves existing data or resource.
Update: Modifies existing data or resource.
Delete: Removes existing data or resource.

*/

SELECT title, release_year "Release Year"  FROM sakila.film; -- SELECT title, release_year AS "Release Year" FROM sakila.film

SELECT CONCAT( UPPER (SUBSTRING( title, 1, 1 ) ), LOWER( SUBSTRING( title, 2 ) ) ) AS "Title", release_year  "Release Year" FROM sakila.film
	WHERE title LIKE "The%";
    
SELECT title, release_year, length FROM sakila.film
ORDER BY 3 DESC; -- ORDER BY length DESC


SELECT * FROM sakila.rental
	WHERE rental_date >= "2005-05-25 00:00:00" AND rental_date <= "2005-05-28 23:59:59"
    ORDER BY rental_date ASC;
    
    
SELECT * FROM sakila.rental
	WHERE rental_date >= "2005-05-25" AND rental_date <= "2005-05-28" -- We need to be careful with such conditions as sometimes we need to also state the time, not only date
    ORDER BY rental_date ASC;

SELECT * FROM sakila.rental
	WHERE rental_date BETWEEN "2005-05-25 00:00:00" AND "2005-05-28 23:59:59"
    ORDER BY rental_date ASC;

SELECT * FROM sakila.rental
	WHERE DATE( rental_date ) BETWEEN "2005-05-25" AND "2005-05-28"
    ORDER BY rental_date ASC;
    
    
SELECT * FROM sakila.rental;

SELECT * FROM sakila.actor_info;

SELECT * FROM world.country;
SELECT * FROM world.city;

SELECT co.Name AS "Country", ci.Name AS "City", FORMAT(ci.Population, 0) AS "Population"
FROM world.city ci INNER JOIN world.country co ON ci.CountryCode = co.Code
WHERE co.Name = "Poland"
ORDER BY ci.Population DESC;

CREATE OR REPLACE VIEW polish_cities AS
	( SELECT co.Name AS "Country", ci.Name AS "City", FORMAT(ci.Population, 0) AS "Population"
		FROM world.city ci INNER JOIN world.country co ON ci.CountryCode = co.Code
		WHERE co.Name = "Poland"
		ORDER BY ci.Population DESC
	);
    
SELECT * FROM polish_cities;
	