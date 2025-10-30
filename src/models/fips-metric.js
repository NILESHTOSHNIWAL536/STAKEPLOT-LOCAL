// models/FipsMetric.js
const mongoose = require("mongoose");

const FipsMetricSchema = new mongoose.Schema(
    {
      timestamp: { type: Date, required: true },
      fip_id: String,
      event_name: String,
      latency_avg_ms: Number,
      success_percent: Number,
      timeout_percent: Number,
      acc_not_found_percent: Number,
      server_error_percent: Number,
      client_error_percent: Number,
      latencyP99_ms: Number,
      latencyP95_ms: Number,
      latencyP50_ms: Number,
  }
);

module.exports = mongoose.model("FipsMetric", FipsMetricSchema);
