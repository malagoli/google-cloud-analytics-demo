-- CREATE A TABLE FROM THE GENERIC GOLDEN GATE MESSAGE

CREATE OR REPLACE VIEW `customer-demo-267815.cdc_oracle.view_cdc_store_sales`
AS 
SELECT
  `customer-demo-267815.cdc_oracle`.jsMerge(before, after),
  key AS MD_key,
  op_ts AS MD_op_ts,
  current_ts AS MD_current_ts,
  pos AS MD_pos,
  op_type AS MD_op_type
FROM
  `customer-demo-267815.cdc_oracle.cdc`
WHERE
  table = 'CDC.STORE_SALES'
