{{
  config(
    materialized='view'
  )
}}

WITH events AS (
    SELECT * FROM {{ ref('stg_greenery__events') }}
), 

users AS (
    SELECT * FROM {{ ref('stg_greenery__users') }}
)

SELECT 
    e.session_id,
    e.user_id,
    u.first_name,
    u.last_name,
    MIN(e.event_created_at) as session_start,
    MAX(e.event_created_at) as session_end,
    DATEDIFF(m,session_start, session_end) as session_length_mins,
    COUNT(CASE WHEN e.event_type = 'page_view' THEN 1 ELSE 0 END) AS session_page_views,
    COUNT(CASE WHEN e.event_type = 'add_to_cart' THEN 1 ELSE 0 END) AS session_add_to_carts,
    COUNT(CASE WHEN e.event_type = 'checkout' THEN 1 ELSE 0 END) AS session_checkouts
FROM events e
LEFT JOIN users u
ON e.user_id = u.user_id
WHERE event_type <> 'package_shipped'
GROUP BY 1,2,3,4