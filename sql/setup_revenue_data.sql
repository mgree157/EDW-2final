-- =========================================================
-- EDW-2 Snowflake Setup: Revenue Data + Analytics Views
-- =========================================================
-- Save this file as: sql/setup_revenue_data.sql
-- Run in Snowflake Worksheets as ACCOUNTADMIN (or equivalent).
-- =========================================================

-- 1. Role & Warehouse (edit warehouse name if needed)
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE EDW_COMPUTE_WH;

-- 2. Create database and schema (idempotent)
CREATE DATABASE IF NOT EXISTS EDW_2_DB;
CREATE SCHEMA IF NOT EXISTS EDW_2_DB.REASONING;

USE DATABASE EDW_2_DB;
USE SCHEMA REASONING;

-- 3. Create base revenue table
--    Columns:
--      QUARTER  (e.g., '2024-Q1')
--      REGION   (e.g., 'North America')
--      PRODUCT  (e.g., 'Aerospace - Flight Controls')
--      REVENUE  (numeric)
--      COST     (numeric)

CREATE OR REPLACE TABLE REVENUE_TABLE (
    QUARTER STRING,
    REGION  STRING,
    PRODUCT STRING,
    REVENUE NUMBER,
    COST    NUMBER
);

-- 4. Load mock Honeywell-style revenue data (16 rows)

TRUNCATE TABLE REVENUE_TABLE;

INSERT INTO REVENUE_TABLE (QUARTER, REGION, PRODUCT, REVENUE, COST) VALUES
    ('2024-Q1', 'North America', 'Aerospace - Flight Controls',          500000, 340000),
    ('2024-Q1', 'North America', 'Industrial Safety - Gas Detection',     260000, 190000),
    ('2024-Q1', 'Europe',        'Aerospace - Flight Controls',          360000, 250000),
    ('2024-Q1', 'Europe',        'Industrial Safety - Gas Detection',    190000, 140000),

    ('2024-Q2', 'North America', 'Aerospace - Flight Controls',          525000, 355000),
    ('2024-Q2', 'North America', 'Industrial Safety - Gas Detection',     275000, 200000),
    ('2024-Q2', 'Europe',        'Aerospace - Flight Controls',          375000, 260000),
    ('2024-Q2', 'Europe',        'Industrial Safety - Gas Detection',    205000, 150000),

    ('2024-Q3', 'North America', 'Aerospace - Flight Controls',          540000, 365000),
    ('2024-Q3', 'North America', 'Industrial Safety - Gas Detection',     290000, 210000),
    ('2024-Q3', 'Europe',        'Aerospace - Flight Controls',          340000, 240000),
    ('2024-Q3', 'Europe',        'Industrial Safety - Gas Detection',    180000, 135000),

    ('2024-Q4', 'North America', 'Aerospace - Flight Controls',          580000, 390000),
    ('2024-Q4', 'North America', 'Industrial Safety - Gas Detection',     310000, 225000),
    ('2024-Q4', 'Europe',        'Aerospace - Flight Controls',          395000, 275000),
    ('2024-Q4', 'Europe',        'Industrial Safety - Gas Detection',    215000, 160000);

-- Should return 16 rows
SELECT COUNT(*) AS ROWS_IN_REVENUE_TABLE FROM REVENUE_TABLE;
SELECT * FROM REVENUE_TABLE ORDER BY QUARTER, REGION, PRODUCT;

-- 5. Analytics views expected by the app
--    These views provide:
--      TOTAL_REVENUE
--      TOTAL_COST
--      TOTAL_PROFIT (REVENUE - COST)

-- 5.1 Revenue by Quarter
CREATE OR REPLACE VIEW V_REVENUE_BY_QUARTER AS
SELECT
    QUARTER,
    SUM(REVENUE)              AS TOTAL_REVENUE,
    SUM(COST)                 AS TOTAL_COST,
    SUM(REVENUE - COST)       AS TOTAL_PROFIT
FROM REVENUE_TABLE
GROUP BY QUARTER
ORDER BY QUARTER;

-- 5.2 Revenue by Region
CREATE OR REPLACE VIEW V_REVENUE_BY_REGION AS
SELECT
    QUARTER,
    REGION,
    SUM(REVENUE)              AS TOTAL_REVENUE,
    SUM(COST)                 AS TOTAL_COST,
    SUM(REVENUE - COST)       AS TOTAL_PROFIT
FROM REVENUE_TABLE
GROUP BY QUARTER, REGION
ORDER BY QUARTER, REGION;

-- 5.3 Revenue by Product
CREATE OR REPLACE VIEW V_REVENUE_BY_PRODUCT AS
SELECT
    QUARTER,
    PRODUCT,
    SUM(REVENUE)              AS TOTAL_REVENUE,
    SUM(COST)                 AS TOTAL_COST,
    SUM(REVENUE - COST)       AS TOTAL_PROFIT
FROM REVENUE_TABLE
GROUP BY QUARTER, PRODUCT
ORDER BY QUARTER, PRODUCT;

-- Check views
SELECT * FROM V_REVENUE_BY_QUARTER  ORDER BY QUARTER;
SELECT * FROM V_REVENUE_BY_REGION   ORDER BY QUARTER, REGION;
SELECT * FROM V_REVENUE_BY_PRODUCT  ORDER BY QUARTER, PRODUCT;