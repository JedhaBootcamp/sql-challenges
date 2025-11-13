-- Challenge 02 – Recommendation System
CREATE SCHEMA IF NOT EXISTS c02_recommendation;
SET search_path TO c02_recommendation,public;

DROP TABLE IF EXISTS users_friends CASCADE;
DROP TABLE IF EXISTS users_pages CASCADE;
DROP TABLE IF EXISTS expected_output CASCADE;

CREATE TABLE users_friends(user_id BIGINT, friend_id BIGINT);
CREATE TABLE users_pages(user_id BIGINT, page_id BIGINT);
CREATE TABLE expected_output(user_id BIGINT, page_id BIGINT);

-- Friend edges (both directions included)
INSERT INTO users_friends(user_id, friend_id) VALUES
 (1,2),(1,3),(1,4),
 (2,1),(2,3),(2,5),
 (3,1),(3,4),(3,6),
 (4,1),(4,3),(4,7),
 (5,2),(5,6),(5,8),
 (6,3),(6,5),(6,7),(6,9),
 (7,4),(7,6),(7,10),
 (8,5),(8,9),
 (9,6),(9,8),(9,10),
 (10,7),(10,9);

-- Page follows
INSERT INTO users_pages(user_id, page_id) VALUES
 (1,101),(1,102),
 (2,101),(2,103),
 (3,103),(3,104),
 (4,104),
 (5,105),(5,106),
 (6,106),(6,107),
 (7,107),
 (8,102),(8,105),
 (9,108),
 (10,101),(10,108);

-- Ground truth: pages user doesn't follow but at least one friend does
INSERT INTO expected_output(user_id, page_id)
SELECT DISTINCT fp.user_id, fp.page_id
FROM (
  SELECT uf.user_id, up.page_id
  FROM users_friends uf
  JOIN users_pages  up
    ON up.user_id = uf.friend_id
) fp
LEFT JOIN users_pages up
  ON up.user_id = fp.user_id AND up.page_id = fp.page_id
WHERE up.page_id IS NULL
ORDER BY fp.user_id, fp.page_id;
