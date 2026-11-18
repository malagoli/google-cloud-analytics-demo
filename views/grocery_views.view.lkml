view: consortium_sales_forecast {
  sql_table_name: `grocery-demo-515014.grocery_serving.v_consortium_sales_and_forecast` ;;

  dimension: pk {
    primary_key: yes
    hidden: yes
    sql: CONCAT(${record_type}, '_', CAST(${week_raw} AS STRING), '_', ${affiliate_id}, '_', ${category}) ;;
  }

  dimension: record_type {
    type: string
    sql: ${TABLE}.record_type ;;
  }

  dimension_group: week {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.week_start ;;
  }

  dimension: affiliate_id { type: string sql: ${TABLE}.affiliate_id ;; }
  dimension: affiliate_name { type: string sql: ${TABLE}.affiliate_name ;; }
  dimension: region { type: string sql: ${TABLE}.region ;; }
  dimension: category { type: string sql: ${TABLE}.category ;; }
  dimension: model_name { type: string sql: ${TABLE}.model_name ;; }
  dimension: is_holiday { type: number sql: ${TABLE}.is_holiday ;; }

  measure: total_revenue_eur {
    type: sum
    sql: ${TABLE}.revenue_eur ;;
    value_format: "#,##0"
  }

  measure: historical_revenue_eur {
    type: sum
    sql: CASE WHEN ${TABLE}.record_type = 'HISTORY' THEN ${TABLE}.revenue_eur ELSE NULL END ;;
    value_format: "#,##0"
  }

  measure: forecast_revenue_eur {
    type: sum
    sql: CASE WHEN ${TABLE}.record_type = 'FORECAST' THEN ${TABLE}.revenue_eur ELSE NULL END ;;
    value_format: "#,##0"
  }

  measure: forecast_lower_95_eur {
    type: sum
    sql: CASE WHEN ${TABLE}.record_type = 'FORECAST' THEN ${TABLE}.revenue_lower_95 ELSE NULL END ;;
    value_format: "#,##0"
  }

  measure: forecast_upper_95_eur {
    type: sum
    sql: CASE WHEN ${TABLE}.record_type = 'FORECAST' THEN ${TABLE}.revenue_upper_95 ELSE NULL END ;;
    value_format: "#,##0"
  }

  measure: total_units_sold {
    type: sum
    sql: ${TABLE}.units_sold ;;
    value_format: "#,##0"
  }

  measure: total_margin_eur {
    type: sum
    sql: ${TABLE}.margin_eur ;;
    value_format: "#,##0"
  }

  measure: avg_promo_depth_pct {
    type: average
    sql: ${TABLE}.promo_depth_pct ;;
    value_format: "0.0%"
  }

  measure: row_count { type: count }
}

view: consortium_anonymous_benchmark {
  sql_table_name: `grocery-demo-515014.grocery_serving.v_consortium_anonymous_benchmark` ;;

  dimension_group: week {
    type: time
    timeframes: [raw, date, week]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.week_start ;;
  }
  dimension: category { type: string sql: ${TABLE}.category ;; }
  measure: group_avg_affiliate_revenue_eur {
    type: sum
    sql: ${TABLE}.group_avg_affiliate_revenue_eur ;;
    value_format: "#,##0"
  }
  measure: group_avg_margin_pct {
    type: average
    sql: ${TABLE}.group_avg_margin_pct ;;
    value_format: "0.0"
  }
}

