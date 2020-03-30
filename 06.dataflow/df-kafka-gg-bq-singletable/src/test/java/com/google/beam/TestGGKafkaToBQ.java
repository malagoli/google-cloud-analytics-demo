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
package com.google.beam;


import org.apache.beam.sdk.testing.TestPipeline;
import org.apache.beam.sdk.testing.ValidatesRunner;

import org.junit.Test;
import org.junit.experimental.categories.Category;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;

@RunWith(JUnit4.class)
public class TestGGKafkaToBQ {

  private static final Logger LOG = LoggerFactory.getLogger(TestGGKafkaToBQ.class);


  @Test
  @Category(ValidatesRunner.class)
  public void IntegrationTestGGToBQ() throws IOException, InterruptedException {
    GoldenGateKafkaToBQ.GoldenGateKafkaToBQOptions options =
            TestPipeline.testingPipelineOptions().as(GoldenGateKafkaToBQ.GoldenGateKafkaToBQOptions.class);

    String projectId = "customer-demo-267815";
    String topic = "cdc";
    String server = System.getenv("SERVER");
    String key = System.getenv("KEY");
    String secret = System.getenv("SECRET");
    String bigQueryDataset = "cdc_oracle";
    String bigQueryTable = "cdc";


    options.setOutputTableSpec( projectId + ":" + bigQueryDataset + "." + bigQueryTable);
    options.setBootstrapServer( server  );
    options.setKey( key );
    options.setSecret( secret );
    options.setTopic( topic  );

    GoldenGateKafkaToBQ s = new GoldenGateKafkaToBQ();
    s.run(options);
  }

}
