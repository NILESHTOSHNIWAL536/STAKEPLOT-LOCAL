import mongoose, { Schema, Document } from 'mongoose';

/* ============================
   Fips Metric Interface
============================ */

export interface IFipsMetric extends Document {
  timestamp: Date;

  fip_id?: string;
  event_name?: string;

  latency_avg_ms?: number;
  success_percent?: number;
  timeout_percent?: number;
  acc_not_found_percent?: number;
  server_error_percent?: number;
  client_error_percent?: number;

  latencyP99_ms?: number;
  latencyP95_ms?: number;
  latencyP50_ms?: number;
}

/* ============================
   Fips Metric Schema
============================ */

const FipsMetricSchema = new Schema<IFipsMetric>({
  timestamp: {
    type: Date,
    required: true,
  },

  fip_id: {
    type: String,
  },

  event_name: {
    type: String,
  },

  latency_avg_ms: {
    type: Number,
  },

  success_percent: {
    type: Number,
  },

  timeout_percent: {
    type: Number,
  },

  acc_not_found_percent: {
    type: Number,
  },

  server_error_percent: {
    type: Number,
  },

  client_error_percent: {
    type: Number,
  },

  latencyP99_ms: {
    type: Number,
  },

  latencyP95_ms: {
    type: Number,
  },

  latencyP50_ms: {
    type: Number,
  },
});

/* ============================
   Export Model
============================ */

const FipsMetric = mongoose.model<IFipsMetric>('FipsMetric', FipsMetricSchema);
export default FipsMetric;