view: dynamic_personas {
  sql_table_name: `grocery-demo-515014.grocery_serving.v_dynamic_personas_governed` ;;

  dimension: pk {
    primary_key: yes
    hidden: yes
    sql: CONCAT(${snapshot_period}, '_', ${affiliate_id}, '_', CAST(${cluster_id} AS STRING)) ;;
  }

  dimension: snapshot_period { type: string sql: ${TABLE}.snapshot_period ;; }
  dimension: affiliate_id { type: string sql: ${TABLE}.affiliate_id ;; }
  dimension: affiliate_name { type: string sql: ${TABLE}.affiliate_name ;; }
  dimension: region { type: string sql: ${TABLE}.region ;; }
  dimension: cluster_id { type: number sql: ${TABLE}.cluster_id ;; }
  dimension: persona_name { type: string sql: ${TABLE}.persona_name ;; }
  dimension: archetype_tagline { type: string sql: ${TABLE}.archetype_tagline ;; }
  dimension: shopping_mission { type: string sql: ${TABLE}.shopping_mission ;; }
  dimension: price_sensitivity_band { type: string sql: ${TABLE}.price_sensitivity_band ;; }
  dimension: preferred_channel_format { type: string sql: ${TABLE}.preferred_channel_format ;; }
  dimension: recommended_mdd_strategy { type: string sql: ${TABLE}.recommended_mdd_strategy ;; }
  dimension: ai_narrative_summary { type: string sql: ${TABLE}.ai_narrative_summary ;; }

  measure: total_active_customers {
    type: sum
    sql: ${TABLE}.active_customers ;;
    value_format: "#,##0"
  }
  measure: avg_persona_share_pct {
    type: average
    sql: ${TABLE}.persona_share_pct ;;
    value_format: "0.0"
  }
  measure: avg_basket_eur {
    type: average
    sql: ${TABLE}.avg_basket_eur ;;
    value_format: "0.00"
  }
  measure: avg_promo_share_pct {
    type: average
    sql: ${TABLE}.promo_share_pct ;;
    value_format: "0.0"
  }
  measure: avg_organic_share_pct {
    type: average
    sql: ${TABLE}.organic_share_pct ;;
    value_format: "0.0"
  }
  measure: avg_protein_share_pct {
    type: average
    sql: ${TABLE}.protein_share_pct ;;
    value_format: "0.0"
  }
  measure: avg_mdd_share_pct {
    type: average
    sql: ${TABLE}.mdd_share_pct ;;
    value_format: "0.0"
  }
}

view: new_product_launch {
  sql_table_name: `grocery-demo-515014.grocery_serving.v_new_product_launch_intelligence` ;;

  dimension: pk {
    primary_key: yes
    hidden: yes
    sql: CONCAT(${concept_id}, '_', ${forecast_method}, '_', CAST(${launch_week_num} AS STRING), '_', ${affiliate_id}) ;;
  }

  dimension: concept_id { type: string sql: ${TABLE}.concept_id ;; }
  dimension: product_name { type: string sql: ${TABLE}.product_name ;; }
  dimension: brand_name { type: string sql: ${TABLE}.brand_name ;; }
  dimension: brand_tier { type: string sql: ${TABLE}.brand_tier ;; }
  dimension: sub_segment { type: string sql: ${TABLE}.sub_segment ;; }
  dimension: target_price_eur { type: number sql: ${TABLE}.target_price_eur ;; value_format: "0.00" }
  dimension: forecast_method { type: string sql: ${TABLE}.forecast_method ;; }
  dimension: launch_week_num { type: number sql: ${TABLE}.launch_week_num ;; }
  dimension_group: forecast_week {
    type: time
    timeframes: [raw, date, week]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.forecast_week_start ;;
  }
  dimension: affiliate_id { type: string sql: ${TABLE}.affiliate_id ;; }
  dimension: affiliate_name { type: string sql: ${TABLE}.affiliate_name ;; }
  dimension: region { type: string sql: ${TABLE}.region ;; }
  dimension: top_adopting_persona { type: string sql: ${TABLE}.top_adopting_persona ;; }
  dimension: top_analog_sku_name { type: string sql: ${TABLE}.top_analog_sku_name ;; }

  measure: total_forecast_units {
    type: sum
    sql: ${TABLE}.forecast_units ;;
    value_format: "#,##0"
  }
  measure: total_forecast_revenue_eur {
    type: sum
    sql: ${TABLE}.forecast_revenue_eur ;;
    value_format: "#,##0"
  }
  measure: total_forecast_margin_eur {
    type: sum
    sql: ${TABLE}.forecast_margin_eur ;;
    value_format: "#,##0"
  }
  measure: avg_weighted_buy_probability {
    type: average
    sql: ${TABLE}.weighted_buy_probability ;;
    value_format: "0.0%"
  }
}

