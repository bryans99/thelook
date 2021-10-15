# This is an example of how to approach flexible cohort analysis in Looker.
# We aggregate transation facts by user-month and then also by cumulative
# user month, the result is a cohort analysis set to analyze in the Looker
# front-end, with the ability to slice and dice your users by any attribute

view: user_transactions_monthly {
  derived_table: {
    sql:
      SELECT users.user_id as user_id
        , month_list.month as month
        , COALESCE(monthly_transactions, 0) as monthly_transactions
        , COALESCE(monthly_revenue, 0) as monthly_revenue
        , COUNT(users.user_id) as monthly_user_count
      FROM (SELECT users.id as user_id, users.created_at as created_at FROM users) users
      LEFT JOIN (SELECT CONCAT(years.year, '-', months.month) as month
                FROM
                  (SELECT '2014' as year union SELECT '2015' union SELECT '2016' union SELECT '2017') years,
                  (SELECT '01' as month union SELECT '02' union SELECT '03' union SELECT '04'
                    union SELECT '05' union SELECT '06' union SELECT '07' union SELECT '08'
                    union SELECT '09' union SELECT '10' union SELECT '11' union SELECT '12') months
                ORDER BY 1) month_list
      ON LAST_DAY(STR_TO_DATE(CONCAT(month_list.month, "-1"), "%Y-%m-%d")) > users.created_at
      AND LAST_DAY(STR_TO_DATE(CONCAT(month_list.month, "-1"), "%Y-%m-%d")) < NOW()
      LEFT JOIN (SELECT
                  o.user_id as user_id
                  , DATE_FORMAT(o.created_at, "%Y-%m") as trans_month
                  , COUNT(distinct o.id) AS monthly_transactions
                  , SUM(oi.sale_price) as monthly_revenue
                FROM order_items oi
                LEFT JOIN orders o ON oi.order_id = o.id
                GROUP BY 1,2) as data
          ON data.trans_month = month_list.month AND data.user_id = users.user_id
      GROUP BY 1,2;;
    indexes: ["user_id", "month"]
    sql_trigger_value: SELECT CURRENT_DATE() ;;
  }

  parameter: cohort_timeframe_picker {
    tags: ["cohort__cohort_timeframe_picker"]
    allowed_value: { label: "Month"       value: "month" }
    allowed_value: { label: "Quarter"     value: "quarter" }
  }

  dimension: cohort_timeframe_value {
    type: string
    hidden: yes
    sql: {% parameter cohort_timeframe_picker %}
      ;;
  }

  parameter: cohort_action_picker {
    tags: ["cohort__cohort_action_picker"]
    allowed_value: { label: "Created Date"        value: "created" }
    allowed_value: { label: "First Order Date"    value: "first_order" }
  }

  dimension: cohort_action_value {
    type: string
    hidden: yes
    sql: {% parameter cohort_action_picker %}
      ;;
  }

  parameter: measure_picker {
    tags: ["cohort__measure_picker"]
    allowed_value: { label: "Revenue"                 value: "revenue" }
    allowed_value: { label: "Transactions"            value: "transactions" }
    allowed_value: { label: "Active Users"            value: "users" }
  }

  dimension: measure_value {
    type: string
    hidden: yes
    sql: {% parameter measure_picker %} ;;
  }

  parameter: measure_aggregation_picker {
    tags: ["cohort__measure_aggregation_picker"]
    allowed_value: { label: "Total"                       value: "non_cumulative_sum" }
    allowed_value: { label: "Cumulative Total"            value: "cumulative_sum" }
    allowed_value: { label: "Average Per User"            value: "non_cumulative_average" }
    allowed_value: { label: "Cumulative Total Per User"   value: "cumulative_average" }
  }

  dimension: measure_aggregation_value {
    type: string
    hidden: yes
    sql: {% parameter measure_aggregation_picker %}
      ;;
  }

  dimension: cohort_timeframe {
    tags: ["cohort__cohort_timeframe"]
    sql:
          {% assign dim1 = cohort_timeframe_value._sql %}
          {% assign dim2 = cohort_action_value._sql %}
          {% if dim1 contains 'month' %}
              {% if dim2 contains 'created' %}
                CONCAT
                  (EXTRACT(year from users_cohorts.created_at),"-",
                   LPAD(EXTRACT(month from users_cohorts.created_at),2,0))
              {% elsif dim2 contains 'first_order' %}
                CONCAT
                  (EXTRACT(year from users_orders_facts.first_order),"-",
                   LPAD(EXTRACT(month from users_orders_facts.first_order),2,0))
              {% else %} month fail
              {% endif %}
          {% elsif dim1 contains 'quarter' %}
              {% if dim2 contains 'created' %}
                CONCAT
                  (EXTRACT(year from users_cohorts.created_at),"-",
                   LPAD(EXTRACT(quarter from users_cohorts.created_at)*3,2,0))
              {% elsif dim2 contains 'first_order' %}
                CONCAT
                  (EXTRACT(year from users_orders_facts.first_order),"-",
                   LPAD(EXTRACT(quarter from users_orders_facts.first_order)*3,2,0))
              {% else %} quarter fail
              {% endif %}
          {% else %} NULL
          {% endif %};;
  }

  dimension: cohort_pivot_timeframe {
    tags: ["cohort__cohort_pivot_timeframe"]

    sql:
          {% assign dim1 = cohort_timeframe_value._sql %}
          {% assign dim2 = cohort_action_value._sql %}
          {% if dim1 contains 'month' %}
              {% if dim2 contains 'created' %}
                LPAD(YEAR(STR_TO_DATE(CONCAT(user_transactions_monthly.month, "-01"), "%Y-%m-%d"))*12
                + MONTH(STR_TO_DATE(CONCAT(user_transactions_monthly.month, "-01"), "%Y-%m-%d"))
                - YEAR(users_cohorts.created_at)*12
                - MONTH(users_cohorts.created_at),2,0)
              {% elsif dim2 contains 'first_order' %}
                LPAD(YEAR(STR_TO_DATE(CONCAT(user_transactions_monthly.month, "-01"), "%Y-%m-%d"))*12
                + MONTH(STR_TO_DATE(CONCAT(user_transactions_monthly.month, "-01"), "%Y-%m-%d"))
                - YEAR(users_orders_facts.first_order)*12
                - MONTH(users_orders_facts.first_order),2,0)
              {% else %} month fail
              {% endif %}
          {% elsif dim1 contains 'quarter' %}
              {% if dim2 contains 'created' %}
                LPAD(FLOOR(
                (YEAR(STR_TO_DATE(CONCAT(user_transactions_monthly.month, "-01"), "%Y-%m-%d"))*12
                + MONTH(STR_TO_DATE(CONCAT(user_transactions_monthly.month, "-01"), "%Y-%m-%d"))
                - YEAR(users_cohorts.created_at)*12
                - MONTH(users_cohorts.created_at)
                )/3)*3,2,0)
              {% elsif dim2 contains 'first_order' %}
                LPAD(FLOOR(
                (YEAR(STR_TO_DATE(CONCAT(user_transactions_monthly.month, "-01"), "%Y-%m-%d"))*12
                + MONTH(STR_TO_DATE(CONCAT(user_transactions_monthly.month, "-01"), "%Y-%m-%d"))
                - YEAR(users_orders_facts.first_order)*12
                - MONTH(users_orders_facts.first_order)
                )/3)*3,2,0)
              {% else %} quarter fail
              {% endif %}
          {% else %} NULL
          {% endif %};;
  }

  measure: measure {
    type: number
    value_format_name: decimal_2
    sql:
      {% assign selected1 = measure_value._sql %}
      {% assign selected2 = measure_aggregation_value._sql %}
      {% if selected1 contains 'revenue' %}
          {% if selected2 contains 'non_cumulative_sum' %}
            SUM(user_transactions_monthly.monthly_revenue)
          {% elsif selected2 contains 'cumulative_sum' %}
            SUM(user_transactions_monthly_cumulative.cumulative_monthly_revenue)
          {% elsif selected2 contains 'non_cumulative_average' %}
            SUM(user_transactions_monthly.monthly_revenue)
            / COUNT(user_transactions_monthly.user_id)
          {% elsif selected2 contains 'cumulative_average' %}
            SUM(user_transactions_monthly_cumulative.cumulative_monthly_revenue)
            / COUNT(user_transactions_monthly.user_id)
          {% else %} revenue fail
          {% endif %}
      {% elsif selected1 contains 'transactions' %}
          {% if selected2 contains 'non_cumulative_sum' %}
            SUM(user_transactions_monthly.monthly_transactions)
          {% elsif selected2 contains 'cumulative_sum' %}
            SUM(user_transactions_monthly_cumulative.cumulative_monthly_transactions)
          {% elsif selected2 contains 'non_cumulative_average' %}
            SUM(user_transactions_monthly.monthly_transactions)
            / COUNT(user_transactions_monthly.user_id)
          {% elsif selected2 contains 'cumulative_average' %}
            SUM(user_transactions_monthly_cumulative.cumulative_monthly_transactions)
            / COUNT(user_transactions_monthly.user_id)
          {% else %} transactions fail
          {% endif %}
      {% elsif selected1 contains 'users' %}
          {% if selected2 contains 'non_cumulative_sum' %}
            COUNT(user_transactions_monthly.user_id)
          {% elsif selected2 contains 'cumulative_sum' %}
            COUNT(user_transactions_monthly.user_id)
          {% elsif selected2 contains 'non_cumulative_average' %}
            SUM(CASE WHEN user_transactions_monthly.monthly_transactions > 1 THEN 1 ELSE 0 END)
            / COUNT(user_transactions_monthly.user_id)
          {% elsif selected2 contains 'cumulative_average' %}
            SUM(CASE WHEN user_transactions_monthly_cumulative.cumulative_monthly_transactions > 1 THEN 1 ELSE 0 END)
            / COUNT(user_transactions_monthly.user_id)
          {% else %} users fail
          {% endif %}
      {% else %} NULL
      {% endif %};;
  }

  dimension: user_id {
    type: number
    value_format_name: id
    primary_key: yes
    sql: ${TABLE}.user_id ;;
  }

  dimension_group: transaction {
    type: time
    timeframes: [month]
    sql: STR_TO_DATE(CONCAT(${TABLE}.month, "-01"), "%Y-%m-%d") ;;
    convert_tz: no
  }

  dimension: months_since_user_created {
    type: number
    sql: YEAR(STR_TO_DATE(CONCAT(${TABLE}.month, "-01"), "%Y-%m-%d"))*12
        + MONTH(STR_TO_DATE(CONCAT(${TABLE}.month, "-01"), "%Y-%m-%d"))
      - YEAR(${users_cohorts.created_date})*12
        - MONTH(${users_cohorts.created_date})
       ;;
  }

  dimension: monthly_transactions {
    type: number
    sql: ${TABLE}.monthly_transactions ;;
  }

  dimension: monthly_revenue {
    type: number
    sql: ${TABLE}.monthly_revenue ;;
    value_format_name: usd_0
  }

  measure: sum_monthly_transactions {
    type: sum
    sql: ${monthly_transactions} ;;
  }

  measure: sum_monthly_revenue {
    type: sum
    sql: ${monthly_revenue} ;;
    value_format_name: usd_0
  }

  measure: retained_users {
    type: number
    sql: ${sum_monthly_revenue}^3/25000^3 ;;
    value_format_name: percent_2
  }

  measure: average_monthly_transactions {
    type: average
    sql: ${monthly_transactions} ;;
  }

  measure: average_monthly_revenue {
    type: average
    sql: ${monthly_revenue} ;;
    value_format_name: usd_0
  }

  measure: user_count {
    type: count
  }

  measure: active_user_count {
    type: count

    filters: {
      field: monthly_transactions
      value: "> 0"
    }
  }

  measure: active_user_percentage {
    type: number
    sql: ${active_user_count} / ${user_count} * 2 ;;
    value_format_name: percent_1
    html: {% if value > 0.9 %}
        <p style="color: white; background-color: #287a1f; font-size:100%; text-align:center">{{ rendered_value }}</p>
      {% elsif value > 0.7 %}
        <p style="color: white; background-color: #42964d; font-size:100%; text-align:center">{{ rendered_value }}</p>
      {% elsif value > 0.6 %}
        <p style="color: white; background-color: #55a372; font-size:100%; text-align:center">{{ rendered_value }}</p>
      {% elsif value > 0.5 %}
        <p style="color: white; background-color: #499ba6; font-size:100%; text-align:center">{{ rendered_value }}</p>
      {% elsif value > 0.45 %}
        <p style="color: white; background-color: #3D6D9E; font-size:100%; text-align:center">{{ rendered_value }}</p>
      {% elsif value > 0.4 %}
        <p style="color: white; background-color: #4D6C97; font-size:100%; text-align:center">{{ rendered_value }}</p>
      {% elsif value > 0.35 %}
        <p style="color: white; background-color: #5D6B91; font-size:100%; text-align:center">{{ rendered_value }}</p>
      {% elsif value > 0.3 %}
        <p style="color: white; background-color: #6E6A8A; font-size:100%; text-align:center">{{ rendered_value }}</p>
      {% elsif value > 0.25 %}
        <p style="color: white; background-color: #7E6984; font-size:100%; text-align:center">{{ rendered_value }}</p>
      {% elsif value > 0.2 %}
        <p style="color: white; background-color: #8E687E; font-size:100%; text-align:center">{{ rendered_value }}</p>
      {% elsif value > 0.15 %}
        <p style="color: white; background-color: #AF6671; font-size:100%; text-align:center">{{ rendered_value }}</p>
      {% elsif value > 0.1 %}
        <p style="color: white; background-color: #D06464; font-size:100%; text-align:center">{{ rendered_value }}</p>
      {% elsif value > 0.05 %}
        <p style="color: white; background-color: #E0635E; font-size:100%; text-align:center">{{ rendered_value }}</p>
      {% elsif value > 0.0 %}
        <p style="color: white; background-color: #F16358; font-size:100%; text-align:center">{{ rendered_value }}</p>
      {% endif %}
      ;;
  }

}

