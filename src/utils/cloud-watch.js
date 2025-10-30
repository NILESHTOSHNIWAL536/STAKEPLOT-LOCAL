const {
  CloudWatchClient,
  PutMetricDataCommand
} = require('@aws-sdk/client-cloudwatch');

const {
  CloudWatchLogsClient,
  CreateLogGroupCommand,
  CreateLogStreamCommand,
  PutLogEventsCommand
} = require('@aws-sdk/client-cloudwatch-logs');

const logger = require("../utils/common/logger");

const REGION = process.env.AWS_REGION;
const logGroupName = 'Mobile-Server-Logs';
const logStreamName = `mobile-server-${new Date().toISOString().split("T")[0]}`;

const cloudwatch = new CloudWatchClient({ region: REGION });
const cloudwatchlogs = new CloudWatchLogsClient({ region: REGION });

// Check if the environment is production
const isProduction = process.env.NODE_ENV === 'production';

async function initCloudWatchLogs() {
  if (!isProduction) {
    logger.debug('Skipping CloudWatch Logs initialization in non-production environment');
    return;
  }

  try {
    await cloudwatchlogs.send(new CreateLogGroupCommand({ logGroupName }));
  } catch (err) {
    if (err.name !== 'ResourceAlreadyExistsException') {
      console.error('Error creating log group:', err);
    }
  }

  try {
    await cloudwatchlogs.send(new CreateLogStreamCommand({ logGroupName, logStreamName }));
  } catch (err) {
    if (err.name !== 'ResourceAlreadyExistsException') {
      console.error('Error creating log stream:', err);
    }
  }
}

async function sendMetric(path, method, statusCode) {
  if (!isProduction) {
    return;
  }

  const callCommand = new PutMetricDataCommand({
    Namespace: 'Mobile-Server/APIMetrics',
    MetricData: [
      {
        MetricName: 'APICallCount',
        Dimensions: [
          { Name: 'Endpoint', Value: path },
          { Name: 'Method', Value: method }
        ],
        Unit: 'Count',
        Value: 1
      }
    ]
  });

  let failureCommand;
  if (statusCode >= 400) {
    failureCommand = new PutMetricDataCommand({
      Namespace: 'Mobile-Server/APIMetrics',
      MetricData: [
        {
          MetricName: 'APIFailureCount',
          Dimensions: [
            { Name: 'Endpoint', Value: path },
            { Name: 'Method', Value: method },
            { Name: 'StatusCode', Value: statusCode.toString() }
          ],
          Unit: 'Count',
          Value: 1
        }
      ]
    });
  }

  try {
    const commands = [cloudwatch.send(callCommand)];
    if (failureCommand) {
      commands.push(cloudwatch.send(failureCommand));
    }
    await Promise.all(commands);
  } catch (err) {
    console.error('Error sending metric:', err);
  }
}

async function logRequest({ method, path, duration, statusCode, ip }) {
  if (!isProduction) {
    return;
  }

  await sendMetric(path, method, statusCode);

  const logEvent = {
    logGroupName,
    logStreamName,
    logEvents: [
      {
        timestamp: Date.now(),
        message: JSON.stringify({
          timestamp: new Date().toISOString(),
          method,
          path,
          responseTime: duration,
          statusCode,
          ip
        })
      }
    ]
  };

  try {
    await cloudwatchlogs.send(new PutLogEventsCommand(logEvent));
  } catch (err) {
    console.error('Error logging to CloudWatch:', err);
  }
}

module.exports = {
  initCloudWatchLogs,
  sendMetric,
  logRequest
};