view: persona_willingness {
  sql_table_name: `grocery-demo-515014.grocery_serving.v_persona_willingness_matrix` ;;

  dimension: pk {
    primary_key: yes
    hidden: yes
    sql: CONCAT(${concept_id}, '_', ${model_endpoint}, '_', CAST(${cluster_id} AS STRING)) ;;
  }

  dimension: concept_id { type: string sql: ${TABLE}.concept_id ;; }
  dimension: product_name { type: string sql: ${TABLE}.product_name ;; }
  dimension: target_price_eur { type: number sql: ${TABLE}.target_price_eur ;; }
  dimension: sub_segment { type: string sql: ${TABLE}.sub_segment ;; }
  dimension: model_endpoint { type: string sql: ${TABLE}.model_endpoint ;; }
  dimension: cluster_id { type: number sql: ${TABLE}.cluster_id ;; }
  dimension: persona_name { type: string sql: ${TABLE}.persona_name ;; }
  dimension: archetype_tagline { type: string sql: ${TABLE}.archetype_tagline ;; }
  dimension: price_verdict { type: string sql: ${TABLE}.price_verdict ;; }
  dimension: primary_driver { type: string sql: ${TABLE}.primary_driver ;; }
  dimension: primary_barrier { type: string sql: ${TABLE}.primary_barrier ;; }
  dimension: persona_quote { type: string sql: ${TABLE}.persona_quote ;; }

  measure: avg_willingness_score_10 {
    type: average
    sql: ${TABLE}.willingness_score_10 ;;
    value_format: "0.00"
  }
  measure: avg_buy_probability {
    type: average
    sql: ${TABLE}.buy_probability ;;
    value_format: "0.0%"
  }
  measure: avg_trial_rate {
    type: average
    sql: ${TABLE}.trial_rate ;;
    value_format: "0.0%"
  }
  measure: avg_repeat_rate {
    type: average
    sql: ${TABLE}.repeat_rate ;;
    value_format: "0.0%"
  }
}

view: eval_forecasting_models {
  sql_table_name: `grocery-demo-515014.grocery_serving.v_eval_forecasting_models` ;;

  dimension: pk {
    primary_key: yes
    hidden: yes
    sql: CONCAT(${slice_level}, '_', ${slice_value}, '_', ${model_name}) ;;
  }
  dimension: slice_level { type: string sql: ${TABLE}.slice_level ;; }
  dimension: slice_value { type: string sql: ${TABLE}.slice_value ;; }
  dimension: model_name { type: string sql: ${TABLE}.model_name ;; }
  dimension: model_family { type: string sql: ${TABLE}.model_family ;; }
  dimension: execution_surface { type: string sql: ${TABLE}.execution_surface ;; }

  measure: wmape_pct { type: average sql: ${TABLE}.wmape_pct ;; value_format: "0.00" }
  measure: smape_pct { type: average sql: ${TABLE}.smape_pct ;; value_format: "0.00" }
  measure: mae_eur { type: average sql: ${TABLE}.mae_eur ;; value_format: "#,##0.0" }
  measure: rmse_eur { type: average sql: ${TABLE}.rmse_eur ;; value_format: "#,##0.0" }
  measure: bias_pct { type: average sql: ${TABLE}.bias_pct ;; value_format: "0.00" }
  measure: coverage_95_pct { type: average sql: ${TABLE}.coverage_95_pct ;; value_format: "0.0" }
  measure: runtime_sec { type: average sql: ${TABLE}.runtime_sec ;; value_format: "0.00" }
}

view: eval_similarity_ablation {
  sql_table_name: `grocery-demo-515014.grocery_serving.v_eval_similarity_ablation` ;;
  dimension: algo_name { primary_key: yes type: string sql: ${TABLE}.algo_name ;; }
  dimension: is_champion { type: yesno sql: ${TABLE}.is_champion ;; }
  measure: cat_precision_at_5_pct { type: average sql: ${TABLE}.cat_precision_at_5_pct ;; value_format: "0.0" }
  measure: subsegment_precision_at_5_pct { type: average sql: ${TABLE}.subsegment_precision_at_5_pct ;; value_format: "0.0" }
  measure: brand_tier_match_at_5_pct { type: average sql: ${TABLE}.brand_tier_match_at_5_pct ;; value_format: "0.0" }
  measure: price_band_match_at_5_pct { type: average sql: ${TABLE}.price_band_match_at_5_pct ;; value_format: "0.0" }
  measure: analog_velocity_mape_pct { type: average sql: ${TABLE}.analog_velocity_mape_pct ;; value_format: "0.0" }
}

