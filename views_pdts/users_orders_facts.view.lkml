view: users_orders_facts {
  derived_table: {
    sql: SELECT orders.user_id AS user_id
        , COUNT(*) AS lifetime_orders
        , MIN(NULLIF(orders.created_at,0)) AS first_order
        , MAX(NULLIF(orders.created_at,0)) AS latest_order
        , DATEDIFF(MAX(NULLIF(orders.created_at,0)),MIN(NULLIF(orders.created_at,0))) AS days_as_customer
        , DATEDIFF(CURDATE(),MAX(NULLIF(orders.created_at,0))) AS days_since_purchase
        , COUNT(DISTINCT CONCAT(MONTH(NULLIF(orders.created_at,0))),YEAR(NULLIF(orders.created_at,0))) AS number_of_distinct_months_with_orders
      FROM orders
      GROUP BY user_id
       ;;
    indexes: ["user_id"]
    persist_for: "12 hours"
  }

  #     sql_trigger_value: SELECT CURDATE()
  # DIMENSIONS #

  dimension: user_id {
    primary_key: yes
    hidden: yes
  }

  dimension: lifetime_orders {
    type: number
  }

  measure: average_ltv {
    type: average
    value_format_name: decimal_2
    drill_fields: [lifetime_orders, users.count]
    sql: ${lifetime_orders} ;;
  }

  dimension: lifetime_number_of_orders_tier {
    type: tier
    style: integer
    tiers: [
      0,
      1,
      2,
      3,
      5,
      10
    ]
    sql: ${lifetime_orders} ;;
  }

  # comment
  dimension: repeat_customer {
    type: yesno
    sql: ${lifetime_orders} > 1 ;;
  }

  dimension_group: first_order {
    type: time
    timeframes: [date, week, month]
    sql: ${TABLE}.first_order ;;
  }

  dimension_group: latest_order {
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}.latest_order ;;
  }

  dimension: days_as_customer {
    type: number
    value_format_name: decimal_0
  }

  dimension: days_as_customer_tiered {
    type: tier
    style: integer
    tiers: [0, 10, 50, 100, 500]
    sql: ${days_as_customer} ;;
  }

  dimension: days_since_purchase {
    type: number
    value_format_name: decimal_0
  }

  dimension: number_of_distinct_months_with_orders {
    type: number
    value_format_name: decimal_0
  }
}
