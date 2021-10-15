explore: example {}

view: example {
  # Or, you could make this view a derived table, like this:
  derived_table: {
    sql: SELECT null as field_one, null as field_two
      UNION ALL
      SELECT 1 as field_one, 'test' as field_two
       ;;
  }

  #     Define your dimensions and measures here, like this:
  dimension: field_one {
    type: number
    sql: ${TABLE}.field_one ;;
  }

  dimension: field_two {
    type: number
    sql: ${TABLE}.field_two ;;
  }

  measure: total_lifetime_orders {
    type: count
  }
}
