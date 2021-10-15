explore: dynamic_table {}

view: dynamic_table {
  sql_table_name: {% assign from_table = table_picker_value._sql | strip %}
    {% if from_table contains 'users' %} users
    {% elsif from_table contains 'orders' %} orders
    {% elsif from_table contains 'products' %} products
    {% else %} NULL
    {% endif %}
     ;;

    filter: table_picker {
      suggestions: ["users", "orders", "products"]
    }

    dimension: table_picker_value {
      type: string
      hidden: yes
      sql: {% parameter table_picker %}
        ;;
    }

    dimension_group: created_at {
      type: time
      timeframes: [date]
      sql: ${TABLE}.created_at ;;
    }

    dimension: id {
      type: number
      sql: ${TABLE}.id ;;
    }

    measure: count {
      sql: COUNT(${id}) ;;
    }
  }
