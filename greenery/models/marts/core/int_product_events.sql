{{
  config(
    materialized='view'
  )
}}

WITH events AS (
    SELECT * FROM {{ ref('stg_greenery__events') }}
), 

product_date_events AS (
    SELECT
        product_id,
        DATE_TRUNC(day, event_created_at) AS date,
        SUM(CASE WHEN event_type = 'page_view' THEN 1 ELSE 0 END) AS page_views,
        SUM(CASE WHEN event_type = 'add_to_cart' THEN 1 ELSE 0 END) AS add_to_carts,
        SUM(CASE WHEN event_type = 'checkout' THEN 1 ELSE 0 END) AS checkouts
    FROM events
    WHERE product_id IS NOT NULL
    GROUP BY 1,2
    ORDER BY 1
)
SELECT
    product_id,
    AVG(page_views) AS daily_page_views,
    AVG(add_to_carts) AS daily_add_to_carts
FROM product_date_events
GROUP BY 1