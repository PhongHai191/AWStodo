const express = require('express');
const router = express.Router();
const pool = require('../db');

router.get('/health', (req, res) => {
  res.sendStatus(200);
});

router.get('/health/db', async (req, res) => {
  try {
    const client = await pool.connect();
    client.release();

    res.status(200).json({ status: 'OK' });
  } catch (err) {
    res.status(500).json({ status: 'DB FAIL' });
  }
});

module.exports = router;