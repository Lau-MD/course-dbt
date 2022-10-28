WITH

products AS (
    SELECT * FROM {{ ref('int_product_orders2') }}
)

, product_events AS (
    SELECT * FROM {{ ref('int_product_events2') }}
)

, final AS (
    SELECT prods.product_id
         , prods.product_name
         , prods.price
         , prods.inventory
         , prods.average_daily_orders
         , prod_events.total_page_view
         , prod_events.total_add_to_cart
         , prod_events.total_checkout
         , prods.total_product_sold
      FROM products AS prods
           LEFT JOIN product_events AS prod_events
           ON prods.product_id = prod_events.product_id
)

SELECT * FROM final