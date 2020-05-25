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

source ./env.sh
## copy the contrib gcs plugins
git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git
gsutil cp -r ./python-docs-samples/third_party/apache-airflow/plugins/gcs_plugin/ $BUCKET/plugins/gcs_plugin


## copy the data fusion operator
git clone git@github.com:apache/airflow.git

mkdir -p plugins/airflow_next_release/providers/google/cloud/hooks/
mkdir -p plugins/airflow_next_release/providers/google/cloud/operators/
mkdir -p plugins/airflow_next_release/providers/google/cloud/utils/

cp airflow/airflow/providers/google/cloud/hooks/base.py plugins/airflow_next_release/providers/google/cloud/hooks/
cp airflow/airflow/providers/google/cloud/hooks/datafusion.py plugins/airflow_next_release/providers/google/cloud/hooks/
cp airflow/airflow/providers/google/cloud/operators/datafusion.py plugins/airflow_next_release/providers/google/cloud/operators/

sed -i 's/airflow.providers.google.cloud/airflow_next_release.providers.google.cloud/g' ./plugins/airflow_next_release/providers/google/cloud/hooks/base.py
sed -i 's/airflow.providers.google.cloud/airflow_next_release.providers.google.cloud/g' ./plugins/airflow_next_release/providers/google/cloud/hooks/datafusion.py
sed -i 's/airflow.providers.google.cloud/airflow_next_release.providers.google.cloud/g' ./plugins/airflow_next_release/providers/google/cloud/operators/datafusion.py

gsutil cp -r ./plugins/airflow_next_release/ $BUCKET/plugins/
