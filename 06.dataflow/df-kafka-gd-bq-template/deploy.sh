#!/bin/sh
### MODIFY PROJECT AND BUCKET NAME
export PROJECT=##YOUR_PROJECT##
export BUCKET=##TEMPLATE_BUCKET##
###

export TEMPLATE_NAME=gg-kafka-bq
export STAGING_LOCATION=$BUCKET/dataflow/staging
export OUTPUT_LOCATION=$BUCKET/dataflow/output

mvn -Pdataflow-runner compile exec:java \
      -Dexec.mainClass=com.google.beam.template.GoldenGateKafkaToBQ \
      -Dexec.args="--project=$PROJECT \
      --stagingLocation=$STAGING_LOCATION \
      --output=$OUTPUT_LOCATION \
      --runner=DataflowRunner"


