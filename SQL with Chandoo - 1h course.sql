USE awesome_chocolates;

SELECT * FROM products;
DESC sales;
DESCRIBE sales;

SELECT * FROM sales; -- SSMS - Sequel Server Management Studio

SELECT SaleDate, Amount, Customers
FROM sales;

SELECT Amount, Customers, GeoID
FROM sales;

SELECT SaleDate, Amount, Boxes, ROUND( Amount / Boxes, 2 ) AS 'Amount per box'
FROM sales;

SELECT *
FROM sales
WHERE Amount > 10000
ORDER BY Amount DESC;

SELECT *
FROM sales
WHERE Amount > 10000
ORDER BY 5 DESC; -- We can use indexes even though we do not specify the column order within our query. But we know that the table `sales` has a certain layout.

SELECT *
FROM sales
WHERE GeoID = 'G1'
ORDER BY PID, Amount DESC;

SELECT *
FROM sales
WHERE YEAR( SaleDate ) = 2022 AND Amount > 10000;

SELECT SaleDate, Amount
FROM sales
WHERE Amount > 10000 AND SaleDate >= '2022-01-01'
ORDER BY Amount DESC;

SELECT *
FROM sales
WHERE Boxes BETWEEN 0 AND 50 -- includes both 0 and 50 boundaries
ORDER BY Boxes DESC;

SELECT *
FROM sales
WHERE Boxes > 0 AND Boxes < 50; -- doesn't include 0 or 50 boundries

SELECT SaleDate, Amount, Boxes, WEEKDAY( SaleDate ) 'Day of week'
FROM sales
WHERE WEEKDAY( SaleDate ) = 4; -- We cannot use aliases to filter etc...

SELECT *
FROM people;

SELECT *
FROM people
WHERE Team = 'Delish' OR Team = 'Jucies';

SELECT *
FROM people
WHERE Team IN ('Delish', 'Jucies');

SELECt *
FROM people
WHERE SalesPerson LIKE 'B%';

SELECT *
FROM people
WHERE SalesPerson REGEXP 'B';

SELECT *
FROM people
WHERE SalesPerson LIKE '%B%';

SELECT 
	SaleDate,
	Amount,
	CASE
	WHEN Amount > 10000 THEN 'Over 10K'
    WHEN Amount <= 10000 AND Amount > 5000 THEN '5K-10K'
    WHEN Amount <= 5000 AND Amount > 1000 THEN '1K-5K'
    ELSE 'Less then 1K'
    END AS 'Sale category'
FROM sales;

SELECT * FROM 
sales s INNER JOIN people p ON s.SPID = p.SPID;

SELECT * FROM 
sales s NATURAL JOIN people p; -- Natural join will try to find two columns in both tables that could be paired and will return only one of them - not both as an INNER JOIN would

SELECT s.SaleDate, s.Amount, s.PID, pr.PID, pr.Product
FROM sales s RIGHT OUTER JOIN products pr ON s.PID = pr.PID;


SELECT s.SaleDate, s.Amount, p.SalesPerson, s.SPID, p.SPID, s.PID, pr.PID, pr.Product
FROM sales s JOIN people p ON p.SPID = s.SPID JOIN products pr ON pr.PID = s.PID;

SELECT s.SaleDate, s.Amount, p.SalesPerson, s.SPID, p.SPID, s.PID, pr.PID, pr.Product, Team
FROM sales s JOIN people p ON p.SPID = s.SPID JOIN products pr ON pr.PID = s.PID
WHERE s.Amount < 500 AND Team = 'Delish'; -- If the columns are uniquely identified we do not have to prefix them with table name or alias. Only amibious column names need to be prefixed.

SELECT s.SaleDate, s.Amount, p.SalesPerson, s.SPID, p.SPID, s.PID, pr.PID, pr.Product, Team
FROM sales s JOIN people p ON p.SPID = s.SPID JOIN products pr ON pr.PID = s.PID
WHERE s.Amount < 500 AND Team = '';


