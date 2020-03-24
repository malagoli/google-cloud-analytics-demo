package com.google.beam.template;


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


import com.google.api.services.bigquery.model.TableRow;

import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.PipelineResult;
import org.apache.beam.sdk.io.gcp.bigquery.*;
import org.apache.beam.sdk.io.gcp.bigquery.BigQueryIO.Write.CreateDisposition;
import org.apache.beam.sdk.io.gcp.bigquery.BigQueryIO.Write.WriteDisposition;
import org.apache.beam.sdk.io.kafka.KafkaIO;
import org.apache.beam.sdk.options.Description;
import org.apache.beam.sdk.options.PipelineOptions;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.transforms.DoFn;
import org.apache.beam.sdk.transforms.ParDo;
import org.apache.beam.sdk.transforms.Values;
import org.apache.beam.sdk.values.KV;
import org.apache.beam.sdk.values.PCollection;
import org.apache.beam.sdk.values.ValueInSingleWindow;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.Map;

import org.apache.kafka.common.serialization.LongDeserializer;
import org.apache.kafka.common.serialization.StringDeserializer;


public class GoldenGateKafkaToBQ {

    /**
     * The log to output status messages to.
     */
    private static final Logger LOG = LoggerFactory.getLogger(GoldenGateKafkaToBQ.class);


    /**
     * The {@link GoldenGateKafkaToBQOptions} class provides the custom execution options passed by the executor at the
     * command-line.
     */
    public interface GoldenGateKafkaToBQOptions extends PipelineOptions {
        @Description("BigQuery Project to write the output to")
        String getOutputProject();

        void setOutputProject(String value);

        @Description("BigQuery Dataset to write the output to")
        String getOutputDataset();

        void setOutputDataset(String value);


        @Description("The Kafka topic to consume from. ")
        String getTopic();

        void setTopic(String value);

        @Description("The Kafka Bootstrap server e.g. broker_1:9092,broker_2:9092 ")
        String getBootstrapServer();

        void setBootstrapServer(String value);


        @Description("The Confluent Kafka KEY")
        String getKey();

        void setKey(String value);

        @Description("The Confluent Kafka SECRET")
        String getSecret();

        void setSecret(String value);


        @Description(
                "If specified the value will be deleted from destination table. E.g. if 'myschema' is specified and the source table is 'myschema.mytable' the output table name will by mytable")
        String getSchemaReplacer();

        void setSchemaReplacer(String value);

        @Description("If specified is the field where the Striim metadata will be saved")
        String getMetadataField();

        void setMetadataField( String value);


    }

    /**
     * The main entry-point for pipeline execution. This method will start the pipeline but will not
     * wait for it's execution to finish. If blocking execution is required, use the {@link
     * GoldenGateKafkaToBQ#run(GoldenGateKafkaToBQOptions)} method to start the pipeline and invoke {@code
     * result.waitUntilFinish()} on the {@link PipelineResult}.
     *
     * @param args The command-line args passed by the executor.
     */
    public static void main(String[] args) {
        GoldenGateKafkaToBQOptions options = PipelineOptionsFactory.fromArgs(args).withValidation().as(GoldenGateKafkaToBQOptions.class);

        run(options);
    }

