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

CREATE OR REPLACE FUNCTION
  `customer-demo-267815.cdc_oracle`.jsMerge (oldString STRING,
    newString STRING)
  RETURNS STRUCT< ERROR STRING,
  SS_SOLD_DATE_SK INT64,
  SS_SOLD_TIME_SK INT64,
  SS_ITEM_SK INT64,
  SS_CUSTOMER_SK INT64,
  SS_CDEMO_SK INT64,
  SS_HDEMO_SK INT64,
  SS_ADDR_SK INT64,
  SS_STORE_SK INT64,
  SS_PROMO_SK INT64,
  SS_TICKET_NUMBER INT64,
  SS_QUANTITY INT64,
  SS_WHOLESALE_COST NUMERIC,
  SS_LIST_PRICE NUMERIC,
  SS_SALES_PRICE NUMERIC,
  SS_EXT_DISCOUNT_AMT NUMERIC,
  SS_EXT_SALES_PRICE NUMERIC,
  SS_EXT_WHOLESALE_COST NUMERIC,
  SS_EXT_LIST_PRICE NUMERIC,
  SS_EXT_TAX NUMERIC,
  SS_COUPON_AMT NUMERIC,
  SS_NET_PAID NUMERIC,
  SS_NET_PAID_INC_TAX NUMERIC,
  SS_NET_PROFIT NUMERIC>
  LANGUAGE js AS '''

   var ret = null;
   
   try {
    if(oldString == null) {
       ret = JSON.parse(newString);
   } else {
    ret = {...JSON.parse(oldString), ...JSON.parse(newString)};
    }
   } catch(e) {
      return {ERROR: e}
   }
   
   return ret;
'''