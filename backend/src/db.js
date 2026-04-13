const { Pool } = require("pg");
const { getSecret } = require("./ASM");

let pool;

async function initDB() {
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
}

function getDB() {
  if (!pool) throw new Error("DB not initialized");
  return pool;
}

module.exports = { initDB, getDB };