SELECT s.SaleDate, s.Amount, p.SalesPerson, s.SPID, p.SPID, s.PID, pr.PID, pr.Product, Team, g.Geo
FROM sales s JOIN people p ON p.SPID = s.SPID JOIN products pr ON pr.PID = s.PID JOIN geo g ON s.GeoID = g.GeoID
WHERE s.Amount < 500 AND Team = '' AND g.Geo IN ( 'New Zealand', 'India' )
ORDER BY s.SaleDate;

SELECT g.GeoID, g.Geo, SUM( s.Amount ) AS 'Total sale'
FROM geo g LEFt OUTER JOIN sales s ON g.GeoID = s.GeoID
GROUP BY g.GeoID, g.Geo;

SELECT pr.Category, pr.Product, SUM( s.Amount ) AS 'Total sales', AVG( s.Amount ) AS 'Average amount', SUM( Boxes ) AS 'Total boxes'
FROM products pr LEFT OUTER JOIN sales s ON pr.PID = s.PID
GROUP BY pr.Category, pr.Product WITH ROLLUP;

SELECT p.Team, pr.Category, SUM( s.Amount ) AS 'Total sales $'
FROM people p LEFT OUTER JOIN sales s ON s.SPID = p.SPID RIGHT OUTER JOIN products pr ON s.PID = pr.PID
WHERE p.Team IS NOT NULL
GROUP BY p.Team, pr.Category WITH ROLLUP
ORDER BY p.Team, pr.Category; 

