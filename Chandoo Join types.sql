USE awesome_chocolates;

SELECT * FROM sales
LIMIT 1000;

SELECT * FROM products;
SELECT * FROM people;
SELECT * FROM geo;

# 1) Shipments information with names & categories of the products.

SELECT p.product AS 'Product', p.category AS 'Category', s.SaleDate AS 'Sales date', s.amount AS 'Amount'
FROM sales s INNER JOIN products p ON s.PID = p.PID;

# 2) Shipments with sales person and team.

SELECT s.PID AS 'PID', DATE(s.SaleDate) AS 'Sales date', p.Salesperson AS 'Salesperson', p.Team AS 'Team', s.Amount AS 'Amount'
FROM sales s INNER JOIN people p ON s.SPID = p.SPID;

# 3) Bar shipments alone.

SELECT p.product AS 'Product', p.category AS 'Category', s.SaleDate AS 'Sales date', s.amount AS 'Amount'
FROM sales s INNER JOIN products p ON s.PID = p.PID
WHERE p.Category = 'Bars';


# 4) Barr shipments alone


SELECT s.PID AS 'PID', DATE(s.SaleDate) AS 'Sales date', p.Salesperson AS 'Salesperson', p.Team AS 'Team', s.Amount AS 'Amount'
FROM sales s INNER JOIN people p ON s.SPID = p.SPID
WHERE p.Salesperson = 'Barr Faughny';

SELECT s.PID AS 'PID', DATE(s.SaleDate) AS 'Sales date', p.Salesperson AS 'Salesperson', p.Team AS 'Team', s.Amount AS 'Amount'
FROM sales s INNER JOIN people p ON s.SPID = p.SPID AND p.Salesperson = 'Barr Faughny'; -- We can add an extra condition in the JOIN operation. Is not used very often as it is not well readible.

# 5) All shipments where the product category is a bar and the Salesperson is called Barr Faughny

SELECT p.product AS 'Product', p.category AS 'Category', pl.Salesperson AS 'Salesperson', s.SaleDate AS 'Sales date', s.amount AS 'Amount'
FROM sales s INNER JOIN products p ON s.PID = p.PID INNER JOIN people pl ON s.SPID = pl.SPID
WHERE p.Category = 'Bars' AND pl.Salesperson = 'Barr Faughny';

SELECT p.product AS 'Product', p.category AS 'Category', pl.Salesperson AS 'Salesperson', s.SaleDate AS 'Sales date', s.amount AS 'Amount'
FROM sales s INNER JOIN products p ON s.PID = p.PID AND p.Category = 'Bars'
INNER JOIN people pl ON s.SPID = pl.SPID AND pl.Salesperson = 'Barr Faughny'
ORDER BY s.Amount DESC;

# 6) Bar Barr shipments, grouped by month

SELECT CONCAT( MONTHNAME( DATE( s.SaleDate ) ), ' ', YEAR( DATE( s.SaleDate ) ) )  AS 'Sale month', COUNT( s.PID ) AS 'Count of shipments'
FROM sales s INNER JOIN products p ON s.PID = p.PID INNER JOIN people pl ON s.SPID = pl.SPID
WHERE p.Category = 'Bars' AND pl.Salesperson = 'Barr Faughny'
GROUP BY CONCAT( MONTHNAME( DATE( s.SaleDate ) ), ' ', YEAR( DATE( s.SaleDate ) ) );

# 7) LEFT JOIN

SELECT * FROM products;
INSERT INTO products VALUES ( 'P23', 'Test product', 'Bars', 'LARGE', 10 ); -- I need to add one new product that was not yet sold and shipped.


SELECT s.SaleDate, s.PID, p.PID
FROM products p LEFT OUTER JOIN sales s ON p.PID = s.PID -- Or LEFT JOIN
ORDER BY 2 ASC;

# 8) ANTI JOINS - Which products have not been sold at all yet? - The one I just created.

SELECT p.Product, p.Category, s.SaleDate, s.PID, p.PID
FROM products p LEFT OUTER JOIN sales s ON p.PID = s.PID -- Or LEFT JOIN
WHERE s.PID IS NULL
ORDER BY 2 ASC; -- There is no specific JOIN keyword for Anti joins. Using anti joins requires us to use a WHERE condition.

# 9) Did we ship all the products on the first of Feb 2002?

WITH all_sales_01022022 AS
	( SELECT s.PID FROM sales s
	  WHERE DATE( s.SaleDate ) = '2022-02-01'
	)
SELECT p.PID, p.Product, p.Category
FROM products p LEFT OUTER JOIN all_sales_01022022 ON p.PID = all_sales_01022022.PID
WHERE all_sales_01022022.PID IS NULL; -- This will be a list of products that were not shipped on the 01.02.2022


SELECT p.Product, SUM( s.Amount ) AS 'Sales',
	CASE 
	WHEN SUM( s.Amount ) IS NULL THEN 'Not shipped'
    ELSE 'Shipped' 
    END AS 'Sales status'
FROM products p LEFT OUTER JOIN sales s ON p.PID = s.PID AND DATE( s.SaleDate ) = '2022-02-01'
GROUP BY p.Product
ORDER BY 2 DESC;

