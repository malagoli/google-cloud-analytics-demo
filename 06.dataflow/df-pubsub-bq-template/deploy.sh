#!/bin/sh
### MODIFY PROJECT AND BUCKET NAME
export PROJECT=##YOUR_PROJECT##
export BUCKET=##TEMPLATE_BUCKET##
###


export TEMPLATE_NAME=strriim-pubsub-bq
export STAGING_LOCATION=$BUCKET/dataflow/staging
export TEMPLATE_LOCATION=$BUCKET/dataflow/templates

    mvn compile exec:java -P dataflow-runner \
     -Dexec.mainClass=com.google.beam.template.StriimPubSubToBQ \
     -Dexec.args="--runner=DataflowRunner \
                  --project=$PROJECT \
                  --stagingLocation=$STAGING_LOCATION \
                  --templateLocation=$TEMPLATE_LOCATION/$TEMPLATE_NAME"

gsutil cp strriim-pubsub-bq_metadata.json $TEMPLATE_LOCATION/${TEMPLATE_NAME}_metadata
