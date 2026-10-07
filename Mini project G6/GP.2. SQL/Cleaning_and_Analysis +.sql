USE coffee_shop_db;
GO

-- =============================================
-- SECTION 1: DATABASE CLEANING & VIEW CREATION
-- =============================================
CREATE OR ALTER VIEW vw_coffee_sales AS
SELECT 
    transaction_id,
    transaction_date,
    transaction_time,
    transaction_qty,
    store_id,
    store_location,
    product_id,
    unit_price,
    product_category,
    product_type,
    product_detail,
    -- حساب إجمالي المبيعات داخل الـ View لتسهيل استدعائه لاحقاً من عمود جاهز
    (CAST(transaction_qty AS INT) * CAST(unit_price AS FLOAT)) AS total_sales,
    DATENAME(WEEKDAY, transaction_date) AS day_name,
    DATEPART(WEEKDAY, transaction_date) AS day_of_week,
    DATEPART(HOUR, transaction_time) AS sale_hour,
    CASE 
        WHEN DATEPART(HOUR, transaction_time) BETWEEN 6 AND 11 THEN 'Morning Rush'
        WHEN DATEPART(HOUR, transaction_time) BETWEEN 12 AND 16 THEN 'Afternoon'
        WHEN DATEPART(HOUR, transaction_time) BETWEEN 17 AND 20 THEN 'Evening'
        ELSE 'Off-Hours'
    END AS day_part
FROM coffee_shop_sales;
GO

-- =============================================
-- SECTION 2: BUSINESS ANALYSIS QUERIES (Group 2)
-- =============================================

-- 1. تحليل أوقات الذروة (Peak Hours) باستخدام عمود total_sales الجاهز
SELECT     
    sale_hour,    
    COUNT(DISTINCT transaction_id) AS total_orders,    
    SUM(CAST(transaction_qty AS INT)) AS total_items_sold,    
    ROUND(SUM(total_sales), 2) AS total_revenue
FROM vw_coffee_sales
GROUP BY sale_hour
ORDER BY total_revenue DESC;

-- 2. المبيعات حسب أيام الأسبوع باستخدام عمود total_sales الجاهز
SELECT     
    day_name,    
    COUNT(DISTINCT transaction_id) AS total_orders,    
    ROUND(SUM(total_sales), 2) AS total_revenue
FROM vw_coffee_sales
GROUP BY day_name, day_of_week
ORDER BY day_of_week;

-- 3. أعلى 5 منتجات مبيعاً مع إضافة شرط الترتيب الثانوي لعدم التعادل
SELECT TOP 5    
    product_category,    
    product_type,    
    SUM(CAST(transaction_qty AS INT)) AS total_quantity_sold,    
    ROUND(SUM(total_sales), 2) AS total_revenue
FROM vw_coffee_sales
GROUP BY product_category, product_type
ORDER BY total_quantity_sold DESC, total_revenue DESC;
-- 4. تحليل أداء الورديات خلال اليوم (Day Part Performance)
SELECT 
    day_part,
    COUNT(DISTINCT transaction_id)      AS total_orders,
    SUM(CAST(transaction_qty AS INT))   AS total_items_sold,
    ROUND(SUM(total_sales), 2)          AS total_revenue,
    ROUND(AVG(total_sales), 2)          AS avg_transaction_value
FROM vw_coffee_sales
GROUP BY day_part
ORDER BY total_revenue DESC;
-- 5. مقارنة أداء الفروع المختلفة (Store Location Performance)
SELECT 
    store_id,
    store_location,
    COUNT(DISTINCT transaction_id)      AS total_orders,
    SUM(CAST(transaction_qty AS INT))   AS total_items_sold,
    ROUND(SUM(total_sales), 2)          AS total_revenue
FROM vw_coffee_sales
GROUP BY store_id, store_location
ORDER BY total_revenue DESC;
-- =============================================
-- OPTIONAL: OVERALL KPIs (تحسين احترافي لاستخراج إجماليات التقرير)
-- =============================================
SELECT 
    COUNT(DISTINCT transaction_id) AS total_orders,
    SUM(CAST(transaction_qty AS INT)) AS total_quantities,
    ROUND(SUM(total_sales), 2) AS total_revenue,
ROUND(SUM(total_sales) / COUNT(DISTINCT transaction_id), 2) AS average_order_value
FROM vw_coffee_sales;
