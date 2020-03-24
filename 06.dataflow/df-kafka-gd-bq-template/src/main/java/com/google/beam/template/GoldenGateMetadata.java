package com.google.beam.template;

import com.google.gson.JsonObject;

public class GoldenGateMetadata {

     private String op_ts;
     private String current_ts;
     private String pos;
     private String jsonBefore;
     private String tableName;


    private String operation;


     public void GoldenGateMetadata() {

     }

     public JsonObject getAsJson() {
         JsonObject jsonObject = new JsonObject();
         jsonObject.addProperty("current_ts", this.getCurrent_ts());
         jsonObject.addProperty("pos", this.getPos());
         jsonObject.addProperty("before", this.getJsonBefore());
         jsonObject.addProperty("tableName", this.getTableName());
         jsonObject.addProperty("operation", this.getOperation());
         jsonObject.addProperty("op_ts", this.getOp_ts());

         return jsonObject;
     }

    public String getOp_ts() {
        return op_ts;
    }

    public void setOp_ts(String op_ts) {
        this.op_ts = op_ts;
    }

    public String getCurrent_ts() {
        return current_ts;
    }

    public void setCurrent_ts(String current_ts) {
        this.current_ts = current_ts;
    }

    public String getPos() {
        return pos;
    }

    public void setPos(String pos) {
        this.pos = pos;
    }

    public String getJsonBefore() {
        return jsonBefore;
    }

    public void setJsonBefore(String before) {
        this.jsonBefore = before;
    }

    public String getTableName() {
        return tableName;
    }

    public void setTableName(String tableName) {
        this.tableName = tableName;
    }

    public String getOperation() {
        return operation;
    }

    public void setOperation(String operation) {
        this.operation = operation;
    }

}
