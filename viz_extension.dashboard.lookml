- dashboard: viz_extension
  title: Viz Extension
  layout: newspaper
  preferred_viewer: dashboards-next
  description: ''
  elements:
  - title: "Kitchen Sink"
    name: "Kitchen Sink"
    model: thelook
    explore: products
    type: kitchensink::kitchensink
    fields: [products.count, calculation_1]
    sorts: [products.count desc]
    limit: 500
    query_timezone: America/Los_Angeles
    row: 0
    col: 8
    width: 25
    height: 16
