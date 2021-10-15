explore: tables {}

view: tables {
  sql_table_name: information_schema.TABLES ;;

  dimension: auto_increment {
    type: number
    sql: ${TABLE}.AUTO_INCREMENT ;;
  }

  dimension: avg_row_length {
    type: number
    sql: ${TABLE}.AVG_ROW_LENGTH ;;
  }

  dimension_group: check {
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.CHECK_TIME ;;
  }

  dimension: checksum {
    type: number
    sql: ${TABLE}.CHECKSUM ;;
  }

  dimension: create_options {
    type: string
    sql: ${TABLE}.CREATE_OPTIONS ;;
  }

  dimension_group: create {
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.CREATE_TIME ;;
  }

  dimension: data_free {
    type: number
    sql: ${TABLE}.DATA_FREE ;;
  }

  dimension: data_length {
    type: number
    sql: ${TABLE}.DATA_LENGTH ;;
  }

  dimension: engine {
    type: string
    sql: ${TABLE}.ENGINE ;;
  }

  dimension: index_length {
    type: number
    sql: ${TABLE}.INDEX_LENGTH ;;
  }

  dimension: max_data_length {
    type: number
    sql: ${TABLE}.MAX_DATA_LENGTH ;;
  }

  dimension: row_format {
    type: string
    sql: ${TABLE}.ROW_FORMAT ;;
  }

  dimension: table_catalog {
    type: string
    sql: ${TABLE}.TABLE_CATALOG ;;
  }

  dimension: table_collation {
    type: string
    sql: ${TABLE}.TABLE_COLLATION ;;
  }

  dimension: table_comment {
    type: string
    sql: ${TABLE}.TABLE_COMMENT ;;
  }

  dimension: table_name {
    type: string
    sql: ${TABLE}.TABLE_NAME ;;
  }

  dimension: table_rows {
    type: number
    sql: ${TABLE}.TABLE_ROWS ;;
  }

  dimension: table_schema {
    type: string
    sql: ${TABLE}.TABLE_SCHEMA ;;
  }

  dimension: table_type {
    type: string
    sql: ${TABLE}.TABLE_TYPE ;;
  }

  dimension_group: update {
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.UPDATE_TIME ;;
  }

  dimension: version {
    type: number
    sql: ${TABLE}.VERSION ;;
  }

  measure: count {
    type: count
    drill_fields: [table_name]
  }
}