view: eval_cold_start_backtest {
  sql_table_name: `grocery-demo-515014.grocery_serving.v_eval_cold_start_backtest` ;;
  dimension: pk { primary_key: yes hidden: yes sql: CONCAT(${granularity}, '_', ${forecast_method}, '_', ${product_id}) ;; }
  dimension: granularity { type: string sql: ${TABLE}.granularity ;; }
  dimension: forecast_method { type: string sql: ${TABLE}.forecast_method ;; }
  dimension: product_id { type: string sql: ${TABLE}.product_id ;; }
  dimension: product_name { type: string sql: ${TABLE}.product_name ;; }
  dimension: category { type: string sql: ${TABLE}.category ;; }

  measure: actual_12wk_units { type: sum sql: ${TABLE}.actual_12wk_units ;; value_format: "#,##0" }
  measure: pred_12wk_units { type: sum sql: ${TABLE}.pred_12wk_units ;; value_format: "#,##0" }
  measure: cumulative_wmape_pct { type: average sql: ${TABLE}.cumulative_wmape_pct ;; value_format: "0.00" }
  measure: regional_rank_spearman { type: average sql: ${TABLE}.regional_rank_spearman ;; value_format: "0.000" }
  measure: top_affiliate_hit_rate_pct { type: average sql: ${TABLE}.top_affiliate_hit_rate_pct ;; value_format: "0.0" }
}

view: eval_persona_models {
  sql_table_name: `grocery-demo-515014.grocery_serving.v_eval_persona_models` ;;
  dimension: approach_id { primary_key: yes type: string sql: ${TABLE}.approach_id ;; }
  dimension: clustering_method { type: string sql: ${TABLE}.clustering_method ;; }
  dimension: model_endpoint { type: string sql: ${TABLE}.model_endpoint ;; }
  dimension: is_champion { type: yesno sql: ${TABLE}.is_champion ;; }
  measure: davies_bouldin_index { type: average sql: ${TABLE}.davies_bouldin_index ;; value_format: "0.000" }
  measure: avg_grounding_score_10 { type: average sql: ${TABLE}.avg_grounding_score_10 ;; value_format: "0.00" }
  measure: composite_quality_10 { type: average sql: ${TABLE}.composite_quality_10 ;; value_format: "0.00" }
  measure: runtime_sec { type: average sql: ${TABLE}.runtime_sec ;; value_format: "0.00" }
}

view: new_product_forecast_by_persona {
  sql_table_name: `grocery-demo-515014.grocery_serving.v_new_product_forecast_by_persona` ;;

  dimension: pk {
    primary_key: yes
    hidden: yes
    sql: CONCAT(${concept_id}, '_', ${affiliate_id}, '_', CAST(${cluster_id} AS STRING), '_', CAST(${launch_week_num} AS STRING)) ;;
  }
  dimension: concept_id { type: string sql: ${TABLE}.concept_id ;; }
  dimension: product_name { type: string sql: ${TABLE}.product_name ;; }
  dimension: brand_tier { type: string sql: ${TABLE}.brand_tier ;; }
  dimension: affiliate_id { type: string sql: ${TABLE}.affiliate_id ;; }
  dimension: affiliate_name { type: string sql: ${TABLE}.affiliate_name ;; }
  dimension: region { type: string sql: ${TABLE}.region ;; }
  dimension: launch_week_num { type: number sql: ${TABLE}.launch_week_num ;; }
  dimension_group: forecast_week {
    type: time
    timeframes: [raw, date, week]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.forecast_week_start ;;
  }
  dimension: cluster_id { type: number sql: ${TABLE}.cluster_id ;; }
  dimension: persona_name { type: string sql: ${TABLE}.persona_name ;; }
  dimension: price_verdict { type: string sql: ${TABLE}.price_verdict ;; }

  measure: total_forecast_units_persona {
    type: sum
    sql: ${TABLE}.forecast_units_persona ;;
    value_format: "#,##0"
  }
  measure: total_forecast_revenue_eur_persona {
    type: sum
    sql: ${TABLE}.forecast_revenue_eur_persona ;;
    value_format: "#,##0"
  }
  measure: total_forecast_margin_eur_persona {
    type: sum
    sql: ${TABLE}.forecast_margin_eur_persona ;;
    value_format: "#,##0"
  }
  measure: avg_willingness_score_10 {
    type: average
    sql: ${TABLE}.willingness_score_10 ;;
    value_format: "0.0"
  }
  measure: avg_buy_probability {
    type: average
    sql: ${TABLE}.buy_probability ;;
    value_format: "0.0%"
  }
  measure: avg_persona_demand_share_pct {
    type: average
    sql: ${TABLE}.persona_demand_share_pct ;;
    value_format: "0.0"
  }
}

