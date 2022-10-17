{{
  config(
    materialized='view'
  )
}}

WITH orders AS (
    SELECT * FROM {{ ref('stg_greenery__orders') }}
),

order_items AS (
    SELECT * FROM {{ ref('stg_greenery__order_items') }}
),

promos AS (
    SELECT * FROM {{ ref('stg_greenery__promos') }}
),

item_count AS (
    SELECT
        order_id,
        SUM(quantity) AS item_count
    FROM order_items
    GROUP BY 1
),

promo_discount AS (
    SELECT
        promo_id,
        discount
    FROM promos
)

SELECT 
    o.order_id,
    user_id,
    o.promo_id,
    pd.discount,
    address_id,
    order_created_at,
    order_cost,
    shipping_cost,
    order_total,
    tracking_id,
    shipping_service,
    estimated_delivery_at,
    delivered_at,
    o.status,
    item_count
FROM orders o
LEFT JOIN item_count ic
ON o.order_id = ic.order_id
LEFT JOIN promo_discount pd
ON o.promo_id = pd.promo_id
ORDER BY 1