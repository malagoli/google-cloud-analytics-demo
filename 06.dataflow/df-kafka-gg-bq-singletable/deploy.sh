#!/bin/sh
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



