-- Challenge 04 – Search Success Rate by User Segment (NEW vs EXISTING)
-- A search is "successful" if the FIRST click in the same (user, query, session)
-- occurs within 30 seconds AFTER the search event.

CREATE SCHEMA IF NOT EXISTS c04_search_success;
SET search_path TO c04_search_success,public;

DROP TABLE IF EXISTS accounts CASCADE;
DROP TABLE IF EXISTS search_events CASCADE;
DROP TABLE IF EXISTS expected_output CASCADE;

-- 1) Users (registration_date defines segment)
CREATE TABLE accounts (
    user_id BIGINT PRIMARY KEY,
    registration_date DATE,
    country TEXT
);

-- 2) Event log (both search and click)
CREATE TABLE search_events (
    event_id BIGINT PRIMARY KEY,
    user_id BIGINT,
    query TEXT,
    event_timestamp TIMESTAMP,
    event_type TEXT,          -- 'search' | 'click'
    session_id TEXT
);

-- 3) Final expected output table
CREATE TABLE expected_output (
    user_segment TEXT,
    total_searches BIGINT,
    successful_searches BIGINT,
    success_rate NUMERIC(6,2)
);

-- ------------------------------------------------------------
-- Seed data (MORE than in the screenshots)
-- Latest event date in this dataset = 2025-10-31 → "new" = registered >= 2025-10-01
-- ------------------------------------------------------------

INSERT INTO accounts (user_id, registration_date, country) VALUES
-- Existing (before 2025-10-01)
(101, '2025-09-25', 'USA'),
(102, '2025-09-28', 'Canada'),
(106, '2025-08-15', 'USA'),
(107, '2025-09-05', 'UK'),
(110, '2025-09-12', 'USA'),
(112, '2025-09-30', 'USA'),
(115, '2025-09-01', 'Germany'),
-- New (on/after 2025-10-01)
(103, '2025-10-01', 'USA'),
(104, '2025-10-05', 'UK'),
(105, '2025-10-10', 'USA'),
(108, '2025-10-15', 'France'),
(109, '2025-10-20', 'USA'),
(111, '2025-10-29', 'Canada'),
(113, '2025-10-02', 'USA'),
(114, '2025-10-18', 'Spain'),
(116, '2025-10-25', 'USA');

-- Helper: times around Oct 22–31
-- We'll add ~40+ search events across users and sessions, with mixed outcomes.

-- user 101 (existing) – 3 searches, 2 successful, 1 >30s fail
INSERT INTO search_events VALUES
(1001,101,'laptop deals','2025-10-22 10:00:00','search','S101-1'),
(1002,101,'laptop deals','2025-10-22 10:00:12','click','S101-1'),
(1003,101,'gaming laptop','2025-10-22 10:05:00','search','S101-1'),
(1004,101,'gaming laptop','2025-10-22 10:05:20','click','S101-1'),
(1005,101,'4k monitor','2025-10-23 09:00:00','search','S101-2'),
(1006,101,'4k monitor','2025-10-23 09:00:45','click','S101-2'); -- >30s fail

-- user 102 (existing) – 2 searches, 1 success, 1 no click
INSERT INTO search_events VALUES
(1010,102,'winter jacket','2025-10-22 11:00:00','search','S102-1'),
(1011,102,'winter jacket','2025-10-22 11:00:20','click','S102-1'),
(1012,102,'snow boots','2025-10-23 08:10:00','search','S102-2');

-- user 106 (existing) – 3 searches, 1 success, 1 late click, 1 none
INSERT INTO search_events VALUES
(1020,106,'noise cancelling','2025-10-23 14:00:00','search','S106-1'),
(1021,106,'noise cancelling','2025-10-23 14:00:50','click','S106-1'), -- >30s
(1022,106,'earbuds','2025-10-23 14:10:00','search','S106-1'),
(1023,106,'earbuds','2025-10-23 14:10:25','click','S106-1'),         -- success
(1024,106,'soundbar','2025-10-23 14:15:00','search','S106-2');

-- user 107 (existing) – 4 searches, 2 success, 2 fail
INSERT INTO search_events VALUES
(1030,107,'bike light','2025-10-24 09:00:00','search','S107-1'),
(1031,107,'bike light','2025-10-24 09:00:35','click','S107-1'),       -- >30s
(1032,107,'helmet','2025-10-24 09:05:00','search','S107-1'),
(1033,107,'helmet','2025-10-24 09:05:18','click','S107-1'),           -- success
(1034,107,'lock','2025-10-24 09:06:00','search','S107-1'),
(1035,107,'lock','2025-10-24 09:06:40','click','S107-1'),             -- >30s
(1036,107,'pump','2025-10-24 09:10:00','search','S107-2'),
(1037,107,'pump','2025-10-24 09:10:28','click','S107-2');             -- success

