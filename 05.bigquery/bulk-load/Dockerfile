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

FROM openjdk
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz --output /tmp/google-cloud-sdk.tar.gz
   
RUN curl https://github.com/Teradata/tpcds/releases/download/1.2/tpcds-1.2-jar-with-dependencies.jar --output tpcds.jar

RUN mkdir -p /usr/local/gcloud \
  && tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz \
  && /usr/local/gcloud/google-cloud-sdk/install.sh

ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

ENV SCALE 1
ENV GCS_URL SETME
ENV GOOGLE_APPLICATION_CREDENTIALS=/serviceaccount.json
ENV PROJECT SETME
ENV DATASET SETME
ENV PARALLELISM 1

ADD ./create.sh .
ADD ./populate.sh .

CMD ["./create.sh"]
