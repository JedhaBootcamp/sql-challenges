-- Challenge 06 – Total active hours per user (single day session logs)
-- A user is "active" while state = 1, until their next event switches it off (or another state).

CREATE SCHEMA IF NOT EXISTS c06_active_hours;
SET search_path TO c06_active_hours,public;

DROP TABLE IF EXISTS cust_tracking CASCADE;
DROP TABLE IF EXISTS expected_output CASCADE;

CREATE TABLE cust_tracking (
  cust_id   TEXT,
  state     BIGINT,                 -- 1 = active, 0 = inactive
  "timestamp" TIMESTAMP             -- events for a single day
);

CREATE TABLE expected_output (
  cust_id    TEXT,
  total_hours NUMERIC(10,2)
);

-- ─────────────────────────────────────────────────────────────────────────────
-- Seed data (more than in the picture, but preserves the 5 example users)
-- The times are crafted so the totals match the screenshot expectations:
-- c001 → 5.0h, c002 → 4.5h, c003 → 1.5h, c004 → 2.0h, c005 → 7.5h
-- ─────────────────────────────────────────────────────────────────────────────

-- c001: 07:00–09:30 (2.5h), 12:00–14:30 (2.5h) => 5.0
INSERT INTO cust_tracking VALUES
('c001',1,'2024-11-26 07:00:00'),
('c001',0,'2024-11-26 09:30:00'),
('c001',1,'2024-11-26 12:00:00'),
('c001',0,'2024-11-26 14:30:00');

-- c002: 08:00–10:15 (2.25h), 11:00–13:15 (2.25h) => 4.5
INSERT INTO cust_tracking VALUES
('c002',1,'2024-11-26 08:00:00'),
('c002',0,'2024-11-26 10:15:00'),
('c002',1,'2024-11-26 11:00:00'),
('c002',0,'2024-11-26 13:15:00');

-- c003: 09:00–10:30 (1.5h)
INSERT INTO cust_tracking VALUES
('c003',1,'2024-11-26 09:00:00'),
('c003',0,'2024-11-26 10:30:00');

-- c004: 13:00–15:00 (2.0h)
INSERT INTO cust_tracking VALUES
('c004',1,'2024-11-26 13:00:00'),
('c004',0,'2024-11-26 15:00:00');

-- c005: 08:30–12:00 (3.5h), 13:00–17:00 (4.0h) => 7.5
INSERT INTO cust_tracking VALUES
('c005',1,'2024-11-26 08:30:00'),
('c005',0,'2024-11-26 12:00:00'),
('c005',1,'2024-11-26 13:00:00'),
('c005',0,'2024-11-26 17:00:00');

-- Extra users (noise; correct logic must still work)
INSERT INTO cust_tracking VALUES
('c006',0,'2024-11-26 08:00:00'),         -- starts inactive, then active
('c006',1,'2024-11-26 09:00:00'),
('c006',0,'2024-11-26 10:00:00'),
('c007',1,'2024-11-26 07:45:00'),         -- active but never turns off → ignore open tail
('c008',0,'2024-11-26 12:00:00'),         -- only 0s → contributes 0
('c009',1,'2024-11-26 10:00:00'),
('c009',1,'2024-11-26 11:00:00'),         -- duplicate state=1 update; next row closes
('c009',0,'2024-11-26 12:00:00');

-- ─────────────────────────────────────────────────────────────────────────────
-- Ground truth (expected_output) computed from the data above
-- We sum durations where state = 1 until the *next* event for that user.
-- Open-ended last intervals (no next event) are ignored for that day.
-- ─────────────────────────────────────────────────────────────────────────────
WITH ordered AS (
  SELECT
    cust_id,
    state,
    "timestamp",
    LEAD("timestamp") OVER (PARTITION BY cust_id ORDER BY "timestamp") AS next_ts
  FROM cust_tracking
),
intervals AS (
  SELECT
    cust_id,
    CASE WHEN state = 1 AND next_ts IS NOT NULL
         THEN EXTRACT(EPOCH FROM (next_ts - "timestamp"))/3600.0
         ELSE 0 END AS hours
  FROM ordered
)
INSERT INTO expected_output (cust_id, total_hours)
SELECT cust_id, ROUND(SUM(hours)::NUMERIC, 2) AS total_hours
FROM intervals
GROUP BY cust_id
ORDER BY cust_id;