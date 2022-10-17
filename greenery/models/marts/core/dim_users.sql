{{
  config(
    materialized='view'
  )
}}

WITH users AS (
    SELECT * FROM {{ ref('stg_greenery__users') }}
),

events AS (
    SELECT * FROM {{ ref('stg_greenery__events') }}
), 

orders AS (
    SELECT * FROM {{ ref('stg_greenery__orders') }}
), 

order_items AS (
    SELECT * FROM {{ ref('stg_greenery__order_items') }}
), 

addresses AS (
    SELECT * FROM {{ ref('stg_greenery__addresses') }}
),

user_events AS (
    SELECT
        user_id,
        COUNT(distinct session_id) AS total_sessions
    FROM events
    GROUP BY 1 
),

user_orders AS (
    SELECT
        user_id,
        COUNT(distinct order_id) AS total_orders,
        SUM(order_total) AS total_spend
    FROM orders
    GROUP BY 1 
),

user_order_items AS(
    SELECT
        u.user_id,
        COUNT(oi.quantity) AS items_ordered
    FROM users u
    LEFT JOIN orders o
    ON u.user_id = o.user_id
    LEFT JOIN order_items oi
    ON o.order_id = oi.order_id
    GROUP BY 1
)
SELECT 
    u.user_id, 
    u.first_name, 
    u.last_name,
    u.user_created_at,
    u.user_updated_at,
    u.email,
    u.phone_number,
    u.address_id,
    a.address,
    a.zipcode,
    a.state,
    a.country,
    COALESCE(ue.total_sessions,0) AS total_sessions,
    COALESCE(uo.total_orders,0) AS total_orders,
    COALESCE(uoi.items_ordered,0) AS total_items_ordered,
    COALESCE(uo.total_spend,0) AS total_spend
FROM users u
LEFT JOIN user_orders uo
ON u.user_id = uo.user_id
LEFT JOIN user_events ue
ON u.user_id = ue.user_id
LEFT JOIN user_order_items uoi
ON u.user_id = uoi.user_id
LEFT JOIN addresses a
ON u.address_id = a.address_id
ORDER BY total_spend DESC