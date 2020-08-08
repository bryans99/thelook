- dashboard: merge_result_filter
  title: Merge Result Filter
  layout: newspaper
  tile_size: 100

  filters:
    - name: Created Date
      title: Created Date
      type: field_filter
      default_value: 7 day
      allow_multiple_values: true
      required: false
      ui_config:
        type: relative_timeframes
        display: overflow
        options: []
      model: thelook
      explore: order_items
      listens_to_filters: []
      field: order_items.return_date

  elements:
    - name: New Tile
      title: New Tile
      merged_queries:
      - model: thelook
        explore: order_items
        type: looker_line
        fields: [order_items.total_sales, users.state]
        filters:
          order_items.return_date: 7 days
        sorts: [order_items.total_sales desc]
        limit: 500
        column_limit: 50
        x_axis_gridlines: false
        y_axis_gridlines: true
        show_view_names: true
        show_y_axis_labels: true
        show_y_axis_ticks: true
        y_axis_tick_density: default
        y_axis_tick_density_custom: 5
        show_x_axis_label: true
        show_x_axis_ticks: true
        y_axis_scale_mode: linear
        x_axis_reversed: false
        y_axis_reversed: false
        plot_size_by_field: false
        trellis: ''
        stacking: ''
        limit_displayed_rows: false
        legend_position: center
        point_style: none
        show_value_labels: false
        label_density: 25
        x_axis_scale: auto
        y_axis_combined: true
        show_null_points: true
        interpolation: linear
        colors: ["#62bad4", "#a9c574", "#929292", "#9fdee0", "#1f3e5a", "#90c8ae", "#92818d",
          "#c5c6a6", "#82c2ca", "#cee0a0", "#928fb4", "#9fc190"]
        series_colors: {}
        series_types: {}
        defaults_version: 1
      - model: thelook
        explore: order_items
        type: table
        fields: [users.state, order_items.avg_items_per_order]
        filters:
        sorts: [order_items.avg_items_per_order desc]
        limit: 500
        query_timezone: America/Los_Angeles
        join_fields:
        - field_name: users.state
          source_field_name: users.state
      type: table
      row: 15
      col: 0
      width: 8
      height: 6
