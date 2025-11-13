# 🧠 SQL Practice Challenges

Welcome to your **SQL Challenge Repository** — a collection of real-world problems inspired by data teams at top tech companies like LinkedIn, Meta, Apple, Microsoft, and Shopify.

Each challenge mirrors the kind of reasoning and data manipulation you’ll face in analytics or data engineering interviews.

## ⚙️ Setup

You can run all challenges **locally** using Docker + pgweb.

### 1. Start your local environment

```bash
docker compose up -d
```

This spins up:

* a **PostgreSQL** container (preloaded with all challenges)
* a **pgweb** container at [http://localhost:8081](http://localhost:8081)

### 2. Access the database

Open [pgweb](http://localhost:8081) → click *Connect* → choose the `postgres` database.

Each challenge lives in its own **schema**:

```
c01_salary_difference
c02_recommendation
c03_customers_orders
c04_search_success
c05_downloads_by_segment
c06_active_hours
```

### 3. Reset the lab 

If you need to reset the lab:

```bash
docker compose down && docker volume rm pgweb_pgdata && docker compose up
```


## 🧩 Challenges Overview

Each folder in `db/init/` contains a realistic mini-project, with preloaded tables and an `expected_output` for validation.
Below are the company contexts and focus areas.

| Challenge           | Company                | Topic                        | Focus                         |
| ------------------- | ---------------------- | ---------------------------- | ----------------------------- |
| **c01 – LinkedIn**  | HR Analytics           | Salary Analysis              | Conditional Aggregation       |
| **c02 – Meta**      | Recommendation Systems | Friends & Pages              | Self-Join + EXCEPT            |
| **c03 – Apple**     | Retail CRM             | Customer Orders              | LEFT JOIN                     |
| **c04 – Microsoft** | Search Analytics       | Success Rate by User Segment | Window Functions & Time Diffs |
| **c05 – Microsoft** | App Store Insights     | Paying vs Non-Paying         | Conditional SUM + Filtering   |
| **c06 – Shopify**   | Session Tracking       | User Active Time             | LEAD() + Duration Calculation |


## 🧰 Directory Structure

```
.
├── db/
│   └── init/
│       ├── 01_c01_salary_difference.sql
│       ├── 02_c02_recommendation.sql
│       ├── 03_c03_customers_orders.sql
│       ├── 04_c04_search_success.sql
│       ├── 05_c05_downloads_by_segment.sql
│       └── 06_c06_active_hours.sql
└── README.md
```

## 📊 How to Work on Each Challenge

1. **Read the assignment** (inside [Julie](https://app.jedha.co))

Each challenge includes:

* a problem description
* the database schema (tables + columns)
* the expected output format

3. **Write your query**

   Open pgweb 👉 paste your SQL 👉 run and verify.

4. **Compare with the expected result**

   Each challenge includes a table `expected_output`.
   You can test your solution using:

   ```sql
   SELECT * FROM expected_output;
   ```


## 🧑‍💻 Contribute or Extend

You can easily create new challenges by:

* Adding a new SQL file under `db/init/`
* Following the naming convention:
  `XX_cYY_<short_title>.sql`
* Creating at least one table named `expected_output` with your computed answer.


## 🚀 Goals

This repo is part of **Jedha’s SQL module**, helping you:

* Master real interview-style SQL questions
* Learn how to read data schemas and transform them
* Practice using CTEs, window functions, and conditional logic


💬 *Tip:* Each dataset is realistic and intentionally a bit messy. Think like a data analyst: **break the problem down**, test intermediate results, and focus on correctness first, optimization later.


**Created by:**
🧠 *Jedha Data & AI School*
📍 [https://jedha.co](https://jedha.co)
