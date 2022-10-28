WITH

events AS (
    SELECT * FROM {{ ref('stg_greenery__events') }}
)

, order_items AS (
    SELECT * FROM {{ ref('stg_greenery__order_items') }}
)

, event_order_items AS (
    select 
        events.session_id
        , events.event_type
        , events.order_id
        , coalesce(events.product_id, order_items.product_id) AS product_id
    from  events
    left join order_items ON events.order_id = order_items.order_id
)

, final AS (
    {%- set product_events = ['page_view', 'add_to_cart', 'checkout']%}
    select
        product_id
        {% for product_event in product_events -%}
        , count(DISTINCT (CASE WHEN event_type = '{{product_event}}' THEN session_id END)) AS total_{{product_event}}
        {% endfor -%}
    from event_order_items
    group by 1
)

select * from final