const amqplib = require("amqplib");
const { CLOUDAMQP_URL } = require("./server-config");

let channel, connection, exchangeName;

async function connectQueue() {
  try {
    connection = await amqplib.connect(CLOUDAMQP_URL);
    exchangeName = "notifications";
    channel = await connection.createChannel();
    await channel.assertExchange(exchangeName, "topic", { durable: true });
  } catch (error) {
    console.error("Error connecting to queue:", error);
    throw error;
  }
}

async function sendData(username, notificationData) {
  try {
    const routingKey = `user.${username}`;
    const queueName = `notifications_${username}`;
    await channel.assertQueue(queueName, { durable: true });
    await channel.bindQueue(queueName, exchangeName, routingKey);
    // await new Promise(resolve => setTimeout(resolve, 1000)); 
    await channel.publish(exchangeName, routingKey, Buffer.from(JSON.stringify(notificationData)));
   
  } catch (error) {
    console.error("Error sending data:", error);
    throw error;
  }
}

async function consumeData(req, res) {
  try {
    const msgs = [];
    const username = req.user.name;
    const queueName = `notifications_${username}`;
    await new Promise((resolve) => {
      channel.consume(queueName, (msg) => {
        if (msg !== null) {
          msgs.push(msg.content.toString());
          // channel.ack(msg);
        }
      }, { noAck: true });
      setTimeout(() => resolve(), 500);
    });
    res.status(200).send(msgs);
  } catch (error) {
    console.error("Error consuming data:", error);
    res.status(500).send(error);
  }
}

module.exports = {
  connectQueue,
  sendData,
  consumeData,
};
