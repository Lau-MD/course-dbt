{{
  config(
    materialized='view'
  )
}}

WITH promos AS (
    SELECT * FROM {{ ref('stg_greenery__promos') }}
), 

orders AS (
    SELECT * FROM {{ ref('stg_greenery__orders') }}
)

SELECT
    p.promo_id,
    p.discount,
    p.status,
    COUNT(distinct o.order_id) AS promo_order_count,
    SUM(order_total)*(p.discount) AS promo_cost  
FROM promos p
LEFT JOIN orders o
ON p.promo_id = o.promo_id
GROUP BY 1,2,3
ORDER BY promo_cost DESC