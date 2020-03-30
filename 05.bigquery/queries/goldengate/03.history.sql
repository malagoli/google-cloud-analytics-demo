CREATE OR REPLACE VIEW
  `customer-demo-267815.cdc_oracle.view_history_store_sales` AS
SELECT
  *,
  IFNULL(LAG(MD_op_ts) OVER (PARTITION BY SS_ITEM_SK, SS_TICKET_NUMBER ORDER BY MD_OP_TS ASC), MD_op_ts) AS validity_start,
  LEAD(MD_op_ts) OVER (PARTITION BY SS_ITEM_SK, SS_TICKET_NUMBER ORDER BY MD_OP_TS ASC) AS validity_end,
  CASE
    WHEN MD_op_type='D' THEN TRUE
  ELSE
  FALSE
END
  AS deleted
FROM
  `customer-demo-267815.cdc_oracle.view_cdc_merged_store_sales`
ORDER BY
  MD_op_ts ASC
