#!/bin/bash
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Load into BQ

### IMPORTANT
### this files has to be created with official dsdgen generator with "-update" flag

set -e

bq --project_id=${PROJECT} load --field_delimiter '|' --null_marker '' --ignore_unknown_values ${DATASET}.s_call_center ${GCS_URL}/s_call_center* \
call_center_id:string,\
call_open_date:string,\
call_closed_date:string,\
call_center_name:string,\
call_center_class:string,\
call_center_employees:integer,\
call_center_sq_ft:integer,\
call_center_hours:string,\
call_center_manager:string,
call_center_tax_percentage:float

bq --project_id=${PROJECT} load --field_delimiter '|' --null_marker '' --ignore_unknown_values ${DATASET}.s_purchase ${GCS_URL}/s_purchase* \
purc_purchase_id:integer,\
purc_store_id:string,\
purc_customer_id:string,\
purc_purchase_date:string,\
purc_purchase_time:integer,\
purc_register_id:integer,\
purc_clerk_id:integer,\
purc_comment:string,\

bq --project_id=${PROJECT} load --field_delimiter '|' --null_marker '' --ignore_unknown_values ${DATASET}.s_purchase_lineitem ${GCS_URL}/s_purchase_lineitem* \
plin_purchase_id:integer,\
plin_line_number:integer,\
plin_item_id:string,\
plin_promotion_id:string,\
plin_quantity:integer,\
plin_sale_price:float,\
plin_coupon_amt:float,\
plin_comment:string

