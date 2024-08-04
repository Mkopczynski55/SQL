-- Zadanie 1 : Dodaj nowe miasto o nazwie 'SampleCity', w kraju o kodzie 'USA', w dystrykcie 'SampleDistrict' z populacją 500000.

SELECT * FROM world.city;

INSERT INTO world.city VALUES (
	4080, 'Sample city', 'USA', 'Sample District', 500000
    );

INSERT INTO world.city (ID, Name, CountryCode, District, Population) VALUES (
( SELECT MAX( c2.ID ) FROM world.city c2 )  + 1, 'New Sample City', 'USA', 'Sample District', 150000
	);
    
-- Zadanie 2: Zaktualizuj populację miasta 'SampleCity' do 600000.

UPDATE world.city
	SET population = 600000
    WHERE ID = 4080;
    
SELECT * FROM world.city
	WHERE ID = 4080;
    
-- Zadanie 3: Usuń miasto 'SampleCity' z tabeli 'city'

DELETE FROM world.city
	WHERE ID = 4080;
    
UPDATE world.city
	SET ID = 4080
    WHERE ID = 4081;
    
-- Zadanie 4: Wyświetl 10 krajów o największej populacji, wraz z ich nazwami i populacją.

SELECT Name, Population
	FROM world.country
    ORDER BY Population DESC
    LIMIT 10;

-- Zadanie 5: Wyświetl wszystkie miasta, których populacja przekracza 1 milion, wraz z ich nazwami, krajami i populacją.

SELECT ci.Name AS "City", co.Name AS "Country", ci.Population AS "Population"
	FROM world.city ci INNER JOIN world.country co ON ci.CountryCode = co.Code
    WHERE ci.Population > 1000000
    ORDER BY ci.Population DESC;
    
-- Zadanie 6: Wyświetl nazwy krajów, gdzie językiem urzędowym jest francuski.

SELECT * FROM world.countrylanguage;

SELECT co.Name AS "Country", cl.Language AS "Language"
	FROM world.country co INNER JOIN world.countrylanguage cl ON co.Code = cl.CountryCode
    WHERE cl.Language = "French" AND cl.IsOfficial = "T";

-- Zadanie 7: Oblicz i wyświetl średnią długość życia dla każdego regionu.

SELECT * FROM world.country;

SELECT Region, ROUND( AVG( LifeExpectancy ), 1 ) AS "Average Life expectancy"
	FROM world.country
    GROUP BY Region
    ORDER BY ROUND( AVG( LifeExpectancy ), 1 ) DESC, Region ASC;
    
-- Zadanie 8: Wyświetl liczbę miast w każdym kraju.

SELECT co.Name AS "Country", COUNT( ci.ID ) AS "City count"
FROM world.country co LEFT OUTER JOIN world.city ci ON co.Code = ci.CountryCode
GROUP BY co.Name
ORDER BY COUNT( ci.ID) DESC, co.Name ASC;

SELECT co.Name AS "Country", COUNT( ci.ID ) AS "City count"
FROM world.country co INNER JOIN world.city ci ON co.Code = ci.CountryCode
GROUP BY co.Name
ORDER BY COUNT( ci.ID) DESC, co.Name ASC;

-- Zadanie 9: Wyświetl nazwy miast i nazw krajów dla wszystkich miast z populacją większą niż 1 milion.

SELECT ci.Name AS "City", co.Name AS "Country", ci.Population AS "Population"
	FROM world.city ci INNER JOIN world.country co ON ci.CountryCode = co.Code
    WHERE ci.Population > 1000000
    ORDER BY 3 DESC, 2 ASC, 3 ASC;
    
-- Zadanie 10: Wyświetl nazwy i populacje krajów, które mają populację większą niż średnia populacja wszystkich krajów.

SELECT AVG(Population) FROM world.country;

SELECT Name AS "Country", Population
	FROM world.country
    WHERE Population > ( SELECT AVG(c1.Population) FROM world.country c1 )
    ORDER BY 2 DESC, 1 ASC;
    
-- Zadanie 11: Utwórz tabelę continent z kolumnami: ID (klucz główny, auto-inkrementacja) i Name (nazwa kontynentu).

CREATE TABLE continent(
	ID INTEGER(2) AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(50) NOT NULL
);

-- Zadanie 12: Dodaj kolumnę AvgAnnualTemperature typu DECIMAL(5, 2) do tabeli country.

ALTER TABLE world.country
	ADD COLUMN AvgAnnulaTemperature DECIMAL(5, 2);
    
    
-- Zadanie 13: Zmień typ danych kolumny Population w tabeli city na BIGINT.

ALTER TABLE world.city
	MODIFY Population bigint;
    
-- Zadanie 14: Usuń tabelę continent.

DROP TABLE world.continent CASCADE;

-- Zadanie 15: Utwórz indeks na kolumnie Name w tabeli city dla przyspieszenia wyszukiwania.

CREATE INDEX cName_index ON world.city(Name);

-- Zadanie 16: Nadaj i cofnij użytkownikowi analyst uprawnienia SELECT na tabeli country.

GRANT SELECT ON world.country TO analyst;
REVOKE SELECT ON world.country FROM analyst;


-- Zadanie 17: Stwórz użytkownika analyst z hasłem securepassword i nadaj mu uprawnienia SELECT, INSERT, UPDATE, DELETE na bazie world.

CREATE USER analyst IDENTIFIED BY 'securepassword';
GRANT SELECT, INSERT, UPDATE, DELETE ON world.* TO analyst;

-- Zadanie 18: Stwórz widok CountryCityCount, który wyświetla nazwy krajów i liczbę miast w każdym kraju.

CREATE OR REPLACE VIEW CountryCityCount AS 
	( SELECT co.Name AS "Country", COUNT( ci.ID ) AS "City count"
		FROM world.country co LEFT OUTER JOIN world.city ci ON co.Code = ci.CountryCode
        GROUP BY co.Name
        ORDER BY 2 DESC, 1 ASC
	);
    
SELECT * FROM CountryCityCount;

-- Zadanie 19: Stwórz procedurę GetCitiesByCountry, która przyjmuje kod kraju jako parametr wejściowy i zwraca wszystkie miasta w tym kraju.

DELIMITER //

DROP PROCEDURE GetCitiesByCountry;

CREATE PROCEDURE GetCitiesByCountry(IN country_code CHAR(3))
BEGIN
    SELECT Name, District, Population
    FROM city
    WHERE CountryCode = country_code
    ORDER BY 2 DESC, 1 ASC;
END //

DELIMITER ;

CALL GetCitiesByCountry("POL");









