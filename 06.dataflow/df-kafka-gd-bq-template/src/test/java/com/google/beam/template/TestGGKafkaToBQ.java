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


import com.google.api.services.bigquery.model.TableRow;
import com.google.protobuf.ByteString;
import org.apache.beam.sdk.testing.TestPipeline;
import org.apache.beam.sdk.testing.ValidatesRunner;
import org.junit.Assert;
import org.junit.Rule;
import org.junit.Test;
import org.junit.experimental.categories.Category;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.Map;

@RunWith(JUnit4.class)
public class TestGGKafkaToBQ {

  private static final Logger LOG = LoggerFactory.getLogger(TestGGKafkaToBQ.class);

  private static String message = "\n" +
          "  {\n" +
          "    \"table\":\"QASOURCE.TCUSTORD\",\n" +
          "    \"op_type\":\"U\",\n" +
          "    \"op_ts\":\"2015-11-05 18:45:39.000000\",\n" +
          "    \"current_ts\":\"2016-10-05T10:15:51.310002\",\n" +
          "    \"pos\":\"00000000000000004300\",\n" +
          "    \"before\":{\n" +
          "        \"CUST_CODE\":\"BILL\",\n" +
          "        \"ORDER_DATE\":\"1995-12-31:15:00:00\",\n" +
          "        \"PRODUCT_CODE\":\"CAR\",\n" +
          "        \"ORDER_ID\":765,\n" +
          "        \"PRODUCT_PRICE\":15000.00,\n" +
          "        \"PRODUCT_AMOUNT\":3,\n" +
          "        \"TRANSACTION_ID\":100\n" +
          "    },\n" +
          "    \"after\":{\n" +
          "        \"CUST_CODE\":\"BILL\",\n" +
          "        \"ORDER_DATE\":\"1995-12-31:15:00:00\",\n" +
          "        \"PRODUCT_CODE\":\"CAR\",\n" +
          "        \"ORDER_ID\":765,\n" +
          "        \"PRODUCT_PRICE\":14000.00\n" +
          "    }\n" +
          "}\n" +
          "";

  @Rule public TestPipeline p = TestPipeline.create();

  @Test
  public void GenerateGGElement() {
    ByteString data = ByteString.copyFromUtf8(message);


      GoldenGateElement el = new GoldenGateElement(message, null);

    Assert.assertEquals(el.getOperation(), "U");

    TableRow r = el.getTableRow();
    Assert.assertEquals(r.get("CUST_CODE"), "BILL");

  }

  @Test
  public void GenerateGGElemenWithMetadatat() {

    GoldenGateElement el = new GoldenGateElement(message, "md");

    Assert.assertEquals(el.getOperation(), "U");

    TableRow r = el.getTableRow();
    Assert.assertEquals( "TRANSACTION_ID", r.get(100));
    Assert.assertEquals( "QASOURCE.TCUSTORD", ((Map)r.get("md")).get("TableName"));

  }


  @Test
  @Category(ValidatesRunner.class)
  public void IntegrationTestGGToBQ() throws IOException, InterruptedException {
    GoldenGateKafkaToBQ.GoldenGateKafkaToBQOptions options =
            TestPipeline.testingPipelineOptions().as(GoldenGateKafkaToBQ.GoldenGateKafkaToBQOptions.class);

    String projectId = "customer-demo-267815";
    String topic = "cdc";
    String server = System.getenv("server");
    String key = System.getenv("key");
    String secret = System.getenv("secret");
    String bigQueryDataset = "tpcds_demo";
    String metadataField = "METADATA";
    String schemaReplacer = "QASOURCE";




    options.setOutputDataset( bigQueryDataset);
    options.setBootstrapServer( server  );
    options.setKey( key );
    options.setSecret( secret );
    options.setTopic( topic  );
    options.setOutputProject(projectId);
    options.setSchemaReplacer( schemaReplacer );
    options.setMetadataField( (metadataField) );

    GoldenGateKafkaToBQ s = new GoldenGateKafkaToBQ();
    s.run(options);
  }

}
