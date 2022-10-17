{{
  config(
    materialized='view'
  )
}}

with promos_source as (
  select * from {{ source('src_greenery', 'promos') }}
)

, renamed_casted as(
  select
    promo_id,
    discount,
    status
  from promos_source

)

select * from renamed_casted