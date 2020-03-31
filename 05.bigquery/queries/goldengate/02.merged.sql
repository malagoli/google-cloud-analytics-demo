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
  `customer-demo-267815.cdc_oracle.view_cdc_merged_store_sales` AS
SELECT
  data.SS_SOLD_DATE_SK,
  data.SS_SOLD_TIME_SK,
  data.SS_ITEM_SK,
  data.SS_CUSTOMER_SK,
  data.SS_CDEMO_SK,
  data.SS_HDEMO_SK,
  data.SS_ADDR_SK,
  data.SS_STORE_SK,
  data.SS_PROMO_SK,
  data.SS_TICKET_NUMBER,
  data.SS_QUANTITY,
  data.SS_WHOLESALE_COST,
  data.SS_LIST_PRICE,
  data.SS_SALES_PRICE,
  data.SS_EXT_DISCOUNT_AMT,
  data.SS_EXT_SALES_PRICE,
  data.SS_EXT_WHOLESALE_COST,
  data.SS_EXT_LIST_PRICE,
  data.SS_EXT_TAX,
  data.SS_COUPON_AMT,
  data.SS_NET_PAID,
  data.SS_NET_PAID_INC_TAX,
  data.SS_NET_PROFIT,
  MD_key,
  MD_op_ts,
  MD_current_ts,
  MD_pos,
  MD_op_type
FROM
  `customer-demo-267815.cdc_oracle.view_cdc_store_sales`
UNION ALL
SELECT
  SS_SOLD_DATE_SK,
  SS_SOLD_TIME_SK,
  SS_ITEM_SK,
  SS_CUSTOMER_SK,
  SS_CDEMO_SK,
  SS_HDEMO_SK,
  SS_ADDR_SK,
  SS_STORE_SK,
  SS_PROMO_SK,
  SS_TICKET_NUMBER,
  SS_QUANTITY,
  SS_WHOLESALE_COST,
  SS_LIST_PRICE,
  SS_SALES_PRICE,
  SS_EXT_DISCOUNT_AMT,
  SS_EXT_SALES_PRICE,
  SS_EXT_WHOLESALE_COST,
  SS_EXT_LIST_PRICE,
  SS_EXT_TAX,
  SS_COUPON_AMT,
  SS_NET_PAID,
  SS_NET_PAID_INC_TAX,
  SS_NET_PROFIT,
  NULL AS MD_key,
  '1900-01-01' AS MD_op_ts,
  '1900-01-01' AS MD_current_ts,
  '' AS MD_pos,
  'I' AS MD_op_type
FROM
  `customer-demo-267815.tpcds_full.store_sales`