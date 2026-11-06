IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'retail_store_forecasting_db')
BEGIN
    CREATE DATABASE retail_store_forecasting_db;
END;
GO

USE retail_store_forecasting_db;
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='store_sales' AND xtype='U')
BEGIN
    CREATE TABLE store_sales (
        id INT,
        date VARCHAR(50),
        store_nbr INT,
        family VARCHAR(100),
        sales DECIMAL(12, 4),
        onpromotion INT
    );
END;
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='holidays_events' AND xtype='U')
BEGIN
    CREATE TABLE holidays_events (
        date VARCHAR(50),
        type VARCHAR(50),
        locale VARCHAR(50),
        locale_name VARCHAR(100),
        description VARCHAR(255),
        transferred VARCHAR(10)
    );
END;
GO

IF OBJECT_ID('daily_sales_cleaned', 'U') IS NOT NULL
    DROP TABLE daily_sales_cleaned;
GO

WITH daily AS (
    SELECT COALESCE(TRY_CONVERT(DATE, [date], 23), TRY_CONVERT(DATE, [date], 103)) AS sale_date,
           SUM(sales) AS total_sales
    FROM store_sales
    GROUP BY COALESCE(TRY_CONVERT(DATE, [date], 23), TRY_CONVERT(DATE, [date], 103))
),
hol AS (
    SELECT COALESCE(TRY_CONVERT(DATE, [date], 23), TRY_CONVERT(DATE, [date], 103)) AS hol_date,
           1 AS is_holiday
    FROM holidays_events
    WHERE transferred = 'False'
      AND type <> 'Work Day'
    GROUP BY COALESCE(TRY_CONVERT(DATE, [date], 23), TRY_CONVERT(DATE, [date], 103))
)
SELECT d.sale_date                          AS [date],
       CAST(d.total_sales AS DECIMAL(12,2)) AS total_sales,
       COALESCE(h.is_holiday, 0)            AS is_holiday
INTO daily_sales_cleaned
FROM daily d
LEFT JOIN hol h ON h.hol_date = d.sale_date;
GO

SELECT COUNT(*) AS days, MIN([date]) AS first_day, MAX([date]) AS last_day,
       SUM(total_sales) AS grand_total, SUM(is_holiday) AS holiday_days,
       SUM(CASE WHEN [date] IS NULL THEN 1 ELSE 0 END) AS null_dates
FROM daily_sales_cleaned;
GO