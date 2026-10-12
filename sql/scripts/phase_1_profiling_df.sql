-- Phase 1 — 
-- Online Retail II, flat table (1,067,371 rows, 8 columns)
-- Goal: understand what a row represents and whether a primary key exists


-- 1.1  Shape of the data
-- rows:      1,067,371
-- invoices:     53,628
-- products:      5,306
-- customers:     5,942   (COUNT DISTINCT skips NULLs — see 1.3)
-- countries:        43

SELECT COUNT(*)                   AS rows,
       COUNT(DISTINCT invoice)    AS invoices,
       COUNT(DISTINCT stockcode)  AS products,
       COUNT(DISTINCT customer_id) AS customers,
       COUNT(DISTINCT country)    AS countries
FROM flat;


-- 1.2  What does one row represent?

-- 1,067,371 rows but only 53,628 invoices — roughly 20 rows per invoice.
-- So a row is NOT an order. A row is one product line on one order:
-- an invoice repeats once per item bought.
--
-- One invoice -> many lines. A one-to-many relationship, which means
-- two tables later: invoices (one row per order) and
-- invoice_lines (one row per item).
--
-- Consequence: invoicedate, customer_id and country are facts about the
-- ORDER and repeat identically across all its lines. stockcode, quantity
-- and price differ per line. Two grains, two tables.

SELECT * FROM flat LIMIT 100;

-- Timestamps are per-invoice, not per-line: 47,635 distinct values
-- against 53,628 invoices (some invoices share a timestamp).
SELECT COUNT(DISTINCT invoicedate) FROM flat;


-- 1.3  Missing customer IDs

-- 824,364 rows have a customer_id
-- 243,007 rows do not  (22.8% of the dataset)
--
-- Decision needed in Phase 3: guest checkouts, or unusable rows?
-- Check what share of revenue they represent before deciding.

SELECT COUNT(customer_id) FROM flat;                      -- 824,364
SELECT COUNT(*) FROM flat WHERE customer_id IS NULL;      -- 243,007


-- 1.4  Is there a primary key?

-- No single column is unique — any such column would have 1,067,371
-- distinct values, and none do.
--
-- Next candidate: the composite (invoice, stockcode). The || operator
-- concatenates the two columns into one string ('489434|85048') so that
-- COUNT DISTINCT can count unique combinations — SQLite won't accept
-- COUNT(DISTINCT a, b). The '|' separator prevents 12+345 and 123+45
-- from both collapsing to '12345'.
--
-- Result: distinct pairs < total rows, so the same product DOES appear
-- more than once on the same invoice. (invoice, stockcode) is therefore
-- NOT unique and cannot be the primary key of invoice_lines.
--
-- => invoice_lines will need a surrogate key (auto-generated line_id).

SELECT COUNT(*)                                        AS rows,
       COUNT(DISTINCT invoice || '|' || stockcode)     AS pairs
FROM flat;


-- 1.5  Inspect the duplicate lines

-- Are these genuine duplicate entries, quantity amendments, or one line
-- being a cancellation of the other? Look at the raw rows for the worst
-- offenders before deciding how to handle them in Phase 3.

SELECT invoice, stockcode, COUNT(*) AS n
FROM flat
GROUP BY invoice, stockcode
HAVING COUNT(*) > 1
ORDER BY n DESC
LIMIT 100;



-- Phase 1 findings
--   - A row = one product line on one order
--   - No primary key exists; (invoice, stockcode) is not unique
--   - invoice_lines needs a surrogate key
--   - 22.8% of rows have no customer_id — Phase 3 decision

