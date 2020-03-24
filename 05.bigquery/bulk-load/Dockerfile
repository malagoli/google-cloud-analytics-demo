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

ADD ./create.sh .
ADD ./populate.sh .

CMD ["./create.sh"]