    /**
     * Runs the pipeline to completion with the specified options. This method does not wait until the
     * pipeline is finished before returning. Invoke {@code result.waitUntilFinish()} on the result
     * object to block until the pipeline is finished running if blocking programmatic execution is
     * required.
     *
     * @param options The execution options.
     * @return The pipeline result.
     */
    public static PipelineResult run(GoldenGateKafkaToBQOptions options) {

        //TupleTag<TableRow> MAIN_OUT = new TupleTag<TableRow>();
        //TupleTag<TableRow> DEADLETTER_OUT = new TupleTag<TableRow>();

        // Create the pipeline
        Pipeline pipeline = Pipeline.create(options);


        String server = options.getBootstrapServer();
        String key = options.getKey();
        String secret = options.getSecret();
        String topic = options.getTopic();
        String metadataField = options.getMetadataField();
        String schemaReplacer = options.getSchemaReplacer();
        String outputDataset = options.getOutputDataset();
        String outputProject = options.getOutputProject();

        LOG.info("Server ["+server+"] topic ["+topic+"] metadataField ["+metadataField+"] schemaRep ["+schemaReplacer+"] dataset ["+outputDataset+"] project ["+outputProject+"]");

        // Build & execute pipeline
        PCollection<String> messages = pipeline
                .apply(

                        "ReadMessages",
                        KafkaIO.<Long, String>read()
                                .withBootstrapServers(server)
                                .withTopic(topic)
                                .withKeyDeserializer(LongDeserializer.class)
                                .withValueDeserializer(StringDeserializer.class)
                                .withConsumerConfigUpdates(propBuilder(key, secret))
                .withoutMetadata())
                .apply(Values.<String>create());


        messages.apply("ConvertToGoldenGateMessage", ParDo.of(new KafkaMessageToGoldenGatelementFn(metadataField)))
                                .apply(
                                        "WriteToBigQuery",
                                        BigQueryIO.<GoldenGateElement>write()
                                                .withExtendedErrorInfo()
                                                .to(
                                                        input ->
                                                                getTableDestination(
                                                                        input, outputProject,
                                                                       outputDataset, schemaReplacer))
                                                .withFormatFunction(
                                                        (GoldenGateElement msg) -> msg.getTableRow())
                                                .withCreateDisposition(CreateDisposition.CREATE_NEVER)
                                                .withWriteDisposition(WriteDisposition.WRITE_APPEND))
                                .getFailedInsertsWithErr()
                                .apply("BQ-ErrorLogger", ParDo.of(new BigQueryErrorLogger()));
        return pipeline.run();
    }

    private static Map<String, Object> propBuilder(String key, String secret){
        Map<String, Object> props = new HashMap<>();

        props.put("ssl.endpoint.identification.algorithm", "https");
        props.put("sasl.mechanism", "PLAIN");
        props.put("sasl.jaas.config", "org.apache.kafka.common.security.plain.PlainLoginModule required username=\"" + key + "\" password=\"" + secret + "\";");
        props.put("security.protocol", "SASL_SSL");
        //props.put("request.timeout.ms", 20000);
        //props.put("retry.backoff.ms", 500);

        return props;
    }

    static TableDestination getTableDestination(
            ValueInSingleWindow<GoldenGateElement> value,
            String outputProject,
            String outputDataset,
            String schemaReplacer) {

        TableDestination destination;
        if (value != null) {
            GoldenGateElement el = value.getValue();

            String tableName = el.getTableName();
            if (schemaReplacer != null) {
                tableName = tableName.replace(schemaReplacer + ".", "");
            }

            destination =
                    new TableDestination(
                            String.format(
                                    "%s:%s.%s",
                                    outputProject, outputDataset, tableName),
                            null);

        } else {
            throw new RuntimeException(
                    "Cannot retrieve the dynamic table destination of an null message!");
        }

        return destination;
    }


    static class KafkaMessageToGoldenGatelementFn
            extends DoFn<String, GoldenGateElement> {


        String metadataField;

        KafkaMessageToGoldenGatelementFn(String metadataField) {
            this.metadataField = metadataField;
        }


        @ProcessElement
        public void processElement(ProcessContext context) {
            GoldenGateElement el = new GoldenGateElement(context.element(), metadataField);
            if (el.getTableName() != null) {
                context.output(el);
            }
        }
    }

    static class BigQueryErrorLogger extends DoFn<BigQueryInsertError, TableRow> {
        @ProcessElement
        public void processElement(ProcessContext context) {
            BigQueryInsertError e = context.element();
            LOG.error(e.getError().toString());
            LOG.error(e.getRow().toString());
            LOG.error(e.getTable().toString());

            context.output(context.element().getRow());
        }

    }


}