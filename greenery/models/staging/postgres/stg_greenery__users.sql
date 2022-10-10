{{
  config(
    materialized='view'
  )
}}

with users_source as (
  select * from {{ source('src_greenery', 'users') }}
)

, renamed_casted as(
  select
    user_id,
    first_name,
    last_name,
    email,
    phone_number,
    created_at as user_created_at,
    updated_at as user_updated_at,
    address_id
  from users_source

)

select * from renamed_casted