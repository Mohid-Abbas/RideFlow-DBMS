const mysql = require('mysql2/promise');
require('dotenv').config();

async function testConnection() {
    console.log('Testing DB Connection...');
    console.log('Host:', process.env.DB_HOST);
    console.log('User:', process.env.DB_USER);
    console.log('Database:', process.env.DB_NAME);
    console.log('SSL:', process.env.DB_SSL === 'true' ? 'Enabled' : 'Disabled');

    try {
        const dbConfig = {
            host: process.env.DB_HOST || 'localhost',
            port: process.env.DB_PORT || 3306,
            user: process.env.DB_USER || 'root',
            password: process.env.DB_PASSWORD || '',
            database: process.env.DB_NAME || 'rideflow_db',
        };

        if (process.env.DB_SSL === 'true') {
            dbConfig.ssl = { rejectUnauthorized: false };
        }

        const pool = mysql.createPool(dbConfig);
        const conn = await pool.getConnection();
        const [rows] = await conn.execute('SELECT COUNT(*) as count FROM users');
        console.log(`✅ Connection SUCCESSFUL! Found ${rows[0].count} users.`);
        conn.release();
        process.exit(0);
    } catch (err) {
        console.error('❌ Connection FAILED!');
        console.error('Error Details:', err.message);
        console.error('Code:', err.code);
        process.exit(1);
    }
}

testConnection();