-- user 110 (existing) – 3 searches, 1 success, 2 none
INSERT INTO search_events VALUES
(1040,110,'sofa','2025-10-25 10:00:00','search','S110-1'),
(1041,110,'sofa','2025-10-25 10:00:15','click','S110-1'),             -- success
(1042,110,'table','2025-10-25 10:10:00','search','S110-2'),
(1043,110,'chair','2025-10-25 10:20:00','search','S110-2');

-- user 112 (existing) – 2 searches, 0 success (late & none)
INSERT INTO search_events VALUES
(1050,112,'camera','2025-10-26 08:00:00','search','S112-1'),
(1051,112,'camera','2025-10-26 08:00:40','click','S112-1'),           -- >30s
(1052,112,'tripod','2025-10-26 08:10:00','search','S112-2');

-- user 115 (existing) – 2 searches, 1 success, 1 none
INSERT INTO search_events VALUES
(1060,115,'drill','2025-10-27 12:00:00','search','S115-1'),
(1061,115,'drill','2025-10-27 12:00:22','click','S115-1'),            -- success
(1062,115,'saw','2025-10-27 12:05:00','search','S115-1');

-- ===== NEW USERS =====

-- user 103 (new) – 4 searches, 3 success, 1 none
INSERT INTO search_events VALUES
(1100,103,'tablet','2025-10-22 12:00:00','search','S103-1'),
(1101,103,'tablet','2025-10-22 12:00:10','click','S103-1'),           -- success
(1102,103,'stylus','2025-10-22 12:05:00','search','S103-1'),
(1103,103,'stylus','2025-10-22 12:05:27','click','S103-1'),           -- success
(1104,103,'case','2025-10-22 12:06:00','search','S103-2'),
(1105,103,'case','2025-10-22 12:06:40','click','S103-2'),             -- >30s
(1106,103,'keyboard','2025-10-22 12:15:00','search','S103-3');

-- user 104 (new) – 3 searches, 2 success, 1 none
INSERT INTO search_events VALUES
(1110,104,'coffee beans','2025-10-23 07:30:00','search','S104-1'),
(1111,104,'coffee beans','2025-10-23 07:30:20','click','S104-1'),     -- success
(1112,104,'grinder','2025-10-23 07:35:00','search','S104-1'),
(1113,104,'grinder','2025-10-23 07:35:25','click','S104-1'),          -- success
(1114,104,'kettle','2025-10-23 07:40:00','search','S104-2');

-- user 105 (new) – 4 searches, 3 success, 1 late
INSERT INTO search_events VALUES
(1120,105,'keyboard','2025-10-23 18:00:00','search','S105-1'),
(1121,105,'keyboard','2025-10-23 18:00:18','click','S105-1'),         -- success
(1122,105,'mouse','2025-10-23 18:05:00','search','S105-1'),
(1123,105,'mouse','2025-10-23 18:05:20','click','S105-1'),            -- success
(1124,105,'mat','2025-10-23 18:06:00','search','S105-2'),
(1125,105,'mat','2025-10-23 18:06:45','click','S105-2'),              -- >30s
(1126,105,'hub','2025-10-23 18:10:00','search','S105-2'),
(1127,105,'hub','2025-10-23 18:10:25','click','S105-2');              -- success

-- user 108 (new) – 3 searches, 2 success, 1 none
INSERT INTO search_events VALUES
(1130,108,'tennis racket','2025-10-24 16:00:00','search','S108-1'),
(1131,108,'tennis racket','2025-10-24 16:00:25','click','S108-1'),    -- success
(1132,108,'balls','2025-10-24 16:05:00','search','S108-1'),
(1133,108,'balls','2025-10-24 16:05:26','click','S108-1'),            -- success
(1134,108,'grip','2025-10-24 16:06:00','search','S108-2');

