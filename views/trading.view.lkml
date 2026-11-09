view: trading {
  label: "Trading 360"
  sql_table_name: `agentspace-448017.cymbal_retail_demo.v_monday_trading_360` ;;

  dimension: pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.pk ;;
  }

  dimension_group: data {
    label: "Trading"
    group_label: "Time"
    description: "Trading date (Europe/Zurich)"
    type: time
    timeframes: [date, week, month, quarter, year, day_of_week]
    datatype: date
    convert_tz: no
    sql: ${TABLE}.data_date ;;
  }

  dimension: country {
    label: "Country"
    group_label: "Geography"
    description: "IT (Italy) or CH (Switzerland)"
    type: string
    sql: ${TABLE}.country ;;
  }

  dimension: region {
    label: "Region"
    group_label: "Geography"
    description: "Operating region (Lombardia, Zurich, Ticino, Emilia-Romagna, Veneto, Piemonte, Lazio, Toscana)"
    type: string
    sql: ${TABLE}.region ;;
  }

  dimension: product_id {
    label: "Product ID"
    group_label: "Catalog"
    type: number
    value_format_name: id
    sql: ${TABLE}.product_id ;;
  }

  dimension: ean_code {
    label: "EAN Code"
    group_label: "Catalog"
    type: string
    sql: ${TABLE}.ean_code ;;
  }

  dimension: sap_material_id {
    label: "SAP Material ID"
    group_label: "Catalog"
    type: string
    sql: ${TABLE}.sap_material_id ;;
  }

  dimension: product_name {
    label: "SKU / Product"
    group_label: "Catalog"
    type: string
    sql: ${TABLE}.product_name ;;
  }

  dimension: brand {
    label: "Brand"
    group_label: "Catalog"
    type: string
    sql: ${TABLE}.brand ;;
  }

  dimension: is_private_label {
    label: "Own Brand (Private Label)"
    group_label: "Catalog"
    type: yesno
    sql: ${TABLE}.is_private_label ;;
  }

  dimension: department {
    label: "Department"
    group_label: "Catalog"
    type: string
    sql: ${TABLE}.department ;;
  }

  dimension: category {
    label: "Category"
    group_label: "Catalog"
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: is_cpg_promoted {
    label: "CPG Promoted SKU"
    group_label: "Catalog"
    type: yesno
    sql: ${TABLE}.is_cpg_promoted ;;
  }

  dimension: cpg_advertiser {
    label: "CPG Advertiser"
    group_label: "Retail Media (GAM)"
    type: string
    sql: ${TABLE}.cpg_advertiser ;;
  }

  dimension: gam_line_item_name {
    label: "GAM Line Item"
    group_label: "Retail Media (GAM)"
    type: string
    sql: ${TABLE}.gam_line_item_name ;;
  }

  dimension: pacing_status {
    label: "Media Pacing Status"
    group_label: "Retail Media (GAM)"
    type: string
    sql: ${TABLE}.pacing_status ;;
  }

  dimension: recommended_action {
    label: "Recommended Action"
    group_label: "Retail Media (GAM)"
    type: string
    sql: ${TABLE}.recommended_action ;;
  }

  dimension: substitute_product_name {
    label: "In-Stock Substitute SKU"
    group_label: "Retail Media (GAM)"
    type: string
    sql: ${TABLE}.substitute_product_name ;;
  }

  # ------------------------------------------------------------------ SAP S/4HANA Measures
  measure: net_sales_eur {
    label: "SAP Net Sales (EUR)"
    group_label: "1. SAP S/4HANA"
    description: "Realized store & omnichannel net sales in EUR"
    type: sum
    value_format_name: eur
    sql: ${TABLE}.net_sales_eur ;;
  }

  measure: lost_sales_eur {
    label: "SAP Lost Sales (EUR)"
    group_label: "1. SAP S/4HANA"
    description: "Estimated revenue lost due to shelf stock-outs in SAP S/4HANA (EUR)"
    type: sum
    value_format_name: eur
    sql: ${TABLE}.lost_sales_eur ;;
  }

  measure: spoilage_waste_eur {
    label: "SAP Spoilage & Waste (EUR)"
    group_label: "1. SAP S/4HANA"
    description: "Perishable spoilage and markdown write-offs in EUR"
    type: sum
    value_format_name: eur
    sql: ${TABLE}.spoilage_waste_eur ;;
  }

  measure: units_sold {
    label: "Units Sold"
    group_label: "1. SAP S/4HANA"
    type: sum
    sql: ${TABLE}.units_sold ;;
  }

  measure: lost_sales_units {
    label: "Lost Sales Units"
    group_label: "1. SAP S/4HANA"
    type: sum
    sql: ${TABLE}.lost_sales_units ;;
  }

  measure: stockout_events {
    label: "SAP Stock-Out Store-Days"
    group_label: "1. SAP S/4HANA"
    type: sum
    sql: ${TABLE}.stockout_events ;;
  }

  measure: store_sku_days {
    hidden: yes
    type: sum
    sql: ${TABLE}.store_sku_days ;;
  }

  measure: stockout_hours {
    label: "SAP Stock-Out Hours"
    group_label: "1. SAP S/4HANA"
    type: sum
    value_format_name: decimal_1
    sql: ${TABLE}.stockout_hours ;;
  }

  measure: stockout_rate {
    label: "SAP Stock-Out Rate"
    group_label: "1. SAP S/4HANA"
    description: "Share of store-days with zero shelf stock (0-1 ratio)"
    type: number
    value_format_name: percent_1
    sql: SAFE_DIVIDE(${stockout_events}, NULLIF(${store_sku_days}, 0)) ;;
  }

  measure: avg_lead_days {
    label: "Avg Replenishment Lead Days"
    group_label: "1. SAP S/4HANA"
    type: average
    value_format_name: decimal_1
    sql: ${TABLE}.avg_lead_days ;;
  }

  # ------------------------------------------------------------------ E-Commerce ERP Measures
  measure: ecomm_orders {
    label: "ERP E-Comm Orders"
    group_label: "2. E-Commerce ERP"
    type: sum
    sql: ${TABLE}.ecomm_orders ;;
  }

  measure: late_deliveries {
    label: "ERP Late Deliveries"
    group_label: "2. E-Commerce ERP"
    description: "Online & Click-and-Collect orders missing promised delivery window"
    type: sum
    sql: ${TABLE}.late_deliveries ;;
  }

  measure: oos_substitutions {
    label: "ERP OOS Substitutions"
    group_label: "2. E-Commerce ERP"
    description: "E-Commerce orders delayed by SAP stock-out forced substitutions"
    type: sum
    sql: ${TABLE}.oos_substitutions ;;
  }

  measure: late_delivery_rate {
    label: "ERP Late Delivery Rate"
    group_label: "2. E-Commerce ERP"
    description: "Late deliveries / total e-commerce orders (0-1 ratio)"
    type: number
    value_format_name: percent_1
    sql: SAFE_DIVIDE(${late_deliveries}, NULLIF(${ecomm_orders}, 0)) ;;
  }

  measure: ecomm_order_value_eur {
    label: "ERP Order Value (EUR)"
    group_label: "2. E-Commerce ERP"
    type: sum
    value_format_name: eur
    sql: ${TABLE}.ecomm_order_value_eur ;;
  }

  # ------------------------------------------------------------------ Salesforce CRM Measures
  measure: high_risk_customers_hit {
    label: "CRM High-Churn Buyers Hit"
    group_label: "3. Salesforce CRM"
    description: "High-churn-risk loyalty members impacted by late/substituted orders"
    type: sum
    sql: ${TABLE}.high_risk_customers_hit ;;
  }

  measure: ltv_at_risk_eur {
    label: "CRM Annual LTV at Risk (EUR)"
    group_label: "3. Salesforce CRM"
    description: "Annual customer lifetime value exposed to churn from OOS & late fulfillment (EUR)"
    type: sum
    value_format_name: eur
    sql: ${TABLE}.ltv_at_risk_eur ;;
  }

  # ------------------------------------------------------------------ Google Ad Manager Measures
  measure: daily_budget_eur {
    label: "GAM Planned Budget (EUR)"
    group_label: "4. Google Ad Manager"
    type: sum
    value_format_name: eur
    sql: ${TABLE}.daily_budget_eur ;;
  }

  measure: ad_spend_eur {
    label: "GAM Ad Spend (EUR)"
    group_label: "4. Google Ad Manager"
    description: "Actual CPG sponsored retail-media spend delivered in Google Ad Manager (EUR)"
    type: sum
    value_format_name: eur
    sql: ${TABLE}.ad_spend_eur ;;
  }

  measure: wasted_oos_spend_eur {
    label: "GAM Wasted OOS Ad Spend (EUR)"
    group_label: "4. Google Ad Manager"
    description: "Ad spend served while the promoted SKU was out-of-stock in that region (EUR)"
    type: sum
    value_format_name: eur
    sql: ${TABLE}.wasted_oos_spend_eur ;;
  }

  measure: wasted_spend_share {
    label: "GAM Wasted Spend Share"
    group_label: "4. Google Ad Manager"
    description: "Wasted OOS ad spend / total GAM ad spend (0-1 ratio)"
    type: number
    value_format_name: percent_1
    sql: SAFE_DIVIDE(${wasted_oos_spend_eur}, NULLIF(${ad_spend_eur}, 0)) ;;
  }

  measure: media_pacing_pct {
    label: "GAM Media Pacing %"
    group_label: "4. Google Ad Manager"
    description: "Delivered GAM ad spend vs planned budget (0-1+ ratio)"
    type: number
    value_format_name: percent_1
    sql: SAFE_DIVIDE(${ad_spend_eur}, NULLIF(${daily_budget_eur}, 0)) ;;
  }

  measure: impressions {
    label: "GAM Impressions"
    group_label: "4. Google Ad Manager"
    type: sum
    sql: ${TABLE}.impressions ;;
  }

  measure: clicks {
    label: "GAM Clicks"
    group_label: "4. Google Ad Manager"
    type: sum
    sql: ${TABLE}.clicks ;;
  }

  measure: ctr {
    label: "GAM CTR"
    group_label: "4. Google Ad Manager"
    type: number
    value_format_name: percent_2
    sql: SAFE_DIVIDE(${clicks}, NULLIF(${impressions}, 0)) ;;
  }

  measure: attributed_gmv_eur {
    label: "GAM Attributed GMV (EUR)"
    group_label: "4. Google Ad Manager"
    type: sum
    value_format_name: eur
    sql: ${TABLE}.attributed_gmv_eur ;;
  }

  measure: roas {
    label: "GAM ROAS (x)"
    group_label: "4. Google Ad Manager"
    description: "Attributed GMV / GAM Ad Spend"
    type: number
    value_format_name: decimal_2
    sql: SAFE_DIVIDE(${attributed_gmv_eur}, NULLIF(${ad_spend_eur}, 0)) ;;
  }

  measure: total_revenue_leakage_eur {
    label: "Total Revenue & Media Leakage (EUR)"
    group_label: "Cross-System KPIs"
    description: "SAP Lost Sales + GAM Wasted OOS Ad Spend + SAP Spoilage Waste (EUR)"
    type: number
    value_format_name: eur
    sql: COALESCE(${lost_sales_eur}, 0) + COALESCE(${wasted_oos_spend_eur}, 0) + COALESCE(${spoilage_waste_eur}, 0) ;;
  }
}
