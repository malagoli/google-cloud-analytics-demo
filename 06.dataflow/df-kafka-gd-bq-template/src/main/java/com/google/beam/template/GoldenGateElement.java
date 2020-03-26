/*
 * Copyright (C) 2018 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

package com.google.beam.template;

import com.google.api.services.bigquery.model.TableRow;
import com.google.common.base.MoreObjects;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.annotations.SerializedName;
import org.apache.beam.sdk.coders.AvroCoder;
import org.apache.beam.sdk.coders.Coder;
import org.apache.beam.sdk.coders.DefaultCoder;
import org.apache.beam.sdk.io.gcp.bigquery.TableRowJsonCoder;
import org.apache.beam.sdk.io.gcp.pubsub.PubsubMessage;
import org.apache.beam.sdk.io.kafka.KafkaRecord;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.Serializable;
import java.nio.charset.StandardCharsets;
import java.util.Objects;

/**
 * The {@link GoldenGateElement} class holds the current value and original value of a record within a
 * pipeline. This class allows pipelines to not lose valuable information about an incoming record
 * throughout the processing of that record. The use of this class allows for more robust
 * dead-letter strategies as the original record information is not lost throughout the pipeline and
 * can be output to a dead-letter in the event of a failure during one of the pipelines transforms.
 */

@DefaultCoder(AvroCoder.class)
public class GoldenGateElement implements Serializable {

  private static final Logger LOG = LoggerFactory.getLogger(GoldenGateElement.class);

  @SerializedName("jsonData")
  private String jsonData;

  @SerializedName("metadata")
  private GoldenGateMetadata metadata;

  private String metadataField;

  public GoldenGateElement(

  ){
    this.metadata = new GoldenGateMetadata();

  };



  public GoldenGateElement(String payload, String metadataField)  {

    this.metadataField = metadataField;

    try{
      JsonObject jsonObject = new JsonParser().parse(payload).getAsJsonObject();
      JsonObject data = jsonObject.get("after").getAsJsonObject();

      this.metadata = new GoldenGateMetadata();

      if(jsonObject.get("table") != null ) {
        this.metadata.setTableName( jsonObject.get("table").getAsString() );
      }
      this.metadata.setOperation( jsonObject.get("op_type").getAsString() );


      this.metadata.setCurrent_ts( jsonObject.get("current_ts").getAsString() );
      this.metadata.setPos( jsonObject.get("pos").getAsString() );
      this.metadata.setOp_ts( jsonObject.get("op_ts").getAsString() );
      if(jsonObject.get("before") != null) {
        this.metadata.setJsonBefore( jsonObject.get("before").getAsJsonObject().toString());
      }

      data.add(metadataField, this.metadata.getAsJson());
      jsonData = data.toString();

    } catch(Exception e) {
      e.printStackTrace();
      LOG.error(e.toString());
      throw(e);

    }

  }


  public String getTableName() {
    return metadata.getTableName();
  }
  public String getOperation() {
    return metadata.getOperation();
  }

  public TableRow getTableRow() {
     return convertJsonToTableRow(this.jsonData);
  }
  public void setTableName(String tableName) {
    this.metadata.setTableName( tableName );
  }

  public void setOperation(String operation) {
    this.metadata.setOperation( operation );
  }

  public void setJsonData(String jsonData) {
    this.jsonData = jsonData;
  }

  public static TableRow convertJsonToTableRow(String json) {
    TableRow row;
    // Parse the JSON into a {@link TableRow} object.
    try (InputStream inputStream =
                 new ByteArrayInputStream(json.getBytes(StandardCharsets.UTF_8))) {
      row = TableRowJsonCoder.of().decode(inputStream, Coder.Context.OUTER);
    } catch (IOException e) {
      throw new RuntimeException("Failed to serialize json to table row: " + json, e);
    }

    return row;
  }

  @Override
  public boolean equals(Object obj) {
    if (this == obj) {
      return true;
    }
    if (obj == null || getClass() != obj.getClass()) {
      return false;
    }

    final GoldenGateElement other = (GoldenGateElement) obj;
    return Objects.deepEquals(this.metadata.getTableName(), other.getTableName())
            && Objects.deepEquals(this.metadata.getOperation(), other.getOperation());

  }

  @Override
  public int hashCode() {
    return Objects.hash(this.metadata.getPos());
  }

  @Override
  public String toString() {
    return MoreObjects.toStringHelper(this)
            .add("tableName", this.metadata.getPos())
        .toString();
  }
}
