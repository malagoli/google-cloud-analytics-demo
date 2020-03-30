#!/bin/sh
PROJECT=customer-demo-267815
DATASET=cdc_oracle

bq mk --table $PROJECT:$DATASET.STORE_SALES store_sales.json
bq mk --table $PROJECT:$DATASET.cdc cdc.json

