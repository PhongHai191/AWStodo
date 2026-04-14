const { Pool } = require("pg");
const { getSecret } = require("./utils/ASM");

let pool;

const initPromise = (async () => {
  const secret = await getSecret("TestAWSSS");
  pool = new Pool({
    host: secret.host,
    user: secret.username,
    password: secret.password,
    database: process.env.DB_NAME,
    port: secret.port,
    ssl: { rejectUnauthorized: false },
  });

  return pool;
})();

module.exports = {
  query: async (...args) => {
    if (!pool) {
      await initPromise; // 
    }
    return pool.query(...args);
  },
};