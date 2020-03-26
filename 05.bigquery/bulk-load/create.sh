#!/bin/sh
set -e

java -jar tpcds.jar --scale $SCALE --parallelism 4

now=$(date "+%Y.%m.%d-%H.%M.%S")

for f in *.dat; do 
    mv -- "$f" "${f%.html}.$now.dat"
done

gcloud auth activate-service-account --key-file /serviceaccount.json
gsutil cp *.dat $GCS_URL
/populate.sh