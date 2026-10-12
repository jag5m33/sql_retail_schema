-- How many rows, invoices, products, customers, countries? --
-- rows: 1067371--
-- distinct invoices: 53,628 --
-- products: 5306 --
-- customers: 5942 --
-- countries: 43 --
SELECT COUNT(*) AS rows,
       COUNT(DISTINCT invoice) AS invoices,
       COUNT(DISTINCT stockcode) AS products,
       COUNT(DISTINCT customer_id) AS customers, -- skips null--
       COUNT(DISTINCT country) AS countries
FROM flat;

-- Which column would uniquely identify a row, if any? --
-- no column uniquely identifities a row - otherwise it would have a distinct 1067371 number of values --
SELECT * FROM flat;
SELECT COUNT(DISTINCT(invoicedate)) FROM flat; --47635--

SELECT COUNT(customer_id) FROM flat; -- 824,364-- the remaining from the 1067371 are null for customer ID
SELECT COUNT(*) FROM flat WHERE customer_id IS NULL; -- 243007-- - NULL CUSTOMER COLUMNS 

-- What does one row represent? One sale? One product on one sale? --
-- one invoice has MULTIPLE lines - there are; repeat the invoiceID number and there are individual items bought per order invoice from each customer 
	-- this is a ONE TO MANY relationship--

-- It's asking: can the same stockcode appear twice on the same invoice? --
SELECT COUNT(*) AS rows,
       COUNT(DISTINCT invoice || '|' || stockcode) AS pairs -- So invoice || '|' || stockcode glues the two columns into one string:-- 
FROM flat; 
--COUNT(DISTINCT ...) counts how many unique combinations exist-- 
-- there are too little for thenumber of rows we have - there are repeats-- 

SELECT invoice, stockcode, COUNT(*) AS n
FROM flat
GROUP BY invoice, stockcode
HAVING COUNT(*) > 1
ORDER BY n DESC
LIMIT 100;
