#!/bin/sh
source ./env.sh

docker build -t composer-client-id .

cwd=$(pwd)
docker run -v $GOOGLE_APPLICATION_CREDENTIALS:/serviceaccount.key.json -v $cwd:/code composer-client-id python /code/get_client_id.py $PROJECT $ZONE $COMPOSER_INSTANCE_NAME
