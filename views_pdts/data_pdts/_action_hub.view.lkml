explore: event_list {}
view: event_list {
  derived_table: {
    sql: SELECT 'Flora Severe' AS name,'Female' AS gender,'florasevere@gmail.com' AS email,10001 AS zipcode,'SF Mission Store Launch' AS event_name,'no' AS previous_customer
      UNION ALL
      SELECT 'Colleen Delong','Female','colleendelong@gmail.com',10805,'SF Mission Store Launch','no'
      UNION ALL
      SELECT 'Lucy Willis','Female','lwillis@yahoo.com',10176,'SF Mission Store Launch','no'
      UNION ALL
      SELECT 'Damian Wellman','Male','dwellman@gmail.com',10045,'SF Mission Store Launch','no'
      UNION ALL
      SELECT 'Russell Choy','Male','russellchoy@gmail.com',14043,'SF Mission Store Launch','no'
      UNION ALL
      SELECT 'Florence Larios','Female','flarios@yahoo.com',10072,'SF Mission Store Launch','no'
      UNION ALL
      SELECT 'Sharon Garcia','Female','sharon.garcia@yahoo.com',12170,'SF Mission Store Launch','yes'
      UNION ALL
      SELECT 'Jeannette Weisser','Female','jweisser@gmail.com',12986,'SF Mission Store Launch','yes'
      UNION ALL
      SELECT 'Maryetta Ward','Female','mward@gmail.com',10276,'SF Mission Store Launch','no'
      UNION ALL
      SELECT 'Lorena Joyner','Female','ljoyner@yahoo.com',10128,'SF Mission Store Launch','no'
      UNION ALL
      SELECT 'Flora Severe','Female','florasevere@gmail.com',10001,'Office Warming','yes'
      UNION ALL
      SELECT 'Lucy Willis','Female','lwillis@yahoo.com',10176,'Office Warming','yes'
      UNION ALL
      SELECT 'Damian Wellman','Male','dwellman@gmail.com',10045,'Office Warming','yes'
      UNION ALL
      SELECT 'Colleen Delong','Female','colleendelong@gmail.com',10805,'Office Warming','no'
      UNION ALL
      SELECT 'Russell Choy','Male','russellchoy@gmail.com',14043,'Office Warming','no'
      UNION ALL
      SELECT 'Sharon Garcia','Female','sharon.garcia@yahoo.com',12170,'Office Warming','no'
      UNION ALL
      SELECT 'Florence Larios','Female','flarios@yahoo.com',10072,'Office Warming','no'
      UNION ALL
      SELECT 'Maryetta Ward','Female','mward@gmail.com',10276,'Office Warming','no'
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: email {
    tags: ["email"]
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: zipcode {
    type: string
    sql: ${TABLE}.zipcode ;;
  }

  dimension: event_name {
    type: string
    sql: ${TABLE}.event_name ;;
  }

  dimension: previous_customer {
    type: string
    sql: ${TABLE}.previous_customer ;;
  }

  set: detail {
    fields: [
      name,
      gender,
      email,
      zipcode,
      event_name,
      previous_customer
    ]
  }
}

explore: customer_list {}
view: customer_list {
  view_label: "Customer"
  derived_table: {
    sql:
  SELECT 'Scent.ly' AS "customer_name",
          'Premium' AS "StandardPremium",
          'Enterprise' AS "Size",
          '3.0' AS "release",
          '853-874-0928' AS Point_of_Contact
      UNION ALL
      SELECT 'Paper source','Standard','Mid Market','3.0', '233-987-2922'
      UNION ALL
      SELECT 'Acumen','Premium','Mid Market','2.0', '892-234-9832'
      UNION ALL
      SELECT 'Buildify','Premium','Mid Market','2.0', '908-098-0000'
      UNION ALL
      SELECT 'Ecoveta','Premium','Mid Market','2.0', '992-232-4343'
      UNION ALL
      SELECT 'DigiQ','Premium','Mid Market','2.0', '133-783-4343'
      UNION ALL
      SELECT 'Finistone','Standard','SMB','1.0', '893-232-7893'
      UNION ALL
      SELECT 'Blackstar','Standard','SMB','1.0', '567-232-7782'
      UNION ALL
      SELECT 'Mylie','Standard','SMB','1.0', '202-282-8843'
            UNION ALL
      SELECT 'Cyprus','Standard','Mid Market','3.0', '879-098-0182'
      UNION ALL
      SELECT 'Papel','Premium','Mid Market','3.0', '892-234-9832'
      UNION ALL
      SELECT 'Woddify','Premium','Mid Market','3.0', '908-098-0000'
      UNION ALL
      SELECT 'LimeFight','Premium','Mid Market','3.0', '992-232-4343'
      UNION ALL
      SELECT 'Dire.io','Premium','Mid Market','2.0', '133-783-4343'
      UNION ALL
      SELECT 'Copit.io','Standard','SMB','1.0', '893-232-7893'
      UNION ALL
      SELECT 'Newly','Standard','SMB','1.0', '567-232-7782'
      UNION ALL
      SELECT 'Rubilsify','Standard','SMB','1.0', '202-282-8843'
      ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.customer_name ;;
    tags: ["email"]
    action: {
      label: "Email Release Notice"
      url: "https://desolate-refuge-53336.herokuapp.com/posts"
      icon_url: "https://sendgrid.com/favicon.ico"
      param: {
        name: "some_auth_code"
        value: "abc123456"
      }
      form_param: {
        name: "Subject"
        required: yes
        default: "Release Notification - {{ customer_list.release._value }}"
      }
      form_param: {
        name: "Body"
        type: textarea
        required: yes
        default:
        "Dear {{ customer_list.name._value }},

        There’s an issue with your latest Initech release. We’ll be rolling you back shortly. Contact support with any questions"
      }
    }
  }

  dimension: standard_premium {
    type: string
    sql: ${TABLE}.standardpremium ;;
  }

  dimension: size {
    type: string
    sql: ${TABLE}.size ;;
  }

  dimension: release {
    type: string
    sql: ${TABLE}.release ;;
  }

  dimension: point_of_contact {
    tags: ["phone"]
    type: string
    sql: ${TABLE}.point_of_contact ;;
  }

  set: detail {
    fields: [name, standard_premium, size, release]
  }
}
