--PHASE 2: FINDING THE PROBLEMS; MISSING DATA, ERRORS, NULLS ETC

-- 2.1 Missing values-- 
SELECT 
    (COUNT(*) - COUNT(invoice)) AS invoice_NULLS_count, --0--
    (COUNT(*) - COUNT(customer_id)) AS customer_nulls_count, --243,007--
    (COUNT(*) - COUNT(quantity)) AS quantity_null_count,--0--
    (COUNT(*) - COUNT(invoicedate)) AS invoice_date_null_count, --0--
    (COUNT(*) - COUNT(country)) AS country_null_count, --0--
    (COUNT(*) - COUNT(stockcode)) AS stockcode_null_count, --0--
    (COUNT(*) - COUNT(description)) AS description_null_count, --4383--
    (COUNT(*) - COUNT(price)) AS price_null_count --0-- 
FROM flat;

-- all values contain NO NULL except customer_id and description
-- customer_id contains a lot of missing values - likely reason: guest checkouts, or unusable rows?--
-- 824,364 rows have a customer_id
-- 243,007 rows do not  (22.8% of the dataset)
-- Check what share of revenue they represent before deciding.

SELECT COUNT(customer_id) FROM flat;                      -- 824,364
SELECT COUNT(*) FROM flat WHERE customer_id IS NULL;      -- 243,007

-- 2.2 Cancellations -- 
SELECT COUNT(DISTINCT(invoice)), COUNT(DISTINCT(customer_id)) FROM flat WHERE invoice LIKE "C%"; 
-- 8292 invoice items were cancelled--
-- 2572 UNIQUE customer_id performed these cancellations --

-- Do cancellations always have negative quantities?-- 
SELECT COUNT(quantity < 0 ) AS negative_quantities FROM flat WHERE invoice LIKE "C%";
-- 19,493 quantities have values less than 0 --
-- anothe way to check 

SELECT COUNT(*) FROM flat WHERE invoice LIKE "C%" AND quantity < 0; -- 19,493 --

--Do negative quantities always sit on 'C' invoices? -- 
SELECT COUNT(*) AS negative_quantities_with_cancelled_invoice
FROM flat 
WHERE invoice NOT LIKE 'C%' 
  AND quantity < 0;
-- negative quantites come about on other UNCANCELLED invoices; 3457 --


-- 2.3 Impossible values -- 
-- how many rows have negative quantity, negative price, zero price? Are the zero-price rows real sales or something else? -- 

SELECT COUNT(*)
FROM flat 
WHERE invoice NOT LIKE 'C%' 
  AND quantity < 0 AND price IS 0;

-- quantity is negative and price is ALWAYS 0, shipped to UP, description is either NULL or shows the items is damaged -- 
-- customer id is missing in these columns --  3457/243,007 = NUMBER OF CUSTOMER ID MISSING WHICH ALSO SHOW QUANTITY < 0 & INVOICE IS NOT cancelled

-- 2.4 Rows that aren't products -- 
-- Some stockcodes aren't products — postage, manual adjustments, bank charges, carriage --
-- Question: which stockcodes don't look like the documented 5-digit format, and how often does each appear?-- 

SELECT * FROM flat WHERE stockcode NOT GLOB '[0-9][0-9][0-9][0-9][0-9]';  -- 134,986 - do not follow the 5 digit format-- 
-- do these products belond on the table?
-- should we remove the null customerID on the table


-- 2.5 One stockcode, many descriptions ← most important --

