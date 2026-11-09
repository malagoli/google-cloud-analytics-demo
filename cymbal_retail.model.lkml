connection: "gam_rda_bq"
label: "Cymbal Retail · Agentic Data Cloud (4-System Semantic Layer)"
include: "/views/*.view.lkml"

datagroup: cymbal_retail_daily {
  sql_trigger: SELECT CURRENT_DATE('Europe/Zurich') ;;
  max_cache_age: "4 hours"
}
persist_with: cymbal_retail_daily

explore: monday_trading_360 {
  view_name: trading
  label: "Monday Trading 360 (SAP + ERP + CRM + Ad Manager)"
  description: "Unified governed semantic layer across SAP S/4HANA inventory/stock-outs, E-Commerce ERP late deliveries, Salesforce CRM loyalty LTV at risk, and Google Ad Manager CPG retail-media spend & wasted OOS spend by date, country, region, category, brand and SKU."
  group_label: "Cymbal Retail"
}

explore: sap_inventory_store {
  view_name: sap_inventory
  label: "SAP S/4HANA Store Inventory & Stock-Outs"
  description: "Granular daily store x SKU stock on hand, safety stock, stock-out hours, lost sales, and perishable waste from SAP S/4HANA MM/SD."
  group_label: "Cymbal Retail"
}

explore: erp_crm_orders {
  view_name: erp_orders
  label: "E-Commerce ERP Orders & CRM Loyalty Impact"
  description: "Online grocery & Click-and-Collect fulfillment SLAs joined with PII-masked Salesforce CRM loyalty tiers, NPS, and annual LTV at churn risk."
  group_label: "Cymbal Retail"
}

explore: gam_retail_media {
  view_name: retail_media
  label: "Google Ad Manager · CPG Retail Media Pacing"
  description: "Daily CPG sponsored search & banner line-item delivery, flight pacing, ROAS, wasted ad spend on out-of-stock SKUs, and in-stock substitute recommendations."
  group_label: "Cymbal Retail"
}
