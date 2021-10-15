view: test_data {
  # Or, you could make this view a derived table, like this:
  derived_table: {
    sql: SELECT 'average_total_amount_of_order_usd' as field, 104.364320015179 as value UNION ALL
      SELECT 'count', 10537 UNION ALL
      SELECT 'first_purchase_count', 3931 UNION ALL
      SELECT 'profit_per_user', 0.0059440414507772 UNION ALL
      SELECT 'sum_total_amount_of_order_usd', 1099686.83999995 UNION ALL
      SELECT 'total_first_purchase_revenue', 413706.529999996 UNION ALL
      SELECT 'total_returning_shopper_revenue', 685980.309999983
       ;;
  }

  #     Define your dimensions and measures here, like this:
  dimension: field {
    type: string
    sql: ${TABLE}.field ;;
  }

  dimension: value {
    type: number
    sql: ${TABLE}.value ;;
  }
}
