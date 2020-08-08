- dashboard: testing_filters_dash
  title: Testing Filters Dash
  layout: newspaper
  filters:
  - name: Order Id Filter
    title: Order Id Filter
    type: number_filter
    default_value: ">900"
    allow_multiple_values: true
    required: false
  - name: Second Filter
    title: Second Filter
    type: number_filter
    default_value: ">0"
    allow_multiple_values: true
    required: false
  elements:
  - name: A basic Merge
    title: A basic Merge
    merged_queries:
    - sorts:
      - order_items.id desc
    - model: thelook
      explore: order_items
      type: table
      fields:
      - order_items.id
      - order_items.count
      sorts:
      - order_items.count desc
      limit: 500
      query_timezone: America/Los_Angeles
      rank: 0
    - model: thelook
      explore: order_items
      type: table
      fields:
      - order_items.id
      - order_items.total_sale_price
      limit: 500
      query_timezone: America/Los_Angeles
      rank: 1
      join_fields:
      - source_field_name: order_items.id
        field_name: order_items.id
    type: table
    listen:
    - Order Id Filter: order_items.id
      Second Filter: order_items.total_sale_price
    - Order Id Filter: order_items.id
      Second Filter: order_items.total_sale_price
    row: 0
    col: 0
    width: 15
    height: 6