-- user 109 (new) – 4 searches, 3 success, 1 none
INSERT INTO search_events VALUES
(1140,109,'lamp','2025-10-25 19:00:00','search','S109-1'),
(1141,109,'lamp','2025-10-25 19:00:16','click','S109-1'),             -- success
(1142,109,'bulb','2025-10-25 19:05:00','search','S109-1'),
(1143,109,'bulb','2025-10-25 19:05:21','click','S109-1'),             -- success
(1144,109,'shade','2025-10-25 19:06:00','search','S109-2'),
(1145,109,'shade','2025-10-25 19:06:31','click','S109-2'),            -- >30s
(1146,109,'switch','2025-10-25 19:10:00','search','S109-2'),
(1147,109,'switch','2025-10-25 19:10:12','click','S109-2');           -- success

-- user 111 (new) – 2 searches, both success
INSERT INTO search_events VALUES
(1150,111,'suitcase','2025-10-29 09:00:00','search','S111-1'),
(1151,111,'suitcase','2025-10-29 09:00:14','click','S111-1'),
(1152,111,'bag tag','2025-10-29 09:05:00','search','S111-1'),
(1153,111,'bag tag','2025-10-29 09:05:22','click','S111-1');

-- user 113 (new) – 3 searches, 1 success, 1 late, 1 none
INSERT INTO search_events VALUES
(1160,113,'ssd','2025-10-30 13:00:00','search','S113-1'),
(1161,113,'ssd','2025-10-30 13:00:40','click','S113-1'),              -- >30s
(1162,113,'hdd','2025-10-30 13:05:00','search','S113-1'),
(1163,113,'hdd','2025-10-30 13:05:26','click','S113-1'),              -- success
(1164,113,'enclosure','2025-10-30 13:10:00','search','S113-2');

-- user 114 (new) – 2 searches, 1 success, 1 none
INSERT INTO search_events VALUES
(1170,114,'pan','2025-10-31 08:00:00','search','S114-1'),
(1171,114,'pan','2025-10-31 08:00:18','click','S114-1'),              -- success
(1172,114,'spatula','2025-10-31 08:05:00','search','S114-1');

-- user 116 (new) – 2 searches, both success
INSERT INTO search_events VALUES
(1180,116,'jacket','2025-10-31 21:00:00','search','S116-1'),
(1181,116,'jacket','2025-10-31 21:00:15','click','S116-1'),
(1182,116,'gloves','2025-10-31 21:10:00','search','S116-1'),
(1183,116,'gloves','2025-10-31 21:10:20','click','S116-1');

-- ------------------------------------------------------------
-- Compute EXPECTED OUTPUT (derived from the data above)
-- ------------------------------------------------------------

WITH max_date AS (
  SELECT MAX(event_timestamp) AS max_event_date FROM search_events
),
user_segments AS (
  SELECT a.user_id,
         CASE
           WHEN a.registration_date >= (SELECT max_event_date FROM max_date) - INTERVAL '30 days'
             THEN 'new'
           ELSE 'existing'
         END AS user_segment
  FROM accounts a
),
searches AS (
  SELECT user_id, query, session_id, event_timestamp AS search_timestamp
  FROM search_events
  WHERE event_type = 'search'
),
clicks AS (
  SELECT user_id, query, session_id,
         event_timestamp AS click_timestamp,
         ROW_NUMBER() OVER (PARTITION BY user_id, query, session_id ORDER BY event_timestamp) AS click_rank
  FROM search_events
  WHERE event_type = 'click'
),
search_with_clicks AS (
  SELECT s.user_id, s.query, s.session_id, s.search_timestamp,
         c.click_timestamp,
         EXTRACT(EPOCH FROM (c.click_timestamp - s.search_timestamp)) AS time_diff_seconds
  FROM searches s
  LEFT JOIN clicks c
    ON c.user_id = s.user_id
   AND c.query = s.query
   AND c.session_id = s.session_id
   AND c.click_rank = 1
   AND c.click_timestamp >= s.search_timestamp
),
search_success AS (
  SELECT us.user_segment,
         COUNT(*) AS total_searches,
         SUM(CASE WHEN swc.time_diff_seconds IS NOT NULL AND swc.time_diff_seconds <= 30 THEN 1 ELSE 0 END) AS successful_searches
  FROM search_with_clicks swc
  JOIN user_segments us ON us.user_id = swc.user_id
  GROUP BY us.user_segment
)
INSERT INTO expected_output (user_segment, total_searches, successful_searches, success_rate)
SELECT user_segment,
       total_searches,
       successful_searches,
       ROUND(successful_searches::NUMERIC / NULLIF(total_searches,0), 2) AS success_rate
FROM search_success
ORDER BY user_segment;
