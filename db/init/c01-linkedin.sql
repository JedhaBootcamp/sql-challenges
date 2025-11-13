-- Challenge 01 – Salary Difference Between Departments (Large Dataset)
CREATE SCHEMA IF NOT EXISTS c01_salary_difference;
SET search_path TO c01_salary_difference,public;

-- Drop tables if rerun
DROP TABLE IF EXISTS db_employee CASCADE;
DROP TABLE IF EXISTS db_dept CASCADE;
DROP TABLE IF EXISTS expected_output CASCADE;

CREATE TABLE db_employee (
    id BIGINT PRIMARY KEY,
    first_name TEXT,
    last_name  TEXT,
    salary BIGINT,
    department_id BIGINT
);

CREATE TABLE db_dept (
    id BIGINT PRIMARY KEY,
    department TEXT
);

CREATE TABLE expected_output (
    salary_difference BIGINT
);

-- Departments
INSERT INTO db_dept (id, department) VALUES
(1, 'engineering'),
(2, 'human resource'),
(3, 'operation'),
(4, 'marketing'),
(5, 'sales');

-- Generate a larger synthetic employee dataset
-- Around 200 rows using generate_series (Postgres)
INSERT INTO db_employee (id, first_name, last_name, salary, department_id)
SELECT
  10000 + g AS id,
  'First_' || g AS first_name,
  'Last_'  || g AS last_name,
  -- pseudo-random salary between 25k and 90k
  25000 + (g * 7919 % 65000) AS salary,
  (g % 5) + 1 AS department_id   -- distribute across 5 departments
FROM generate_series(1,200) AS g;

-- Optional: a few specific edge cases to ensure marketing/engineering have different maxima
UPDATE db_employee SET salary = 95000 WHERE id IN (10005,10010);  -- marketing
UPDATE db_employee SET salary = 92600 WHERE id IN (10001,10020);  -- engineering

-- Expected output: absolute difference between max salaries in marketing & engineering
INSERT INTO expected_output (salary_difference)
SELECT ABS(
         MAX(CASE WHEN d.department = 'marketing'   THEN e.salary END)
       - MAX(CASE WHEN d.department = 'engineering' THEN e.salary END)
       ) AS salary_difference
FROM db_employee e
JOIN db_dept d ON e.department_id = d.id
WHERE d.department IN ('marketing','engineering');
