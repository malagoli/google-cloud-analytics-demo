view: sap_inventory {
  label: "SAP S/4HANA Store Inventory"
  sql_table_name: `agentspace-448017.cymbal_retail_demo.v_sap_s4_inventory` ;;

  dimension: pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: CONCAT(CAST(${TABLE}.data_date AS STRING), ':', CAST(${TABLE}.store_id AS STRING), ':', CAST(${TABLE}.product_id AS STRING)) ;;
  }

  dimension_group: data {
    label: "Inventory"
    type: time
    timeframes: [date, week, month]
    datatype: date
    convert_tz: no
    sql: ${TABLE}.data_date ;;
  }

  dimension: country { type: string sql: ${TABLE}.country ;; }
  dimension: region { type: string sql: ${TABLE}.region ;; }
  dimension: city { type: string sql: ${TABLE}.city ;; }
  dimension: store_code { label: "Store Code" type: string sql: ${TABLE}.store_code ;; }
  dimension: store_name { label: "Store Name" type: string sql: ${TABLE}.store_name ;; }
  dimension: banner { label: "Banner" type: string sql: ${TABLE}.banner ;; }
  dimension: sap_plant_code { label: "SAP Plant" type: string sql: ${TABLE}.sap_plant_code ;; }
  dimension: sap_material_id { label: "SAP Material" type: string sql: ${TABLE}.sap_material_id ;; }
  dimension: ean_code { label: "EAN" type: string sql: ${TABLE}.ean_code ;; }
  dimension: product_name { label: "SKU / Product" type: string sql: ${TABLE}.product_name ;; }
  dimension: brand { type: string sql: ${TABLE}.brand ;; }
  dimension: category { type: string sql: ${TABLE}.category ;; }
  dimension: is_cpg_promoted { label: "CPG Promoted" type: yesno sql: ${TABLE}.is_cpg_promoted ;; }
  dimension: is_stockout { label: "Is Out of Stock" type: yesno sql: ${TABLE}.is_stockout ;; }
  dimension: sap_mrp_status { label: "SAP MRP Status" type: string sql: ${TABLE}.sap_mrp_status ;; }

  measure: store_days { hidden: yes type: count }
  measure: stockout_store_days { label: "Stock-Out Store-Days" type: count filters: [is_stockout: "yes"] }
  measure: stockout_rate { label: "Stock-Out Rate" type: number value_format_name: percent_1 sql: SAFE_DIVIDE(${stockout_store_days}, NULLIF(${store_days}, 0)) ;; }
  measure: net_sales_eur { label: "Net Sales (EUR)" type: sum value_format_name: eur sql: ${TABLE}.net_sales_eur ;; }
  measure: lost_sales_eur { label: "Lost Sales (EUR)" type: sum value_format_name: eur sql: ${TABLE}.lost_sales_eur ;; }
  measure: spoilage_waste_eur { label: "Spoilage Waste (EUR)" type: sum value_format_name: eur sql: ${TABLE}.spoilage_waste_eur ;; }
  measure: stockout_hours { label: "Stock-Out Hours" type: sum value_format_name: decimal_1 sql: ${TABLE}.stockout_hours ;; }
}

view: erp_orders {
  label: "E-Commerce ERP & CRM Loyalty"
  sql_table_name: `agentspace-448017.cymbal_retail_demo.v_erp_crm_orders` ;;

  dimension: order_id { primary_key: yes label: "ERP Order ID" type: string sql: ${TABLE}.order_id ;; }
  dimension_group: data {
    label: "Order"
    type: time
    timeframes: [date, week, month]
    datatype: date
    convert_tz: no
    sql: ${TABLE}.data_date ;;
  }
  dimension: country { type: string sql: ${TABLE}.country ;; }
  dimension: region { type: string sql: ${TABLE}.region ;; }
  dimension: store_name { label: "Fulfillment Hub / Store" type: string sql: ${TABLE}.store_name ;; }
  dimension: fulfillment_channel { label: "Fulfillment Channel" type: string sql: ${TABLE}.fulfillment_channel ;; }
  dimension: product_name { label: "Hero SKU" type: string sql: ${TABLE}.product_name ;; }
  dimension: category { type: string sql: ${TABLE}.category ;; }
  dimension: is_late_delivery { label: "Is Late Delivery" type: yesno sql: ${TABLE}.is_late_delivery ;; }
  dimension: has_oos_substitution { label: "Has SAP OOS Substitution" type: yesno sql: ${TABLE}.has_oos_substitution ;; }
  dimension: delay_reason { label: "Delay Root Cause" type: string sql: ${TABLE}.delay_reason ;; }
  dimension: fidelity_code { label: "CRM Fidelity ID" type: string sql: ${TABLE}.fidelity_code ;; }
  dimension: email_masked { label: "Email (PII Masked)" type: string sql: ${TABLE}.email_masked ;; }
  dimension: loyalty_tier { label: "CRM Loyalty Tier" type: string sql: ${TABLE}.loyalty_tier ;; }
  dimension: churn_risk_band { label: "CRM Churn Risk Band" type: string sql: ${TABLE}.churn_risk_band ;; }

  measure: orders_count { label: "E-Comm Orders" type: count }
  measure: late_deliveries { label: "Late Deliveries" type: count filters: [is_late_delivery: "yes"] }
  measure: late_delivery_rate { label: "Late Delivery Rate" type: number value_format_name: percent_1 sql: SAFE_DIVIDE(${late_deliveries}, NULLIF(${orders_count}, 0)) ;; }
  measure: order_value_eur { label: "Order Value (EUR)" type: sum value_format_name: eur sql: ${TABLE}.order_value_eur ;; }
  measure: distinct_customers { label: "Impacted Customers" type: count_distinct sql: ${TABLE}.customer_id ;; }
  measure: high_risk_customers { label: "High-Churn Customers" type: count_distinct sql: ${TABLE}.customer_id ;; filters: [churn_risk_band: "High", is_late_delivery: "yes"] }
  measure: avg_delay_minutes { label: "Avg Delay (min)" type: average value_format_name: decimal_1 sql: ${TABLE}.delay_minutes ;; filters: [is_late_delivery: "yes"] }
}

