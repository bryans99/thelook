explore: order_items_rollup {}

view: order_items_rollup {
  derived_table: {
    sql: SELECT
        orders.status as status
        , COUNT(*) as counter
      FROM orders
      GROUP BY 1
       ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: counter {
    type: number
    sql: ${TABLE}.counter ;;
  }

  measure: total_counter {
    type: sum
    sql: ${counter} ;;
  }
}
