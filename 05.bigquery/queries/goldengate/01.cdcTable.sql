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
