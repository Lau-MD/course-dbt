{{
  config(
    materialized='view'
  )
}}

WITH product AS (
    SELECT * FROM {{ ref('stg_greenery__products') }}
), 

order_items AS (
    SELECT * FROM {{ ref('stg_greenery__order_items') }}
),

orders AS (
    SELECT * FROM {{ ref('stg_greenery__orders') }}
),

product_order_items AS (
    SELECT
        p.product_id,
        p.product_name,
        DATE_TRUNC(day, o.order_created_at) as date,
        SUM(oi.quantity) AS orders,
        SUM(oi.quantity*p.price) AS revenue
    FROM product p
    LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
    LEFT JOIN orders o
    ON o.order_id = oi.order_id
    GROUP BY 1,2,3
)
SELECT 
    product_id,
    product_name,
    AVG(orders) AS daily_orders,
    AVG(revenue) AS daily_revenue 
FROM product_order_items
GROUP BY 1,2
ORDER BY 4 DESC