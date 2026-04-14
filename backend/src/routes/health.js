const express = require('express');
const router = express.Router();
const pool = require('../db');

router.get('/', async (req, res) => {
  const healthcheck = {
    status: 'UP',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    database: 'UP',
    error: null
  };

  try {
    await pool.query('SELECT 1');
    return res.status(200).json(healthcheck);
  } catch (error) {
    healthcheck.status = 'DOWN';
    healthcheck.database = 'DOWN';
    healthcheck.error = error.message;

    return res.status(503).json(healthcheck);
  }
});

module.exports = router;