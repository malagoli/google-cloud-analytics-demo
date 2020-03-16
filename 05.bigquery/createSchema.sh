#!/bin/sh
PROJECT=customer-demo-267815
DATASET=cdc_realtime
TABLE=customer_address

bq mk --table $PROJECT:$DATASET.$TABLE customer_address.json


