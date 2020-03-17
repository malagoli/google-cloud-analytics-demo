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
import org.apache.beam.sdk.io.gcp.pubsub.PubsubIO;
import org.apache.beam.sdk.io.gcp.pubsub.PubsubMessage;
import org.apache.beam.sdk.options.Description;
import org.apache.beam.sdk.options.PipelineOptions;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.options.ValueProvider;
import org.apache.beam.sdk.transforms.DoFn;
import org.apache.beam.sdk.transforms.ParDo;
import org.apache.beam.sdk.values.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.Serializable;


public class StriimPubSubToBQ {

    /**
     * The log to output status messages to.
     */
    private static final Logger LOG = LoggerFactory.getLogger(StriimPubSubToBQ.class);



    /**
     * The {@link StriimPubSubToBQOptions} class provides the custom execution options passed by the executor at the
     * command-line.
     */
    public interface StriimPubSubToBQOptions extends PipelineOptions {
        @Description("BigQuery Project to write the output to")
        ValueProvider<String> getOutputProject();

        void setOutputProject(ValueProvider<String> value);

        @Description("BigQuery Dataset to write the output to")
        ValueProvider<String> getOutputDataset();

        void setOutputDataset(ValueProvider<String> value);


        @Description(
                "The Cloud Pub/Sub subscription to consume from. "
                        + "The name should be in the format of "
                        + "projects/<project-id>/subscriptions/<subscription-name>.")
        ValueProvider<String> getInputSubscription();

        void setInputSubscription(ValueProvider<String> value);

        @Description(
                "If specified the value will be deleted from destination table. E.g. if 'myschema' is specified and the source table is 'myschema.mytable' the output table name will by mytable")
        ValueProvider<String> getSchemaReplacer();

        void setSchemaReplacer(ValueProvider<String> value);

        @Description("If specified is the field where the Striim metadata will be saved")
        ValueProvider<String> getMetadataField();
        void setMetadataField(ValueProvider<String> value);


    }

    /**
     * The main entry-point for pipeline execution. This method will start the pipeline but will not
     * wait for it's execution to finish. If blocking execution is required, use the {@link
     * StriimPubSubToBQ#run(StriimPubSubToBQOptions)} method to start the pipeline and invoke {@code
     * result.waitUntilFinish()} on the {@link PipelineResult}.
     *
     * @param args The command-line args passed by the executor.
     */
    public static void main(String[] args) {
        StriimPubSubToBQOptions options = PipelineOptionsFactory.fromArgs(args).withValidation().as(StriimPubSubToBQOptions.class);

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
    public static PipelineResult run(StriimPubSubToBQOptions options) {

        //TupleTag<TableRow> MAIN_OUT = new TupleTag<TableRow>();
        //TupleTag<TableRow> DEADLETTER_OUT = new TupleTag<TableRow>();

        // Create the pipeline
        Pipeline pipeline = Pipeline.create(options);

        ValueProvider<String> outputDataset = options.getOutputDataset();
        ValueProvider<String> outputProject = options.getOutputProject();
        ValueProvider<String> schemaReplacer = options.getSchemaReplacer();
        ValueProvider<String> metadataField = options.getMetadataField();

        // Build & execute pipeline
        PCollection<TableRow> apply = pipeline
                .apply(
                        "ReadMessages",
                        PubsubIO.readMessages().fromSubscription(options.getInputSubscription()))
                .apply("ConvertToStriimMessage", ParDo.of(new PubsubMessageToStriimElementFn(metadataField)))
                .apply(
                        "WriteToBigQuery",
                        BigQueryIO.<StriimElement>write()
                                .withExtendedErrorInfo()
                                .to(
                                        input ->
                                                getTableDestination(
                                                        input, outputProject.get(),
                                                        outputDataset.get(), schemaReplacer.get()))
                                .withFormatFunction(
                                        (StriimElement msg) -> msg.getTableRow())
                                .withCreateDisposition(CreateDisposition.CREATE_NEVER)
                                .withWriteDisposition(WriteDisposition.WRITE_APPEND))
                .getFailedInsertsWithErr()
                .apply("BQ-ErrorLogger", ParDo.of(new BigQueryErrorLogger()));
        return pipeline.run();
    }

    static TableDestination getTableDestination(
            ValueInSingleWindow<StriimElement> value,
            String outputProject,
            String outputDataset,
            String schemaReplacer) {

        TableDestination destination;
        if (value != null) {
            StriimElement el = value.getValue();

            String tableName = el.getTableName();
            if(schemaReplacer != null) {
                tableName = tableName.replace(schemaReplacer+".", "");
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


    static class PubsubMessageToStriimElementFn
            extends DoFn<PubsubMessage, StriimElement>  {


        ValueProvider<String> metadataField;

        PubsubMessageToStriimElementFn(ValueProvider<String> metadataField) {
            this.metadataField = metadataField;
        }


        @ProcessElement
        public void processElement(ProcessContext context) {
            StriimElement el =  new StriimElement(context.element(), metadataField.get());
            if(el.getTableName() != null) {
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