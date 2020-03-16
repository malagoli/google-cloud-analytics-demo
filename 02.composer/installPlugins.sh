#!/bin/sh
source ./env.sh
## copy the contrib gcs plugins
git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git
gsutil cp -r ./python-docs-samples/third_party/apache-airflow/plugins/gcs_plugin/ $BUCKET/plugins/gcs_plugin


## copy the data fusion operator
git clone git@github.com:malagoli/airflow.git

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
