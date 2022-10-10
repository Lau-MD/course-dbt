{{
  config(
    materialized='view'
  )
}}

with orders_source as (
  select * from {{ source('src_greenery', 'orders') }}
)

, renamed_casted as(
  select
    order_id,
    user_id,
    promo_id,
    address_id,
    created_at as order_created_at,
    order_cost,
    shipping_cost,
    order_total,
    tracking_id,
    shipping_service,
    estimated_delivery_at,
    delivered_at,
    status
  from orders_source

)

select * from renamed_casted