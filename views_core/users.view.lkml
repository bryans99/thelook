view: users {
  sql_table_name: users ;;
  # DIMENSIONS #

  dimension: id {
    type: number
    primary_key: yes
    sql: ${TABLE}.id ;;
    tags: ["user_id", "braze_id", "external_id"]

    link: {
      label: "View Order History"
      url: "/explore/thelook/orders?fields=orders.detail*&f[users.id]={{ value }}"
    }

    link: {
      label: "View Item History"
      url: "/explore/thelook/order_items?fields=order_items.detail*&f[users.id]={{ value }}"
    }
  }

  parameter: test_parameter {
    allowed_value: {
      label: "wow_the_new_IDE"
      value: "holy_moly"
    }
  }

  dimension: age {
    type: number
  }

  measure: average_age {
    type: average
    value_format_name: decimal_2
    sql: ${age} ;;
  }

  dimension: age_tier {
    type: tier
    style: integer
    sql: ${age} ;;
    tiers: [
      0,
      10,
      20,
      30,
      40,
      50,
      60,
      70,
      80
    ]
  }

  dimension: city {
    drill_fields: [zipcode]
  }

  dimension: state {
    drill_fields: [city, zipcode]
  }

  dimension: country {
    drill_fields: [state, city, zipcode]
  }

  dimension: zipcode {
    type: zipcode
    sql: ${TABLE}.zip ;;
    alias: [zip]
    drill_fields: [gender, age_tier]
  }

  #   - dimension: country_first_letter
  #     type: string
  #     expression: substring(${country},0,1)

  dimension_group: created {
    type: time
    timeframes: [time, date, week, month, year, raw]
    sql: ${TABLE}.created_at ;;
  }

  dimension: email {
    link: {
      url: "/dashboards/thelook/4_user_lookup?email={{ value | encode_uri }}"
      label: "User Lookup for {{ value }}"
    }
    tags: ["email", "braze_id"]
  }

  dimension: phone {
    sql: CONCAT("165086", ${id})   ;;
    tags: ["phone"]
  }

  dimension: email_500 {
    sql: ${email} ;;
    suggest_dimension: email_500_suggest
  }

  dimension: email_500_suggest {
    sql: CASE
        WHEN ${email} like 'd%' THEN ${email}
        ELSE NULL
      END
       ;;
  }

  dimension: email_1000 {
    sql: ${email} ;;
    suggest_dimension: email_1000_suggest
  }

  dimension: email_1000_suggest {
    sql: CASE
        WHEN ${email} like 'z%' THEN ${email}
        WHEN ${email} like 'y%' THEN ${email}
        WHEN ${email} like 'w%' THEN ${email}
        WHEN ${email} like 'v%' THEN ${email}
        ELSE NULL
      END
       ;;
  }

  dimension: gender {}

  dimension: gender_normalized {
    sql: CASE
        WHEN ${gender} like 'mail%' THEN 'm'
        ELSE ${gender}
      END
       ;;
  }

  dimension: name {
    sql: CONCAT(${TABLE}.first_name,' ', ${TABLE}.last_name) ;;
    }

  filter: dimension_picker {
    suggestions: ["gender", "age"]
  }

  dimension: dimension_value {
    type: string
    hidden: yes
    sql: {% parameter dimension_picker %}
      ;;
  }

  dimension: dimension {
    sql:
          {% assign dim = dimension_value._sql %}
          {% if dim contains 'gender' %} users.gender
          {% elsif dim contains 'age' %} users.age
          {% else %} NULL
          {% endif %};;
  }

  filter: measure_picker {
    suggestions: ["id", "age"]
  }

  filter: aggregation_picker {
    suggestions: ["count", "sum", "average", "min", "max"]
  }

  dimension: measure_value {
    type: string
    hidden: yes
    sql: {% parameter measure_picker %}
      ;;
  }

  dimension: aggregation_value {
    type: string
    hidden: yes
    sql: {% parameter aggregation_picker %}
      ;;
  }

  measure: measure {
    type:  number
    sql:
          {% assign agg = aggregation_value._sql %}
          {% if agg contains 'count' %} count(
          {% elsif agg contains 'sum' %} sum(
          {% elsif agg contains 'average' %} average(
          {% elsif agg contains 'min' %} min(
          {% elsif agg contains 'max' %} max(
          {% else %} NULL
          {% endif %}
          {% assign mea = measure_value._sql %}
          {% if mea contains 'id' %} users.id)
          {% elsif mea contains 'age' %} users.age)
          {% else %} NULL
          {% endif %};;
    }

  # MEASURES #

  measure: count {
    type: count_distinct
    sql: COALESCE(${id}, 0) ;;
    drill_fields: [detail*]
  }

  measure: count_percent_of_total {
    label: "Count (Percent of Total)"
    type: percent_of_total
    drill_fields: [detail*]
    value_format_name: decimal_1
    sql: ${count} ;;
  }

  # SETS #

  set: detail {
    fields: [
      id,
      name,
      email,
      city,
      state,
      country,
      zipcode,
      gender,
      age,

      #         # Counters for views that join 'users'
      orders.count,
      order_items.count
    ]
  }
}
