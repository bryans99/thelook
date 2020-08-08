label: "The Look"

connection: "thelook"

include: "../views_core/*.view"
include: "../views_other/*.view"
include: "../views_pdts/*.view"
include: "../views_pdts/data_pdts/*.view"

datagroup: thelook_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: thelook_default_datagroup

datagroup: aryeh_datagroup {
  sql_trigger:  SELECT 1 ;;
  max_cache_age: "24 hours"
}

datagroup: this_is_dumb {
  sql_trigger:  insert into profservices_scratch.special_trigger_test1 (
    select (select max(id) from profservices_scratch.special_trigger_test1)+1 as id, getdate() as log_date, 102 as value where (select age from public.users group by 1 having count(*)>10 limit 1)
    )
}

datagroup: step_1_master_trigger {
  sql_trigger: select floor(datediff(minute,'1999-12-31 00:00:00',getdate())/10) as ten_minute_intervals_since_2000 ;;
}

datagroup: alert_testing_manual_trigger_checker {
  sql_trigger: select trigger_value from  profservices_scratch.aaa_trigger_max;;
}

explore: order_items {
  view_name: order_items

  query: users_by_average_age {
    dimensions: [users.gender]
    measures: [users.average_age]
    sort: {field: users.average_age desc:no}
  }

  join: orders {
    # this is intentionally messed up for testing purposes:
    foreign_key: order_items.id #.order_id
  }

  join: products {
    foreign_key: inventory_items.product_id
  }

  join: users {
    foreign_key: orders.user_id
  }

  join: users_orders_facts {
    foreign_key: users.id
  }

  join: inventory_items {
    foreign_key: order_items.inventory_item_id
  }
}

explore: inventory_items {
  join: products {
    foreign_key: inventory_items.product_id
  }
}

explore: orders {
  join: users {
    foreign_key: orders.user_id
  }

  join: users_orders_facts {
    foreign_key: users.id
  }
}

explore: funnel {
  always_filter: {
    filters: {
      field: event_time
      value: "30 days ago for 30 days"
    }
  }

  join: users {
    foreign_key: user_id
  }

  join: users_orders_facts {
    foreign_key: users.id
  }

  join: orders {
    foreign_key: order_id
  }
}

explore: products {}

explore: users {
  join: users_orders_facts {
    foreign_key: users.id
  }

  join: users_revenue_facts {
    foreign_key: users.id
    relationship: one_to_one
  }

  join: users_sales_facts {
    foreign_key: users.id
  }
}

explore: users_cohorts {
  from: users
  always_join: [user_transactions_monthly, user_transactions_monthly_cumulative, users_orders_facts]

  join: users_orders_facts {
    foreign_key: users_cohorts.id
  }

  join: users_revenue_facts {
    foreign_key: users_cohorts.id
    relationship: one_to_one
  }

  join: users_sales_facts {
    foreign_key: users_cohorts.id
  }

  join: user_transactions_monthly {
    sql_on: user_transactions_monthly.user_id = users_cohorts.id ;;
    relationship: many_to_one
  }

  join: user_transactions_monthly_cumulative {
    required_joins: [user_transactions_monthly]
    sql_on: user_transactions_monthly_cumulative.user_id = users_cohorts.id AND user_transactions_monthly_cumulative.month = user_transactions_monthly.month ;;
    relationship: many_to_one
  }
}
