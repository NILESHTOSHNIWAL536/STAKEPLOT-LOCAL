const { SESClient, SendEmailCommand } = require("@aws-sdk/client-ses");
require("dotenv").config();

// No credentials passed — EC2 IAM role provides them automatically via IMDS.
const sesClient = new SESClient({ region: process.env.AWS_REGION });

const sendEmail = async (subject, message, sendTo, sendFrom, replyTo) => {
  const params = {
    Source: sendFrom, // e.g., info@stakeplot.com
    Destination: {
      ToAddresses: [sendTo], // Recipient email
    },
    ReplyToAddresses: [replyTo || sendFrom],
    Message: {
      Subject: {
        Data: subject,
        Charset: "UTF-8",
      },
      Body: {
        Html: {
          Data: message,
          Charset: "UTF-8",
        },
      },
    },
  };


  try {
    const command = new SendEmailCommand(params);
    const response = await sesClient.send(command);
    return response;
  } catch (err) {
    throw err;
  }
};

module.exports = sendEmail;