view: retail_media {
  label: "Google Ad Manager Retail Media"
  sql_table_name: `agentspace-448017.cymbal_retail_demo.v_gam_retail_media` ;;

  dimension: pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: CONCAT(CAST(${TABLE}.data_date AS STRING), ':', CAST(${TABLE}.gam_line_item_id AS STRING), ':', ${TABLE}.region) ;;
  }
  dimension_group: data {
    label: "Flight"
    type: time
    timeframes: [date, week, month]
    datatype: date
    convert_tz: no
    sql: ${TABLE}.data_date ;;
  }
  dimension: country { type: string sql: ${TABLE}.country ;; }
  dimension: region { type: string sql: ${TABLE}.region ;; }
  dimension: cpg_advertiser { label: "CPG Advertiser" type: string sql: ${TABLE}.cpg_advertiser ;; }
  dimension: gam_order_name { label: "GAM Order" type: string sql: ${TABLE}.gam_order_name ;; }
  dimension: gam_line_item_name { label: "GAM Line Item" type: string sql: ${TABLE}.gam_line_item_name ;; }
  dimension: ad_placement { label: "Ad Placement" type: string sql: ${TABLE}.ad_placement ;; }
  dimension: product_name { label: "Promoted SKU" type: string sql: ${TABLE}.product_name ;; }
  dimension: substitute_product_name { label: "In-Stock Substitute SKU" type: string sql: ${TABLE}.substitute_product_name ;; }
  dimension: category { type: string sql: ${TABLE}.category ;; }
  dimension: pacing_status { label: "Pacing Status" type: string sql: ${TABLE}.pacing_status ;; }
  dimension: recommended_action { label: "Recommended Action" type: string sql: ${TABLE}.recommended_action ;; }

  measure: planned_budget_eur { label: "Planned Budget (EUR)" type: sum value_format_name: eur sql: ${TABLE}.daily_budget_eur ;; }
  measure: ad_spend_eur { label: "Ad Spend (EUR)" type: sum value_format_name: eur sql: ${TABLE}.ad_spend_eur ;; }
  measure: wasted_oos_spend_eur { label: "Wasted OOS Ad Spend (EUR)" type: sum value_format_name: eur sql: ${TABLE}.wasted_oos_spend_eur ;; }
  measure: pacing_pct { label: "Media Pacing %" type: number value_format_name: percent_1 sql: SAFE_DIVIDE(${ad_spend_eur}, NULLIF(${planned_budget_eur}, 0)) ;; }
  measure: impressions { label: "Impressions" type: sum sql: ${TABLE}.impressions ;; }
  measure: clicks { label: "Clicks" type: sum sql: ${TABLE}.clicks ;; }
  measure: ctr { label: "CTR" type: number value_format_name: percent_2 sql: SAFE_DIVIDE(${clicks}, NULLIF(${impressions}, 0)) ;; }
  measure: attributed_gmv_eur { label: "Attributed GMV (EUR)" type: sum value_format_name: eur sql: ${TABLE}.attributed_gmv_eur ;; }
  measure: roas { label: "ROAS (x)" type: number value_format_name: decimal_2 sql: SAFE_DIVIDE(${attributed_gmv_eur}, NULLIF(${ad_spend_eur}, 0)) ;; }
}
