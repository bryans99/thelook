- dashboard: viz_extension
  title: Viz Extension Demo
  layout: newspaper
  preferred_viewer: dashboards-next
  description: ''
  elements:
  - title: Viz Extension
    name: Viz Extension
    model: thelook
    explore: users
    type: visualization_extension::visualization
    fields: [users.average_age, users.count]
    limit: 500
    query_timezone: America/Los_Angeles
    row: 0
    col: 8
    width: 25
    height: 16