#####################################################################################

view: user_transactions_monthly_cumulative {
  derived_table: {
    sql: SELECT
        utm1.user_id as user_id
        , utm1.month as month
        , SUM(COALESCE(utm2.monthly_transactions,0)) AS cumulative_monthly_transactions
        , SUM(COALESCE(utm2.monthly_revenue,0)) as cumulative_monthly_revenue
      FROM ${user_transactions_monthly.SQL_TABLE_NAME} as utm1
      LEFT JOIN ${user_transactions_monthly.SQL_TABLE_NAME} as utm2
      ON STR_TO_DATE(CONCAT(utm2.month, "-01"), "%Y-%m-%d")
            <= STR_TO_DATE(CONCAT(utm1.month, "-01"), "%Y-%m-%d")
            AND utm1.user_id = utm2.user_id
      GROUP BY 1,2
      ORDER BY 1,2
       ;;
    indexes: ["user_id"]
    sql_trigger_value: SELECT CURRENT_DATE() ;;
  }

  dimension: user_id {
    type: number
    primary_key: yes
    sql: ${TABLE}.user_id ;;
  }

  dimension_group: transaction {
    type: time
    timeframes: [month]
    sql: STR_TO_DATE(CONCAT(${TABLE}.month, "-01"), "%Y-%m-%d") ;;
    convert_tz: no
  }

  dimension: months_since_user_created {
    type: number
    sql: YEAR(STR_TO_DATE(CONCAT(${TABLE}.month, "-01"), "%Y-%m-%d"))*12
        + MONTH(STR_TO_DATE(CONCAT(${TABLE}.month, "-01"), "%Y-%m-%d"))
      - YEAR(${users_cohorts.created_date})*12
        - MONTH(${users_cohorts.created_date})
       ;;
  }

  dimension: cumulative_monthly_transactions {
    type: number
    sql: ${TABLE}.cumulative_monthly_transactions ;;
  }

  dimension: cumulative_monthly_revenue {
    type: number
    sql: ${TABLE}.cumulative_monthly_revenue ;;
  }

  measure: sum_cumulative_monthly_transactions {
    type: sum
    sql: ${cumulative_monthly_transactions} ;;
  }

  measure: sum_cumulative_monthly_revenue {
    type: sum
    sql: ${cumulative_monthly_revenue} ;;
    value_format_name: usd_0
  }

  measure: average_cumulative_monthly_transactions {
    type: average
    value_format_name: decimal_2
    sql: ${cumulative_monthly_transactions} ;;
  }

  measure: average_cumulative_monthly_revenue {
    type: average
    value_format_name: usd_0
    sql: ${cumulative_monthly_revenue} ;;
  }
}
