USE coffee_shop_db;
GO

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

    -- إجمالي الإيراد
    (transaction_qty * unit_price) AS total_sales,

    -- اسم اليوم
    DATENAME(WEEKDAY, transaction_date) AS day_name,

    -- رقم اليوم لترتيب الأيام
    DATEPART(WEEKDAY, transaction_date) AS day_of_week,

    -- الساعة اللي حصل فيها البيع
    DATEPART(HOUR, transaction_time) AS sale_hour,

    -- تقسيم اليوم لورديات
    CASE
        WHEN DATEPART(HOUR, transaction_time) BETWEEN 6 AND 11 THEN 'Morning Rush'
        WHEN DATEPART(HOUR, transaction_time) BETWEEN 12 AND 16 THEN 'Afternoon'
        WHEN DATEPART(HOUR, transaction_time) BETWEEN 17 AND 20 THEN 'Evening'
        ELSE 'Off-Hours'
    END AS day_part
FROM coffee_shop_sales;
GO