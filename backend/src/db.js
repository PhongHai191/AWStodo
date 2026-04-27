const { Pool } = require("pg");
const { getSecret } = require("./utils/ASM");
const logger = require("./utils/logger");

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

  pool.on("error", (err) => {
    logger.error("db_pool_error", { error: err.message });
  });

  logger.info("db_connected", { host: secret.host, database: process.env.DB_NAME });
  return pool;
})().catch((err) => {
  logger.error("db_init_failed", { error: err.message });
  throw err;
});

module.exports = {
  query: async (...args) => {
    if (!pool) {
      await initPromise;
    }
    return pool.query(...args);
  },
};
