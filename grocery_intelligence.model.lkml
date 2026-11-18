connection: "gam_rda_bq"

include: "/views/*.view.lkml"

label: "Cymbal Grocery Alliance — AI Intelligence"

explore: consortium_sales_forecast {
  label: "01 · Consortium Sales & TimesFM 3.0 Forecast"
  description: "Weekly net sell-out revenue, units, margins, and 12-week TimesFM 3.0 Multivariate forecast across 5 Affiliates (Soci) and 8 categories, joined with Anonymous Group Benchmark."
  from: consortium_sales_forecast
  join: consortium_anonymous_benchmark {
    type: left_outer
    relationship: many_to_one
    sql_on: ${consortium_sales_forecast.week_raw} = ${consortium_anonymous_benchmark.week_raw}
        AND ${consortium_sales_forecast.category} = ${consortium_anonymous_benchmark.category} ;;
  }
}

explore: dynamic_personas {
  label: "02 · Dynamic AI Shopper Personas"
  description: "Half-year evolving behavioral shopper personas (2024-H1 to 2026-H2) across Affiliates and Regions synthesized via BQML K-Means + Gemini 4 Argon."
  from: dynamic_personas
}

explore: new_product_launch {
  label: "03 · New Product Launch Simulator (Pasta)"
  description: "12-week persona-driven cold-start demand forecast across Affiliates for 3 new pasta concepts (C1 Analogy vs C2 Persona vs C3 Hybrid Multimodal + TimesFM 3.0)."
  from: new_product_launch
}

explore: persona_willingness {
  label: "04 · Persona Willingness-to-Buy & Quotes"
  description: "Multimodal Gemini persona evaluations (0-10 willingness score, buy probability, price verdict, drivers, barriers, and verbatim first-person quotes) for new pasta launches."
  from: persona_willingness
}

explore: ml_benchmarks {
  label: "05 · Data Science Model Benchmarks"
  description: "Full BigQuery evaluation pipeline scorecards: 8-model forecasting leaderboard (WMAPE/SMAPE/Bias), 5-algorithm multimodal similarity ablation, and 15-SKU zero-leakage cold-start backtest."
  from: eval_forecasting_models
}

explore: eval_similarity_ablation {
  label: "06 · Multimodal Similarity Ablation"
  from: eval_similarity_ablation
}

explore: eval_cold_start_backtest {
  label: "07 · Cold-Start 15-SKU Backtest"
  from: eval_cold_start_backtest
}

explore: eval_persona_models {
  label: "08 · Gemini Persona Generation Benchmark"
  from: eval_persona_models
}

explore: new_product_forecast_by_persona {
  label: "09 · Per-Persona New Product Launch Forecast"
  description: "12-week sales forecast (units, revenue, margin) decomposed for each of the 6 dynamic AI personas across 3 new pasta launches and 5 Affiliates."
  from: new_product_forecast_by_persona
}

explore: product_photo_persona_match {
  label: "10 · Multimodal Photo Analysis & Persona Match"
  description: "BigQuery AI.GENERATE vision analysis of product packaging photos (ObjectRef), visual similarity to top catalog analogs, and Photo-vs-Text persona match delta."
  from: product_photo_persona_match
}

explore: eval_gemini_models_comparison {
  label: "11 · Gemini 3 vs Gemini 4 Model Comparison"
  description: "Head-to-head BigQuery AI.GENERATE evaluation of all 9 live Gemini 3 & Gemini 4 models (Flash-Lite, Flash, Hydrogen, Argon, Carbon) across Dynamic Personas and Multimodal Packshot Vision."
  from: eval_gemini_models_comparison
}