SELECT pr.Product, SUM( s.Amount ) AS 'Total sales ($)'
FROM sales s JOIN products pr ON s.PID = pr.PID
GROUP BY pr.Product
ORDER BY `Total sales ($)` DESC; -- In the ORDER BY we can use aliases but when the alias has spaces then we need to use the ` symbol


SELECT pr.Product, SUM( s.Amount ) AS 'Total sales ($)'
FROM sales s JOIN products pr ON s.PID = pr.PID
GROUP BY pr.Product
ORDER BY `Total sales ($)` DESC
LIMIT 10;

### Intermediate Homework ###

# 1) Print details of shipments (sales) where amount is greater than 2000 and boxes are less than 500.

SELECT *
FROM sales
WHERE Amount > 2000 AND Boxes < 100;

# 2) How many shipments (sales) each of the salespersons had in the month of January 2022?

SELECT p.SalesPerson, COUNT( s.SPID ) AS 'Shipment count'
FROM people p LEFT OUTER JOIN sales s ON p.SPID = s.SPID
WHERE DATE_FORMAT( s.SaleDate, '%m-%Y' ) = '01-2022'
GROUP BY p.SalesPerson
ORDER BY  `Shipment count` DESC;


# 3) Which product sells more boxes? Milk Bars or Eclairs?

SELECT pr.Product, SUM( s.Boxes ) AS 'Total boxes sold'
FROM products pr LEFT OUTER JOIN sales s ON pr.PID = s.PID
WHERE pr.Product IN ( 'Milk Bars', 'Eclairs' )
GROUP BY pr.Product
ORDER BY `Total boxes sold` DESC; -- Eclairs around 14K more

# 4) Which product sold more boxes in the first 7 days of February 2022? Milk Bars or Eclairs?

SELECT pr.Product, SUM( s.Boxes ) AS 'Total boxes sold'
FROM products pr LEFT OUTER JOIN sales s ON pr.PID = s.PID
WHERE pr.Product IN ( 'Milk Bars', 'Eclairs' ) AND DATE( s.SaleDate ) BETWEEN '2022-02-01' AND '2022-02-07'
GROUP BY pr.Product
ORDER BY `Total boxes sold` DESC; -- Also Eclairs around 200 boxes more

# 5) Which shipments had under 100 customers & under 100 boxes? Did any of them occur on Wednesday?

SELECT DAYNAME( s.SaleDate ) AS 'Day of week', s.Customers AS'Total customers', s.Boxes AS 'Total boxes'
FROM sales s
WHERE s.Customers < 100 AND s.Boxes < 100;


SELECT DAYNAME( s.SaleDate ) AS 'Day of week', s.Customers AS'Total customers', s.Boxes AS 'Total boxes'
FROM sales s
WHERE s.Customers < 100 AND s.Boxes < 100 AND DAYNAME( s.SaleDate ) = 'Wednesday';

### Advanced Homework ###


# 1) What are the names of the salespersons whp had at least one shipment (sale) in the first 7 days of January?

SELECT DISTINCT p.SalesPerson
FROM people p INNER JOIN sales s ON p.SPID = s.SPID
WHERE DATE( s.SaleDate ) BETWEEN '2022-01-01' AND '2022-01-07'
ORDER BY 1;

# 2) Which salespersons did not make any shipments in the first 7 days of January 2022?

WITH sales_sp AS
	( SELECT *
      FROM sales
      WHERE DATE( SaleDate ) BETWEEN '2022-01-01' AND '2022-01-07'
	)
SELECT DISTINCT p.Salesperson
FROM sales_sp RIGHT OUTER JOIN people p ON sales_sp.SPID = p.SPID
WHERE sales_sp.SPID IS NULL; -- 8 records

SELECT p.salesperson
FROM people p
WHERE p.spid NOT IN
(SELECT DISTINCT s.spid FROM sales s WHERE s.SaleDate BETWEEN '2022-01-01' AND '2022-01-07');

# 3) How many times we shipped more than 1000 boxes in each month?

select YEAR( s.SaleDate ) AS 'Year', MONTH( s.SaleDate ) AS 'Month', COUNT(*) 'Times we shipped 1k boxes'
FROM sales s 
WHERE s.Boxes > 1000
GROUP BY YEAR( s.SaleDate ), MONTH( s.SaleDate )
ORDER BY YEAR( s.SaleDate ), MONTH( s.SaleDate );

# 4) Did we ship at least one box of 'After Nines' to New Zealand on all the months?

SELECT YEAR( s.SaleDate ) AS 'Year', MONTH( s.SaleDate ) AS 'Month', COUNT( * ) 'Shipments', IF( COUNT( * ) > 0, 'YES', 'NO' ) AS 'Status'
FROM sales s INNER JOIN products pr ON s.PID = pr.PID INNER JOIN geo g ON s.GeoID = g.GeoID
WHERE pr.Product = 'After Nines' AND g.Geo = 'New Zealand'
GROUP BY YEAR( s.SaleDate ), MONTH( s.SaleDate )
ORDER BY YEAR( s.SaleDate ), MONTH( s.SaleDate );

set @product_name = 'After Nines';
set @country_name = 'New Zealand';

select year(saledate) 'Year', month(saledate) 'Month', count( boxes ),
if(sum(boxes)>1, 'Yes','No') 'Status'
from sales s
join products pr on pr.PID = s.PID
join geo g on g.GeoID=s.GeoID
where pr.Product = @product_name and g.Geo = @country_name
group by year(saledate), month(saledate)
order by year(saledate), month(saledate);

# 5) India or Australia? Who buys more chocolate boxes on a monthly basis?

select year(saledate) 'Year', month(saledate) 'Month',
sum(CASE WHEN g.geo='India' THEN boxes ELSE 0 END) 'India Boxes',
sum(CASE WHEN g.geo='Australia' THEN boxes ELSE 0 END) 'Australia Boxes',
CASE 
	WHEN sum(CASE WHEN g.geo='India' THEN boxes ELSE 0 END) > sum(CASE WHEN g.geo='Australia' THEN boxes ELSE 0 END) THEN 'India'
    WHEN sum(CASE WHEN g.geo='India' THEN boxes ELSE 0 END) < sum(CASE WHEN g.geo='Australia' THEN boxes ELSE 0 END) THEN 'Australia'
    ELSE 'Equal boxes'
    END AS 'India Vs. Australia'
from sales s
join geo g on g.GeoID=s.GeoID
group by year(saledate), month(saledate)
order by year(saledate), month(saledate);

INSERT INTO sales VALUES ( 'SP01', 'G1', 'P014', '2021-01-01 00:00:00', 100, 100, 1017 );

SELECT * FROM sales;
SELECT * FROM geo;




