/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.google.beam.template;


import com.google.api.core.ApiFuture;
import com.google.api.core.ApiFutureCallback;
import com.google.api.core.ApiFutures;
import com.google.api.gax.rpc.ApiException;
import com.google.api.services.bigquery.model.TableRow;
import com.google.common.util.concurrent.MoreExecutors;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.protobuf.ByteString;


import org.apache.beam.sdk.io.gcp.pubsub.PubsubMessage;
import org.apache.beam.sdk.options.ValueProvider;
import org.apache.beam.sdk.testing.TestPipeline;
import org.apache.beam.sdk.testing.ValidatesRunner;
import org.junit.Assert;
import org.junit.Rule;
import org.junit.Test;
import org.junit.experimental.categories.Category;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;



import com.google.beam.template.StriimPubSubToBQ.StriimPubSubToBQOptions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

@RunWith(JUnit4.class)
public class TestStriimPubSubToBQ {

  private static final Logger LOG = LoggerFactory.getLogger(TestStriimPubSubToBQ.class);

  private static String message = "{\n" +
          "  \"metadata\":{\"TableName\":\"fusion_demo.customer_address\",\"TxnID\":\"3480913975:000001:805484:1583328201000\",\"OperationName\":\"INSERT\",\"TimeStamp\":\"2020-03-04T13:23:57.000Z\"},\n" +
          "  \"data\":{\n" +
          "\"CA_ADDRESS_SK\":1007,\n" +
          "\"CA_ADDRESS_ID\":\"AAAAAAAAPODAAAAA\",\n" +
          "\"CA_STREET_NUMBER\":\"298\",\n" +
          "\"CA_STREET_NAME\":\"Smith\",\n" +
          "\"CA_STREET_TYPE\":\"RD\",\n" +
          "\"CA_SUITE_NUMBER\":\"Suite 490\",\n" +
          "\"CA_CITY\":\"Lakewood\",\n" +
          "\"CA_COUNTY\":\"Johnson County\",\n" +
          "\"CA_STATE\":\"KY\",\n" +
          "\"CA_ZIP\":\"48877\",\n" +
          "\"CA_COUNTRY\":\"United States\",\n" +
          "\"CA_GMT_OFFSET\":\"-6.00\",\n" +
          "\"CA_LOCATION_TYPE\":\"single family\"\n" +
          "},\n" +
          "  \"before\":null,\n" +
          "  \"userdata\":null\n" +
          " }";

  @Rule public TestPipeline p = TestPipeline.create();

  @Test
  public void GenerateStriimElement() {
    ByteString data = ByteString.copyFromUtf8(message);

    PubsubMessage pubsubMessage = new PubsubMessage(data.toByteArray(), null);

      StriimElement el = new StriimElement(pubsubMessage, null);

    Assert.assertEquals(el.getOperation(), "INSERT");

    TableRow r = el.getTableRow();
    Assert.assertEquals(r.get("CA_LOCATION_TYPE"), "single family");

  }

  @Test
  public void GenerateStriimElemenWithMetadatat() {
    ByteString data = ByteString.copyFromUtf8(message);

    PubsubMessage pubsubMessage = new PubsubMessage(data.toByteArray(), null);

    StriimElement el = new StriimElement(pubsubMessage, "md");

    Assert.assertEquals(el.getOperation(), "INSERT");

    TableRow r = el.getTableRow();
    Assert.assertEquals( "single family", r.get("CA_LOCATION_TYPE"));
    Assert.assertEquals( "fusion_demo.customer_address", ((Map)r.get("md")).get("TableName"));

  }


  @Test
  @Category(ValidatesRunner.class)
  public void IntegrationTestStriimPubSubToBQ() throws IOException, InterruptedException {
    StriimPubSubToBQOptions options =
            TestPipeline.testingPipelineOptions().as(StriimPubSubToBQOptions.class);

    String projectId = "fusion-demo-269315";
    //String topicId = "cdc";
    String subscriptionId = "fusion-sub";
    String bigQueryDataset = "cdc";
    String metadataField = "metadata";
    String schemaReplacer = "fusion_demo";

    // fusion-demo-269315
    // projects/fusion-demo-269315/subscriptions/fusion-sub
    String subscriptionValue = "projects/"+ projectId  +"/subscriptions/" + subscriptionId;



    //List<String> messages = Arrays.asList(message);

    //sendToPubSub(messages, projectId, topicId);

    options.setOutputDataset( ValueProvider.StaticValueProvider.of(bigQueryDataset) );
    options.setInputSubscription( ValueProvider.StaticValueProvider.of(subscriptionValue) ) ;
    options.setOutputProject( ValueProvider.StaticValueProvider.of(projectId) );
    options.setSchemaReplacer(ValueProvider.StaticValueProvider.of(schemaReplacer) );
    options.setMetadataField(ValueProvider.StaticValueProvider.of((metadataField)) );

    StriimPubSubToBQ s = new StriimPubSubToBQ();
    s.run(options);
  }

/*
  private static void sendToPubSub(List<String> messages, String projectId, String topicId) throws IOException, InterruptedException {
// send a new message
    ProjectTopicName topicName = ProjectTopicName.of(projectId, topicId);

    Publisher publisher = Publisher.newBuilder(topicName).build();

    for (final String message : messages) {
      ByteString data = ByteString.copyFromUtf8(message);
      PubsubMessage pubsubMessage = PubsubMessage.newBuilder().setData(data).build();

      // Once published, returns a server-assigned message id (unique within the topic)
      ApiFuture<String> future = publisher.publish(pubsubMessage);

      // Add an asynchronous callback to handle success / failure
      ApiFutures.addCallback(
              future,
              new ApiFutureCallback<String>() {

                @Override
                public void onFailure(Throwable throwable) {
                  if (throwable instanceof ApiException) {
                    ApiException apiException = ((ApiException) throwable);
                    // details on the API exception
                    System.out.println(apiException.getStatusCode().getCode());
                    System.out.println(apiException.isRetryable());
                  }
                  System.out.println("Error publishing message : " + message);
                }

                @Override
                public void onSuccess(String messageId) {
                  // Once published, returns server-assigned message ids (unique within the topic)
                  System.out.println(messageId);
                }
              },
              MoreExecutors.directExecutor());
    }

    if (publisher != null) {
      // When finished with the publisher, shutdown to free up resources.
      publisher.shutdown();
      publisher.awaitTermination(1, TimeUnit.MINUTES);
    }
  }

 */
}
