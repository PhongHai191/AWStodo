const express = require('express');
const router = express.Router();
const db = require('../db');

router.get('/', (req, res) => {
  res.sendStatus(200);
});

router.get('/db', async (req, res) => {
  let client;
  try {    
    await db.query("SELECT 1");

    res.status(200).json({ status: 'OK' });
  } catch (err) {
    console.error('DB health error:', err.message);
    res.status(500).json({ 
      status: 'DB FAIL', 
      details: err.message 
    });
  }
});
module.exports = router;