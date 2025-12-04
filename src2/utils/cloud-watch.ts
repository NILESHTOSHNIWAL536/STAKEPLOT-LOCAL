import {
  CloudWatchClient,
  PutMetricDataCommand
} from "@aws-sdk/client-cloudwatch";

import {
  CloudWatchLogsClient,
  CreateLogGroupCommand,
  CreateLogStreamCommand,
  PutLogEventsCommand,
  InputLogEvent
} from "@aws-sdk/client-cloudwatch-logs";

import logger from "./common/logger";

// Environment variables
const REGION: string | undefined = process.env.AWS_REGION;
const logGroupName: string = "Mobile-Server-Logs";
const logStreamName: string = `mobile-server-${new Date().toISOString().split("T")[0]}`;

// AWS Clients
const cloudwatch = new CloudWatchClient({ region: REGION });
const cloudwatchlogs = new CloudWatchLogsClient({ region: REGION });

// Check if the environment is production
const isProduction: boolean = process.env.NODE_ENV === "production";

// Log Request Interface
interface LogRequestPayload {
  method: string;
  path: string;
  duration: number;
  statusCode: number;
  ip: string;
}

export async function initCloudWatchLogs(): Promise<void> {
  if (!isProduction) {
    logger.debug("Skipping CloudWatch Logs initialization in non-production environment");
    return;
  }

  try {
    await cloudwatchlogs.send(new CreateLogGroupCommand({ logGroupName }));
  } catch (err: any) {
    if (err.name !== "ResourceAlreadyExistsException") {
      console.error("Error creating log group:", err);
    }
  }

  try {
    await cloudwatchlogs.send(
      new CreateLogStreamCommand({ logGroupName, logStreamName })
    );
  } catch (err: any) {
    if (err.name !== "ResourceAlreadyExistsException") {
      console.error("Error creating log stream:", err);
    }
  }
}

export async function sendMetric(
  path: string,
  method: string,
  statusCode: number
): Promise<void> {
  if (!isProduction) return;

  const callCommand = new PutMetricDataCommand({
    Namespace: "Mobile-Server/APIMetrics",
    MetricData: [
      {
        MetricName: "APICallCount",
        Dimensions: [
          { Name: "Endpoint", Value: path },
          { Name: "Method", Value: method }
        ],
        Unit: "Count",
        Value: 1
      }
    ]
  });

  let failureCommand: PutMetricDataCommand | undefined;

  if (statusCode >= 400) {
    failureCommand = new PutMetricDataCommand({
      Namespace: "Mobile-Server/APIMetrics",
      MetricData: [
        {
          MetricName: "APIFailureCount",
          Dimensions: [
            { Name: "Endpoint", Value: path },
            { Name: "Method", Value: method },
            { Name: "StatusCode", Value: statusCode.toString() }
          ],
          Unit: "Count",
          Value: 1
        }
      ]
    });
  }

  try {
    const commands: Promise<any>[] = [cloudwatch.send(callCommand)];

    if (failureCommand) {
      commands.push(cloudwatch.send(failureCommand));
    }

    await Promise.all(commands);
  } catch (err) {
    console.error("Error sending metric:", err);
  }
}

export async function logRequest({
  method,
  path,
  duration,
  statusCode,
  ip
}: LogRequestPayload): Promise<void> {
  if (!isProduction) return;

  await sendMetric(path, method, statusCode);

  const logEvents: InputLogEvent[] = [
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
  ];

  const logEventParams = {
    logGroupName,
    logStreamName,
    logEvents
  };

  try {
    await cloudwatchlogs.send(new PutLogEventsCommand(logEventParams));
  } catch (err) {
    console.error("Error logging to CloudWatch:", err);
  }
}
