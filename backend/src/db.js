const { Pool } = require("pg");
const { getSecret } = require("./utils/ASM");

let pool;

const initPromise = (async () => {
  const secret = await getSecret("TestAWS");

  pool = new Pool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: secret.DB_PASS,
    database: process.env.DB_NAME,
    port: 5432,
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