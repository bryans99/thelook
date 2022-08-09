view: users_first_order_facts_daily {
  derived_table: {
    sql: SELECT first_order_date, COUNT(*) as first_orders_count
      FROM
        (
        SELECT orders.user_id AS user_id
          , DATE_FORMAT(MIN(NULLIF(orders.created_at,0)), '%Y-%m-%d') AS first_order_date
        FROM orders
        GROUP BY user_id
        ) first_orders
      GROUP BY first_order_date
       ;;
  }

  dimension: first_order_date {
    sql: ${TABLE}.first_order_date ;;
  }

  dimension: first_orders_count_daily {
    type: number
    sql: ${TABLE}.first_orders_count ;;
  }
}

view: users_first_order_facts_weekly {
  derived_table: {
    sql: SELECT first_order_week, COUNT(*) as first_orders_count
      FROM
        (
        SELECT orders.user_id AS user_id
          , DATE_FORMAT(DATE_ADD(MIN(NULLIF(orders.created_at,0)), '%Y-%m-%d'), INTERVAL(1-DAYOFWEEK(mydate)) DAY)) AS first_order_week
        FROM orders
        GROUP BY user_id
        ) first_orders
      GROUP BY first_order_week
       ;;
  }

  dimension: first_order_week {
    sql: ${TABLE}.first_order_week ;;
  }

  dimension: first_orders_count_weekly {
    type: number
    sql: ${TABLE}.first_orders_count ;;
  }
}

view: users_first_order_facts_monthly {
  derived_table: {
    sql: SELECT first_order_month, COUNT(*) as first_orders_count
      FROM
        (
        SELECT orders.user_id AS user_id
          , DATE_FORMAT(MIN(NULLIF(orders.created_at,0)), '%Y-%m') AS first_order_month
        FROM orders
        GROUP BY user_id
        ) first_orders
      GROUP BY first_order_month
       ;;
  }

  dimension: first_order_month {
    sql: ${TABLE}.first_order_month ;;
  }

  dimension: first_orders_count_monthly {
    type: number
    sql: ${TABLE}.first_orders_count ;;
  }
}
