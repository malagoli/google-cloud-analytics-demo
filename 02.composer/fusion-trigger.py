import datetime

import airflow
from airflow.operators                   import bash_operator
from gcs_plugin.operators.gcs_to_gcs     import GoogleCloudStorageToGoogleCloudStorageOperator
from airflow_next_release.providers.google.cloud.operators.datafusion import CloudDataFusionStartPipelineOperator
from airflow.contrib.sensors.gcs_sensor  import GoogleCloudStorageObjectSensor

LOCATION = "us-west1"
INSTANCE_NAME = "myfusioninstance"
INSTANCE = {"type": "ENTERPRISE", "displayName": INSTANCE_NAME}
PIPELINE_NAME = "MYPIPELINE"

default_args = {
    'owner': 'Composer DataFusion Trigger',
    'depends_on_past': False,
    'email': [],
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': datetime.timedelta(minutes=5),
    'start_date': datetime.datetime(2020, 1, 1),
}

with airflow.DAG(
        'datafusion-file-ingestion',
        default_args=default_args,
        # Not scheduled, trigger only
        schedule_interval=None) as dag:
    
    rename = GoogleCloudStorageToGoogleCloudStorageOperator(
        task_id='staging_file',
        source_bucket='{{ dag_run.conf["bucket"] }}',
        source_object='{{ dag_run.conf["name"] }}',
        destination_bucket='{{ dag_run.conf["bucket"] }}',
        destination_object='{{ dag_run.conf["name"].replace("source", "staging") }}',
        move_object=True
    )


    start_pipeline = CloudDataFusionStartPipelineOperator(
        location=LOCATION,
        pipeline_name=PIPELINE_NAME,
        instance_name=INSTANCE_NAME,
        task_id="start_pipeline",
        runtime_args={"bucket": '{{ dag_run.conf["bucket"] }}', "sourcePath": '{{ dag_run.conf["name"].replace("source", "staging") }}', "destinationPath": '{{ dag_run.conf["name"].replace("source", "done") }}' }
        #runtime_args='{"bucket": "{{ dag_run.conf["bucket"] }}", "sourcePath": "{{ dag_run.conf["name"].replace("source", "staging") }}", "destinationPath":"{{ dag_run.conf["name"].replace("source", "done") }}" }'
        )
    

    gcs_file_sensor = GoogleCloudStorageObjectSensor(task_id='gcs_file_sensor_task',
        bucket='{{ dag_run.conf["bucket"] }}',
        object='{{ dag_run.conf["name"].replace("source", "done")  }}',
        google_cloud_conn_id='google_cloud_storage_default')


rename >> start_pipeline >> gcs_file_sensor

