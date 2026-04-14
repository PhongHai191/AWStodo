const { createClient } = require("redis");

const client = createClient({
  url: `rediss://${process.env.REDIS_HOST}:6379`,
});

client.on("error", (err) => {
  console.error("Redis error:", err);
});

(async () => {
  try {
    await client.connect();
    console.log("Redis connected");
  } catch (err) {
    console.error("Redis connect failed:", err);
  }
})();

module.exports = client;