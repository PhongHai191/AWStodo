const { createClient } = require("redis");

const client = createClient({
  url: `redis://${process.env.REDIS_HOST}:6379`,
});

client.connect();

module.exports = client;