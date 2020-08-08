view: orders {
  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

#{
  parameter: date_granularity {
    type: string
    allowed_value: { value: "Day" }
    allowed_value: { value: "Month" }
    allowed_value: { value: "Quarter" }
    allowed_value: { value: "Year" }
  }

  dimension: date {
    label_from_parameter: date_granularity
    sql:
      CASE
        WHEN {% parameter date_granularity %} = 'Day' THEN
          ${created_date}
        WHEN {% parameter date_granularity %} = 'Month' THEN
          ${created_month}
        WHEN {% parameter date_granularity %} = 'Quarter' THEN
          ${created_quarter}
        WHEN {% parameter date_granularity %} = 'Year' THEN
          ${created_year}
        ELSE
          NULL
      END ;;
  }
#}

  parameter: metric_selector {
    type: string
    allowed_value: {
      label: "Total Order Profit"
      value: "total_order_profit"
    }
    allowed_value: {
      label: "First-Time Shopper Revenue"
      value: "total_first_purchase_revenue"
    }
    allowed_value: {
      label: "Returning Shopper Revenue"
      value: "total_returning_shopper_revenue"
    }
  }

  measure: metric {
    label_from_parameter: metric_selector
    type: number
    value_format: "$0.0,\"K\""
    sql:
      CASE
        WHEN {% parameter metric_selector %} = 'total_order_profit' THEN
          ${total_order_profit}
        WHEN {% parameter metric_selector %} = 'total_first_purchase_revenue' THEN
          ${total_first_purchase_revenue}
        WHEN {% parameter metric_selector %} = 'total_returning_shopper_revenue' THEN
          ${total_returning_shopper_revenue}
        ELSE
          NULL
      END ;;
  }

  dimension_group: since_user_created {
    type: duration
    intervals: [day, week, month]
    sql_start: ${users.created_raw};;
    sql_end: ${orders.created_raw};;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      month_num,
      quarter,
      year,
      day_of_week_index,
      hour_of_day,
      minute5,
      day_of_month
    ]
    sql: ${TABLE}.created_at ;;
    convert_tz: no
  }

  dimension_group: created_doy {
    type: time
    timeframes: [day_of_year]
    sql: ${TABLE}.created_at ;;
    convert_tz: no
    html: {{ created_month_num._rendered_value }}-{{ created_day_of_month._rendered_value }} ;;
  }

  measure: max_date {
    type: max
    sql: ${TABLE}.created_at ;;
  }

  measure: earliest_order_date {
    type: date
    sql: MIN(${TABLE}.created_at) ;;
  }

  measure: latest_order_date {
    type: date
    sql: MAX(${TABLE}.created_at) ;;
  }

  filter: time_period_filter {}
  filter: offset_days_filter {}

  dimension: time_period {
    type: number
    sql: {% parameter time_period_filter %} ;;
  }

  dimension: offset_days {
    type: number
    sql: {% parameter offset_days_filter %} ;;
  }

  dimension: status {
    label: "Status"
    sql: ${TABLE}.status ;;
  }

  measure: min_status {
    type: string
    sql: MIN(${status}) ;;
  }

  dimension: total_amount_of_order_usd {
    type: number
    value_format_name: decimal_2
    sql: (
      SELECT SUM(order_items.sale_price)
      FROM order_items
      WHERE order_items.order_id = orders.id
    ) ;;
  }

  dimension: total_amount_of_order_usd_tier {
    type: tier
    tiers: [0, 10, 50, 150, 500, 750, 1000, 2000, 3000]
    sql: ${total_amount_of_order_usd} ;;
  }

  dimension: order_items_list {
    sql: (
      SELECT GROUP_CONCAT(products.item_name)
      FROM order_items
      LEFT JOIN inventory_items ON order_items.inventory_item_id = inventory_items.id
      LEFT JOIN products ON inventory_items.product_id = products.id
      WHERE order_items.order_id = orders.id
    ) ;;
  }

  dimension: total_cost_of_order {
    type: number
    value_format_name: decimal_2
    sql: (
      SELECT SUM(inventory_items.cost)
      FROM order_items
      LEFT JOIN inventory_items ON order_items.inventory_item_id = inventory_items.id
      WHERE order_items.order_id = orders.id
    ) ;;
  }

  dimension: total_number_of_items {
    type: number
    value_format_name: decimal_0
    sql: (
      SELECT COUNT(order_items.id)
      FROM order_items
      WHERE order_items.order_id = orders.id) ;;
  }

  dimension: order_profit {
    type: number
    value_format_name: decimal_2
    sql: ${total_amount_of_order_usd} - ${total_cost_of_order} ;;
    html: ${{ rendered_value }} ;;
  }

  measure: profit_per_user {
    type: number
    value_format_name: decimal_2
    sql: 1.0 * ${order_profit}/NULLIF(${users.count},0) ;;
    html: ${{ rendered_value }} ;;
  }

  dimension: order_sequence_number {
    type: number
    sql: (
      SELECT COUNT(*)
      FROM orders o
      WHERE o.id < ${TABLE}.id
      AND o.user_id=${TABLE}.user_id
    ) + 1 ;;
  }

  dimension: is_first_purchase {
    type: yesno
    sql: ${order_sequence_number} = 1 ;;
  }

  dimension: rainier_dd1105 {
    type: yesno
    label: "For bug testing"
    sql: ${order_sequence_number} = 1;;
    html: <div style="font-size:xx-large;">{{rendered_value}}</div>;;
  }

  dimension: user_id {
    type: number
    hidden: yes
  }

  dimension: month_text {
    case: {
      when: {
        sql: ${created_month_num} = 9 ;;
        label: "September"
      }

      when: {
        sql: ${created_month_num} = 10 ;;
        label: "October"
      }

      when: {
        sql: ${created_month_num} = 11 ;;
        label: "November"
      }

      when: {
        sql: ${created_month_num} = 12 ;;
        label: "December"
      }

      else: ""
    }
  }

  dimension: user_order_month_normalized {
    type: number
    sql: 12 * (YEAR(${TABLE}.created_at) - YEAR(${users.created_date})) + MONTH(${TABLE}.created_at) - MONTH(${users.created_date}) ;;
  }

  dimension: is_same_dow_as_today {
    type: yesno
    sql: DAYOFWEEK(${TABLE}.created_at) = DAYOFWEEK(current_timestamp) ;;
  }

  dimension: months_since_user_created_sharp {
    type: number
    sql:
      YEAR(${created_date}) * 12
      + MONTH(${created_date})
      - YEAR(${users.created_date}) * 12
      - MONTH(${users.created_date}) ;;
  }

  dimension: months_since_users_first_order_sharp {
    type: number
    sql:
      YEAR(${created_date}) * 12
      + MONTH(${created_date})
      - YEAR(${users_orders_facts.first_order_date}) * 12
      - MONTH(${users_orders_facts.first_order_date}) ;;
  }

  dimension: months_since_users_first_order_smooth {
    type: number
    value_format_name: decimal_0
    sql: FLOOR(DATEDIFF(${created_date}, ${users_orders_facts.first_order_date})/30.416667) ;;
  }

  measure: sum_total_amount_of_order_usd {
    type: sum
    sql: ${total_amount_of_order_usd}*1000000000 ;;
    html: {{ rendered_value | replace: ".", "," }} ;;
    value_format: "###\ ###\ ###\ ###\ ###\ ###.00"
  }

  measure: sum_total_amount_of_order_usd_2 {
    type: sum
    sql: ${total_amount_of_order_usd}*1000 ;;
    value_format_name: usd
  }

  measure: average_total_amount_of_order_usd {
    type: average
    sql: ${total_amount_of_order_usd} ;;
    value_format_name: usd
  }

  measure: this_week_count {
    type: count_distinct
    sql: ${TABLE}.id ;;
    drill_fields: [detail*]

    filters: {
      field: created_date
      value: "7 days"
    }
  }

  measure: this_last_14_days_count {
    type: count_distinct
    sql: ${TABLE}.id ;;
    drill_fields: [detail*]

    filters: {
      field: created_date
      value: "14 days"
    }
  }

  measure: this_last_30_days_count {
    type: count_distinct
    sql: ${TABLE}.id ;;
    drill_fields: [detail*]

    filters: {
      field: created_date
      value: "30 days"
    }
  }

  measure: count {
    type: count_distinct
    sql: ${TABLE}.id ;;
  }

  measure: count_not_first {
    type: count_distinct
    sql: ${TABLE}.id ;;

    filters: {
      field: users.gender
      value: "m"
    }
  }

  measure: order_percent_change {
    type: percent_of_previous
    sql: ${count} ;;
  }

  measure: count_percent_of_total {
    label: "Count (Percent of Total)"
    type: percent_of_total
    drill_fields: [detail*]
    value_format_name: decimal_1
    sql: ${count} ;;
  }

  measure: total_first_purchase_revenue {
    type: sum
    sql: ${total_amount_of_order_usd} ;;
    value_format_name: decimal_2
    }

  measure: first_purchase_count {
    type: count
    drill_fields: [detail*]

    filters: {
      field: is_first_purchase
      value: "yes"
    }
  }

  measure: total_returning_shopper_revenue {
    type: sum
    value_format_name: decimal_2
    sql: ${total_amount_of_order_usd} ;;

    filters: {
      field: is_first_purchase
      value: "no"
    }
  }

  measure: total_order_profit {
    group_label: "Profit Stuff"
    type: sum
    sql: ${order_profit} ;;
    value_format_name: usd
  }

  measure: average_order_profit {
    group_label: "Profit Stuff"
    type: average
    sql: ${order_profit} ;;
    value_format: "$#.00"
  }

  parameter: row_limit {
    type: number
  }

  dimension: row_limiter {
    type: number
    sql: {% parameter row_limit %};;
  }

  set: detail {
    fields: [id, created_time, users.name, users.history, total_cost_of_order]
  }
}
