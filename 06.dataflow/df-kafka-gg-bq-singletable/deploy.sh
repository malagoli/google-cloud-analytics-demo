#!/bin/sh
export PROJECT="GCP PROJECT"
export OUTPUT_DATASET="cdc_oracle"
export SERVER="KAFKA-BROKER:9092"
export KEY="CONFLUENT KEY"
export SECRET="CONFLUENT SECRET"
export TOPIC="cdc"
export TABLE="cdc"

###

mvn -Pdataflow-runner compile exec:java \
      -Dexec.mainClass=com.google.beam.GoldenGateKafkaToBQ \
      -Dexec.args="--project=$PROJECT \
      --outputTableSpec=$PROJECT:$OUTPUT_DATASET.$TABLE \
      --bootstrapServer=$SERVER \
      --key=$KEY \
      --secret=$SECRET \
      --topic=$TOPIC \
      --runner=DataflowRunner"



