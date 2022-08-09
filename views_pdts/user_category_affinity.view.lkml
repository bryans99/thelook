explore: user_category_affinity {}

view: user_category {
  derived_table: {
    persist_for: "24 hours"
    indexes: ["user_id"]
    sql: SELECT
        o.user_id as user_id
        , p.category as category
      FROM order_items oi
      JOIN orders o ON o.id = oi.order_id
      JOIN inventory_items ii ON oi.inventory_item_id = ii.id
      JOIN products p ON ii.product_id = p.id
      GROUP BY user_id, category
       ;;
  }
}

view: total_user_category {
  derived_table: {
    persist_for: "24 hours"
    indexes: ["category"]
    sql: SELECT
        p.category as category
        , count(distinct o.user_id) as category_frequency
      FROM order_items oi
      JOIN orders o ON o.id = oi.order_id
      JOIN inventory_items ii ON oi.inventory_item_id = ii.id
      JOIN products p ON ii.product_id = p.id
      GROUP BY p.category
       ;;
  }
}

view: user_category_affinity {
  derived_table: {
    persist_for: "24 hours"
    indexes: ["category_a"]
    sql: SELECT
        category_a
        , category_b
        , joint_frequency
        , tuc1.category_frequency as category_a_frequency
        , tuc2.category_frequency as category_b_frequency
      FROM (
        SELECT uc1.category as category_a
        , uc2.category as category_b
        , count(*) as joint_frequency
        FROM ${user_category.SQL_TABLE_NAME} as uc1
        JOIN ${user_category.SQL_TABLE_NAME} uc2 ON uc1.user_id = uc2.user_id AND uc1.category <> uc2.category
        GROUP BY category_a, category_b
      ) as prop
      JOIN ${total_user_category.SQL_TABLE_NAME} as tuc1 ON prop.category_a = tuc1.category
      JOIN ${total_user_category.SQL_TABLE_NAME} as tuc2 ON prop.category_b = tuc2.category
      ORDER BY category_a, joint_frequency DESC, category_b
       ;;
  }

  dimension: category_a {
    sql: ${TABLE}.category_a ;;
  }

  dimension: category_b {
    sql: ${TABLE}.category_b ;;
  }

  dimension: joint_frequency {
    type: number
    sql: ${TABLE}.joint_frequency ;;
  }

  dimension: category_a_frequency {
    type: number
    sql: ${TABLE}.category_a_frequency ;;
  }

  dimension: category_b_frequency {
    type: number
    sql: ${TABLE}.category_b_frequency ;;
  }

  measure: category_affinity {
    type: number
    value_format_name: decimal_1
    sql: ${joint_frequency}/(${category_a_frequency}+${category_b_frequency}-${joint_frequency})*100 ;;
  }
}
