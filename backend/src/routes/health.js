const express = require('express');
const router = express.Router();
const { Pool } = require('pg'); 

router.get('/', async (req, res) => {
    const healthcheck = {
        status: 'UP',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        database: 'DOWN'
    };

    try {
        await pool.query('SELECT 1');
        healthcheck.database = 'UP';
        res.status(200).json(healthcheck);
    } catch (error) {
        healthcheck.status = 'DOWN';
        healthcheck.database = `ERROR: ${error.message}`;
        res.status(503).json(healthcheck);
    }
});

module.exports = router;