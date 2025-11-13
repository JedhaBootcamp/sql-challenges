-- Challenge 05 – Non-paying vs Paying Downloads by Date
-- Keep only dates where non-paying downloads > paying downloads.
-- Output: date, non_paying, paying (sorted ascending by date)

CREATE SCHEMA IF NOT EXISTS c05_downloads_by_segment;
SET search_path TO c05_downloads_by_segment,public;

DROP TABLE IF EXISTS ms_user_dimension CASCADE;
DROP TABLE IF EXISTS ms_acc_dimension CASCADE;
DROP TABLE IF EXISTS ms_download_facts CASCADE;
DROP TABLE IF EXISTS expected_output CASCADE;

-- Dimensions
CREATE TABLE ms_acc_dimension (
  acc_id BIGINT PRIMARY KEY,
  paying_customer TEXT  -- 'yes' | 'no'
);

CREATE TABLE ms_user_dimension (
  acc_id BIGINT,
  user_id BIGINT PRIMARY KEY
);

-- Facts
-- NOTE: "date" is a reserved word in some DBs; keep it quoted here.
CREATE TABLE ms_download_facts (
  user_id BIGINT,
  "date"  DATE,
  downloads BIGINT
);

-- Ground truth table
CREATE TABLE expected_output (
  download_date DATE,
  non_paying BIGINT,
  paying BIGINT
);

-- ----------------------------------------
-- Seed data (larger than screenshots)
-- Accounts: mix of paying and non-paying
-- ----------------------------------------
INSERT INTO ms_acc_dimension (acc_id, paying_customer) VALUES
(1,'yes'), (2,'no'), (3,'yes'), (4,'no'), (5,'yes'), (6,'no'), (7,'yes'), (8,'no');

-- Users mapped to accounts (10 users)
INSERT INTO ms_user_dimension (acc_id, user_id) VALUES
(1,201),(1,202),   -- paying
(2,203),(2,204),   -- non-paying
(3,205),(3,209),   -- paying
(4,206),(4,210),   -- non-paying
(5,207),           -- paying
(6,208);           -- non-paying

-- ----------------------------------------
-- Downloads over a week (tune totals so some dates satisfy non>paying)
-- 2025-10-01 → non (80) > pay (50)      ✅ keep
-- 2025-10-02 → non (100) < pay (120)    ❌ drop
-- 2025-10-03 → non (61) > pay (60)      ✅ keep
-- 2025-10-04 → non (20) < pay (30)      ❌ drop
-- 2025-10-05 → non (70) = pay (70)      ❌ drop
-- 2025-10-06 → non (125) > pay (90)     ✅ keep
-- 2025-10-07 → non (110) > pay (95)     ✅ keep
-- ----------------------------------------

-- 2025-10-01
INSERT INTO ms_download_facts VALUES
(201,'2025-10-01',20),(202,'2025-10-01',30),(205,'2025-10-01',0),(207,'2025-10-01',0),(209,'2025-10-01',0),  -- paying total 50
(203,'2025-10-01',40),(204,'2025-10-01',20),(206,'2025-10-01',10),(208,'2025-10-01',5),(210,'2025-10-01',5); -- non total 80

-- 2025-10-02
INSERT INTO ms_download_facts VALUES
(201,'2025-10-02',50),(202,'2025-10-02',30),(205,'2025-10-02',20),(207,'2025-10-02',10),(209,'2025-10-02',10), -- paying 120
(203,'2025-10-02',40),(204,'2025-10-02',30),(206,'2025-10-02',20),(208,'2025-10-02',10);                       -- non 100

-- 2025-10-03
INSERT INTO ms_download_facts VALUES
(201,'2025-10-03',10),(202,'2025-10-03',20),(205,'2025-10-03',20),(209,'2025-10-03',10),                       -- paying 60
(203,'2025-10-03',30),(204,'2025-10-03',20),(206,'2025-10-03',11);                                             -- non 61

-- 2025-10-04
INSERT INTO ms_download_facts VALUES
(201,'2025-10-04',15),(205,'2025-10-04',5),(207,'2025-10-04',10),                                               -- paying 30
(204,'2025-10-04',10),(206,'2025-10-04',5),(208,'2025-10-04',5);                                                -- non 20

-- 2025-10-05
INSERT INTO ms_download_facts VALUES
(201,'2025-10-05',20),(202,'2025-10-05',20),(205,'2025-10-05',15),(207,'2025-10-05',15),                        -- paying 70
(203,'2025-10-05',25),(204,'2025-10-05',20),(206,'2025-10-05',15),(210,'2025-10-05',10);                        -- non 70

-- 2025-10-06
INSERT INTO ms_download_facts VALUES
(201,'2025-10-06',30),(202,'2025-10-06',25),(205,'2025-10-06',20),(209,'2025-10-06',15),                        -- paying 90
(203,'2025-10-06',40),(204,'2025-10-06',35),(206,'2025-10-06',30),(208,'2025-10-06',10),(210,'2025-10-06',10);  -- non 125

-- 2025-10-07
INSERT INTO ms_download_facts VALUES
(201,'2025-10-07',35),(202,'2025-10-07',30),(205,'2025-10-07',20),(207,'2025-10-07',10),                        -- paying 95
(203,'2025-10-07',45),(204,'2025-10-07',35),(206,'2025-10-07',20),(208,'2025-10-07',10);                        -- non 110

-- ------------------------------------------------------------
-- Compute EXPECTED OUTPUT (derived from same logic as the task)
-- ------------------------------------------------------------
WITH download_totals AS (
  SELECT
    f."date" AS download_date,
    SUM(CASE WHEN a2.paying_customer = 'yes' THEN f.downloads ELSE 0 END) AS paying,
    SUM(CASE WHEN a2.paying_customer = 'no'  THEN f.downloads ELSE 0 END) AS non_paying
  FROM ms_download_facts f
  JOIN ms_user_dimension u  ON u.user_id = f.user_id
  JOIN ms_acc_dimension a2  ON a2.acc_id = u.acc_id
  GROUP BY f."date"
)
INSERT INTO expected_output (download_date, non_paying, paying)
SELECT download_date, non_paying, paying
FROM download_totals
WHERE (non_paying - paying) > 0
ORDER BY download_date ASC;