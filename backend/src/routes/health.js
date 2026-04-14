const express = require('express');
const router = express.Router();
const pool = require('../db');

router.get('/', (req, res) => {
  res.sendStatus(200);
});

router.get('/db', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.status(200).json({ status: 'OK' });
  } catch (err) {
    console.error('DB health error:', err.message);
    res.status(500).json({ status: 'DB FAIL' });
  }
});
module.exports = router;