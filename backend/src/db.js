const { Pool } = require("pg");
const { getSecret } = require("./utils/ASM");

let pool;

const initPromise = (async () => {
  const secretName = process.env.DB_SECRET_NAME || "awstodo/dev/db/credentials";
  const secret = await getSecret(secretName);
  pool = new Pool({
    host: secret.host,
    user: secret.username,
    password: secret.password,
    database: process.env.DB_NAME,
    port: secret.port,
    ssl: { rejectUnauthorized: false },
  });

  return pool;
})().catch((err) => {
  console.error("DB init failed:", err.message);
  throw err;
});

module.exports = {
  query: async (...args) => {
    if (!pool) {
      await initPromise; // 
    }
    return pool.query(...args);
  },
};