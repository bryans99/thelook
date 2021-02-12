view: products {
  # DIMENSIONS #

  dimension: id {
    type: number
    primary_key: yes
    sql: ${TABLE}.id ;;
  }

  dimension: brand_name {
    sql: ${TABLE}.brand ;;
    link: {
      label: "A special fancy external link"
      url: "https://lmgtfy.com/?q=looker"
    }
  }

  # We want category to be a top level entity even though doesn't
  dimension: category_name {
    alias: [category.name]
    description: "The name of a category"
    #  have its own table
    sql: ${TABLE}.category ;;
    link: {
      label: "Drill Dashboard"
      url: "/embed/dashboards-next/2"
    }
    }

  #       <img src="http://s1.huffpost.com/images/v/linkout_image.png" width=8 height=8></a>

  dimension: department_name {
    alias: [department.name]
    sql: ${TABLE}.department ;;
  }

  dimension: department_dashboard {
    sql: CONCAT("/dashboards/1095?Department=", ${TABLE}.department) ;;
    tags: ["looker_dashboard_url"]
  }

  dimension: item_name {
    sql: ${TABLE}.item_name ;;
  }

  dimension: rank {
    type: number
    value_format_name: decimal_0
    sql: ${TABLE}.rank ;;
  }

  dimension: retail_price {
    type: number
    value_format_name: decimal_2
    sql: ${TABLE}.retail_price ;;
  }

  dimension: retail_price_tiered {
    type: tier
    sql: ${retail_price} ;;
    tiers: [
      0,
      100,
      200,
      300,
      400,
      500,
      600,
      700,
      800,
      900,
      999
    ]
  }

  dimension: sku {
    sql: ${TABLE}.sku ;;
  }

  # these next two dimensions dyanmically builds an image file based on the product_id fior image dashboard
  dimension: image_file {
    sql: (concat('http://www.looker.com/_content/docs/99-hidden/images/image_',${id},'.png')) ;;
  }

  dimension: product_image {
    sql: ${image_file} ;;
    html: <img src="{{ value }}" width="100" height="100"/>;;
  }

  # MEASURES #

  # number of different products
  measure: count {
    type: count
    # set to show when the count field is clicked
    drill_fields: [detail*]
  }

  # number of different brands.
  measure: brand_count {
    alias: [brand.count]
    type: count_distinct
    # the field in the db to distinctly count
    sql: ${TABLE}.brand ;;
    # when the user clicks brand count
    drill_fields: [

      # show the brand
      brand_name,

      # a bunch of counts (see the set below)
      sub_detail*,

      # but don't show the brand count, because it will always be 1
      -brand_count
    ]
  }

  #
  measure: category_count {
    alias: [category.count]
    type: count_distinct
    sql: ${TABLE}.category ;;
    drill_fields: [category_name, sub_detail*, -category_count]
  }

  measure: department_count {
    alias: [department.count]
    type: count_distinct
    sql: ${TABLE}.department ;;
    drill_fields: [department_name, sub_detail*, -department_count]
  }

  measure: brand_list {
    type: list
    list_field: brand_name
  }

  measure: list {
    type: list
    list_field: item_name
  }

  # SETS #

  set: detail {
    fields: [
      id,
      item_name,
      brand_name,
      category_name,
      department_name,
      retail_price,

      # Counters for views that join 'products'
      customers.count,
      orders.count,
      order_items.count,
      inventory_items.count
    ]
  }

  set: sub_detail {
    fields: [
      category_count,
      brand_count,
      department_count,
      count,
      customers.count,
      orders.count,
      order_items.count,
      inventory_items.count,
      products.count
    ]
  }
}
