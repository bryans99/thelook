view: order_items {
  # DIMENSIONS #

  dimension: id {
    type: number
    primary_key: yes
    sql: ${TABLE}.id ;;
  }

  dimension: inventory_item_id {
    type: number
    sql: ${TABLE}.inventory_item_id ;;
    hidden: yes
  }

  dimension: return_date {
    type: date
    sql: ${TABLE}.returned_at ;;
  }

  dimension: returned {
    type: yesno
    sql: ${TABLE}.returned_at IS NOT NULL ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
    hidden: yes
  }

  dimension: sale_price {
    description: "The sale price reflects the price that the item was sold at."
    type: number
    value_format_name: decimal_2
    sql: ${TABLE}.sale_price ;;
  }

  dimension: sale_price_eu {
    description: "The sale price reflects the price that the item was sold at."
    type: number
    value_format_name: eur
    sql: ${TABLE}.sale_price/1.2 ;;
  }

  dimension: sale_price_jp {
    description: "The sale price reflects the price that the item was sold at."
    type: number
    value_format: "\"¥\"0.00"
    sql: ${TABLE}.sale_price*100 ;;
  }

  dimension: sale_price_cn {
    description: "The sale price reflects the price that the item was sold at."
    type: number
#     value_format: "CNY0.00"
    sql: ${TABLE}.sale_price*6 ;;
  }

  dimension: percent_of_total_sale_price {
    type: number
    value_format_name: percent_1
    sql: ${sale_price} / ${orders.total_amount_of_order_usd} ;;
  }

  dimension: gross_margin {
    type: number
    value_format_name: decimal_2
    sql: ${sale_price} - ${inventory_items.cost} ;;
  }

  dimension: item_gross_margin_percentage {
    type: number
    sql: 100.0 * ${gross_margin}/NULLIF(${sale_price}, 0) ;;
  }

  dimension: item_gross_margin_percentage_tier {
    type: tier
    tiers: [0, 10, 20, 30, 40, 50, 60, 70, 80, 90]
    sql: ${item_gross_margin_percentage} ;;
  }

  # MEASURES #

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_gross_margin {
    type: sum
    sql: ${gross_margin} ;;
    value_format: "$#,##0.00"
  }

  measure: total_sale_price {
    type: sum
    sql: ${sale_price} ;;
    value_format: "$#,##0.00"
  }

  measure: average_sale_price {
    type: average
    sql: ${sale_price} ;;
    value_format: "$#,##0.00"
  }

  measure: average_gross_margin {
    type: average
    sql: ${gross_margin} ;;
    value_format_name: decimal_2
  }

  measure: median_sale_price {
    type: median
    sql: ${sale_price} ;;
    value_format: "$#,##0.00"
  }

  measure: median_gross_margin {
    type: median
    sql: ${gross_margin} ;;
    value_format_name: decimal_2
  }

  measure: 5th_percentile_sale_price {
    type: percentile
    percentile: 5
    sql: ${sale_price} ;;
    value_format: "$#,##0.00"
  }

  measure: 5th_percentile_gross_margin {
    type: percentile
    percentile: 5
    sql: ${gross_margin} ;;
    value_format_name: decimal_2
  }

  measure: 25th_percentile_sale_price {
    type: percentile
    percentile: 25
    sql: ${sale_price} ;;
    value_format: "$#,##0.00"
  }

  measure: 25th_percentile_gross_margin {
    type: percentile
    percentile: 25
    sql: ${gross_margin} ;;
    value_format_name: decimal_2
  }

  measure: 75th_percentile_sale_price {
    type: percentile
    percentile: 75
    sql: ${sale_price} ;;
    value_format: "$#,##0.00"
  }

  measure: 75th_percentile_gross_margin {
    type: percentile
    percentile: 75
    sql: ${gross_margin} ;;
    value_format_name: decimal_2
  }

  measure: 95th_percentile_sale_price {
    type: percentile
    percentile: 95
    sql: ${sale_price} ;;
    value_format: "$#,##0.00"
  }

  measure: 95th_percentile_gross_margin {
    type: percentile
    percentile: 95
    sql: ${gross_margin} ;;
    value_format_name: decimal_2
  }


  #   - measure: total_sale_price_per_first_order_user_daily
  #     type: sum
  #     sql: ${sale_price} / ${users_first_order_facts_daily.first_orders_count_daily}
  #     value_format_name: decimal_2
  #     html: |
  #       ${{ rendered_value }}
  #
  #   - measure: total_sale_price_per_first_order_user_weekly
  #     type: sum
  #     sql: ${sale_price} / ${users_first_order_facts_weekly.first_orders_count_weekly}
  #     value_format_name: decimal_2
  #     html: |
  #       ${{ rendered_value }}
  #
  #   - measure: total_sale_price_per_first_order_user_monthly
  #     type: sum
  #     sql: ${sale_price} / ${users_first_order_facts_monthly.first_orders_count_monthly}
  #     value_format_name: decimal_2
  #     html: |
  #       ${{ rendered_value }}

  #   - measure: gross_margin_percentage
  #     type: number
  #     sql: 100.0 * ${total_gross_margin}/${total_sale_price}    # postgres does integer division by default, so multiply by 100.0
  #     value_format_name: decimal_2                                               #  to force real numbers.


  # SETS #

  set: detail {
    fields: [
      orders.created_date,
      id,
      orders.id,
      users.name,
      users.history,
      products.item_name,
      brand.name,
      category.name,
      department.name,
      total_sale_price
    ]
  }
}
