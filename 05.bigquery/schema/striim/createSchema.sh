#!/bin/sh
PROJECT=customer-demo-267815
DATASET=cdc_realtime

bq mk --table $PROJECT:$DATASET.customer_address customer_address.json


