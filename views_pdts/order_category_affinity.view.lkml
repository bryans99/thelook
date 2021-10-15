explore: order_category_affinity {}

view: order_category {
  derived_table: {
    persist_for: "24 hours"
    indexes: ["order_id"]
    sql: SELECT o.id as order_id
      , oi.inventory_item_id as inventory_item_id
      , p.category as category
      FROM order_items oi
      JOIN orders o ON o.id = oi.order_id
      JOIN inventory_items ii ON oi.inventory_item_id = ii.id
      JOIN products p ON ii.product_id = p.id
      GROUP BY order_id, category
       ;;
  }
}

view: total_order_category {
  derived_table: {
    persist_for: "24 hours"
    indexes: ["category"]
    sql: SELECT p.category as category
      , count(distinct p.category, o.id) as category_frequency
      FROM order_items oi
      JOIN orders o ON o.id = oi.order_id
      JOIN inventory_items ii ON oi.inventory_item_id = ii.id
      JOIN products p ON ii.product_id = p.id
      GROUP BY p.category
       ;;
  }
}

view: order_category_affinity {
  derived_table: {
    persist_for: "24 hours"
    indexes: ["category_a"]
    sql: SELECT category_a
      , category_b
      , joint_frequency
      , toc1.category_frequency as category_a_frequency
      , toc2.category_frequency as category_b_frequency
      FROM (
        SELECT oc1.category as category_a
        , oc2.category as category_b
        , count(*) as joint_frequency
        FROM ${order_category.SQL_TABLE_NAME} as oc1
        JOIN ${order_category.SQL_TABLE_NAME} oc2 ON oc1.order_id = oc2.order_id
        GROUP BY category_a, category_b
      ) as prop
      JOIN ${total_order_category.SQL_TABLE_NAME} as toc1 ON prop.category_a = toc1.category
      JOIN ${total_order_category.SQL_TABLE_NAME} as toc2 ON prop.category_b = toc2.category
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