view: product_photo_persona_match {
  sql_table_name: `grocery-demo-515014.grocery_serving.v_product_photo_persona_match` ;;

  dimension: pk {
    primary_key: yes
    hidden: yes
    sql: CONCAT(${concept_id}, '_', CAST(${cluster_id} AS STRING)) ;;
  }
  dimension: concept_id { type: string sql: ${TABLE}.concept_id ;; }
  dimension: product_name { type: string sql: ${TABLE}.product_name ;; }
  dimension: packaging_format { type: string sql: ${TABLE}.packaging_format ;; }
  dimension: dominant_colors { type: string sql: ${TABLE}.dominant_colors ;; }
  dimension: detected_visual_badges { type: string sql: ${TABLE}.detected_visual_badges ;; }
  dimension: perceived_price_tier { type: string sql: ${TABLE}.perceived_price_tier ;; }
  dimension: visual_cues_summary { type: string sql: ${TABLE}.visual_cues_summary ;; }
  dimension: best_visual_fit_persona { type: string sql: ${TABLE}.best_visual_fit_persona ;; }
  dimension: visual_mismatch_persona { type: string sql: ${TABLE}.visual_mismatch_persona ;; }
  dimension: top_analog_sku_name { type: string sql: ${TABLE}.top_analog_sku_name ;; }
  dimension: cluster_id { type: number sql: ${TABLE}.cluster_id ;; }
  dimension: persona_name { type: string sql: ${TABLE}.persona_name ;; }
  dimension: photo_impact_direction { type: string sql: ${TABLE}.photo_impact_direction ;; }
  dimension: photo_price_verdict { type: string sql: ${TABLE}.photo_price_verdict ;; }

  measure: shelf_standout_score_10 { type: average sql: ${TABLE}.shelf_standout_score_10 ;; value_format: "0.0" }
  measure: top_analog_photo_sim { type: average sql: ${TABLE}.top_analog_photo_sim ;; value_format: "0.00" }
  measure: top_analog_hybrid_sim { type: average sql: ${TABLE}.top_analog_hybrid_sim ;; value_format: "0.00" }
  measure: photo_willingness_10 { type: average sql: ${TABLE}.photo_willingness_10 ;; value_format: "0.0" }
  measure: text_only_willingness_10 { type: average sql: ${TABLE}.text_only_willingness_10 ;; value_format: "0.0" }
  measure: photo_buy_prob_pct { type: average sql: ${TABLE}.photo_buy_prob_pct ;; value_format: "0.0" }
  measure: delta_buy_prob_pp { type: average sql: ${TABLE}.delta_buy_prob_pp ;; value_format: "+0.0;-0.0;0.0" }
}

view: eval_gemini_models_comparison {
  sql_table_name: `grocery-demo-515014.grocery_serving.v_eval_gemini_models_comparison` ;;

  dimension: model_id { primary_key: yes type: string sql: ${TABLE}.model_id ;; }
  dimension: display_name { type: string sql: ${TABLE}.display_name ;; }
  dimension: model_family { type: string sql: ${TABLE}.model_family ;; }
  dimension: model_tier { type: string sql: ${TABLE}.model_tier ;; }
  dimension: recommended_role { type: string sql: ${TABLE}.recommended_role ;; }
  dimension: eval_order { type: number sql: ${TABLE}.eval_order ;; }

  measure: combined_quality_score { type: average sql: ${TABLE}.combined_quality_score ;; value_format: "0.00" }
  measure: persona_judge_score { type: average sql: ${TABLE}.persona_judge_score ;; value_format: "0.00" }
  measure: vision_judge_score { type: average sql: ${TABLE}.vision_judge_score ;; value_format: "0.00" }
  measure: persona_runtime_sec { type: average sql: ${TABLE}.persona_runtime_sec ;; value_format: "0.0" }
  measure: vision_runtime_sec { type: average sql: ${TABLE}.vision_runtime_sec ;; value_format: "0.0" }
  measure: persona_parse_rate_pct { type: average sql: ${TABLE}.persona_parse_rate_pct ;; value_format: "0.0" }
  measure: vision_parse_rate_pct { type: average sql: ${TABLE}.vision_parse_rate_pct ;; value_format: "0.0" }
  measure: persona_cost_per_1k_rows_usd { type: average sql: ${TABLE}.persona_cost_per_1k_rows_usd ;; value_format: "$#,##0.00" }
  measure: vision_cost_per_1k_rows_usd { type: average sql: ${TABLE}.vision_cost_per_1k_rows_usd ;; value_format: "$#,##0.00" }
}
