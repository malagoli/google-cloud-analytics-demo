-- Copyright 2020 Google LLC
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

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