# HW1) Show amount, boxes, product and dates for all sales in January 2022 excluding "other category".

SELECT p.product AS 'Product', DATE( s.SaleDate ) AS 'Sale date',  s.Amount AS 'Sales', s.Boxes AS 'Boxes' 
FROM products p INNER JOIN sales s ON p.PID = s.PID
WHERE p.Category <> 'Other' AND DATE_FORMAT( s.SaleDate, '%m-%Y' ) = '01-2022';

# HW2) Show amount, boxes, product for all sales in January 2022 excluding "Other" grouped by date.

SELECT DATE( s.SaleDate ) AS 'Sale date', COUNT( DISTINCT p.product ) AS 'Count of products', SUM( s.Amount ) AS 'Total Sales', SUM( s.Boxes ) AS 'Total Boxes' 
FROM products p INNER JOIN sales s ON p.PID = s.PID
WHERE p.Category <> 'Other' AND DATE_FORMAT( s.SaleDate, '%m-%Y' ) = '01-2022'
GROUP BY DATE( s.SaleDate );

# HW3) Which products sold more in Jan 2022 compared to Jan 2021?

WITH 
	sales_2021 AS
	( SELECT p1.Product AS p1Product, SUM( s1.Amount ) s1Amount
	  FROM products p1 JOIN sales s1 ON p1.PID = s1.PID
      WHERE DATE_FORMAT( s1.SaleDate, '%m-%Y' ) = '01-2021'
      GROUP BY p1.Product
	),
    sales_2022 AS
	( SELECT p2.Product AS p2Product, SUM( s2.Amount ) s2Amount
	  FROM products p2 JOIN sales s2 ON p2.PID = s2.PID
      WHERE DATE_FORMAT( s2.SaleDate, '%m-%Y' ) = '01-2022'
      GROUP BY p2.Product
	)
SELECT p.Product AS 'Product' , s1Amount AS 'Sales Jan 2021', s2Amount AS 'Sales Jan 2022',
	CASE
		WHEN COALESCE(s1Amount, 0) > COALESCE(s2Amount, 0) THEN 'Sold more in Jan 2021'
		WHEN COALESCE(s2Amount, 0) > COALESCE(s1Amount, 0) THEN 'Sold more in Jan 2022'
		ELSE 'Sold the same in Jan 2021 & 2022'
    END AS '2021 Vs. 2022'
FROM products p LEFT OUTER JOIN sales_2021 ON p.Product = p1Product LEFT OUTER JOIN sales_2022 ON p.Product = p2Product;

INSERT INTO products VALUES( 'P24', 'Sold only in 2022', 'Bars', 'LARGE', 10 );
INSERT INTO products VALUES( 'P25', 'Sold only in 2021', 'Bars', 'LARGE', 10 );
SELECT * FROM sales;
INSERT INTO sales VALUES( 'SP01', 'G1', 'P25', '2021-01-01 00:00:00', 1000, 100, 256 );
INSERT INTO sales VALUES( 'SP01', 'G1', 'P24', '2022-01-01 00:00:00', 1000, 100, 256 );

# 4) In the month of Jan 2022, what is the average of Barr Faughny's daily sales?

WITH daily_sales AS
	( SELECT DATE( s.SaleDate ) AS SaleDate, SUM( s.Amount ) AS TotalSales
	  FROM sales s INNER JOIN people p ON s.SPID = p.SPID
	  WHERE DATE_FORMAT( s.SaleDate, '%m-%Y' ) = '01-2022' AND p.Salesperson = 'Barr Faughny'
	  GROUP BY DATE( s.SaleDate)
	  ORDER BY 1
	)
SELECT ROUND( AVG( daily_sales.TotalSales ), 2 ) AS 'Average daily sales for Barr Faughny in Jan 2022'
      FROM daily_sales; -- This query includes only date when Barr Faughny sold something.
      
SELECT ROUND( SUM( s.Amount ) / 31, 2 ) AS 'Average daily sales for Barr Faughny in Jan 2022'
FROM sales s INNER JOIN people p ON s.SPID = p.SPID
WHERE DATE_FORMAT( s.SaleDate, '%m-%Y' ) = '01-2022' AND p.Salesperson = 'Barr Faughny'; -- This query includes days when Barr Faughny didn't sell anything.

# 5) On how many days he exceeded this average? I will look only at days when ha actually sold

WITH daily_sales AS
	( SELECT DATE( s.SaleDate ) AS SaleDate, SUM( s.Amount ) AS TotalSales
	  FROM sales s INNER JOIN people p ON s.SPID = p.SPID
	  WHERE DATE_FORMAT( s.SaleDate, '%m-%Y' ) = '01-2022' AND p.Salesperson = 'Barr Faughny'
	  GROUP BY DATE( s.SaleDate)
	  ORDER BY 1
	),
    average_sales AS
    ( SELECT ROUND( AVG( daily_sales.TotalSales ), 2 ) AS AvgSales
	  FROM daily_sales
	)
SELECT COUNT( SaleDate )  AS 'Num. of days over the average'
FROM daily_sales
WHERE TotalSales > (SELECT AvgSales FROM average_sales );




    
