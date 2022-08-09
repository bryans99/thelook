view: schema_migrations {
  dimension: filename {
    sql: ${TABLE}.filename ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Detail ------
  set: detail {
    fields: [filename]
  }
}
