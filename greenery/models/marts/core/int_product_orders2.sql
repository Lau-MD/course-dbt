WITH

products AS (
    SELECT * FROM {{ ref('stg_greenery__products') }}
)

, orders AS (
    SELECT * FROM {{ ref('stg_greenery__orders') }}
)

, order_items AS (
    SELECT * FROM {{ ref('stg_greenery__order_items') }}
)

, product_daily_orders AS (
    SELECT oi.product_id
         , date_trunc('day', o.order_created_at) AS order_date
         , oi.quantity
      FROM order_items AS oi
           LEFT JOIN orders AS o
           USING (order_id)
)

, daily_totals AS (
    SELECT product_id
         , order_date
         , count(product_id) AS daily_orders_on_product
         , sum(quantity) AS daily_total_ordered
      FROM product_daily_orders
     GROUP BY 1, 2
)

, product_stats AS (
    SELECT product_id
         , avg(daily_orders_on_product) AS average_daily_orders
         , sum(daily_total_ordered) AS total_product_sold
      FROM daily_totals
  GROUP BY 1
)

, final AS (
    SELECT s.product_id
         , p.product_name
         , p.price
         , p.inventory
         , s.average_daily_orders
         , s.total_product_sold
      FROM product_stats AS s
           LEFT JOIN products AS p
           USING (product_id)
)

SELECT * FROM final