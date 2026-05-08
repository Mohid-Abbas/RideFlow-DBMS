/**
 * RideFlow - Ride Hailing Platform
 * Deliverable 3: Complete System Implementation
 * 
 * Features:
 * - Role-based login (Rider, Driver, Admin)
 * - Rider Dashboard: Book rides, view history, manage wallet
 * - Driver Dashboard: Toggle availability, accept/reject rides, view earnings
 * - Admin Panel: Manage users, vehicles, fare rules, view reports
 * - Live reporting and analytics
 */

const express = require('express');
const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
const session = require('express-session');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

// Session configuration
app.use(session({
    secret: process.env.SESSION_SECRET || 'rideflow_secret_key_2026',
    resave: false,
    saveUninitialized: false,
    cookie: { 
        secure: false, // Set to true if using HTTPS
        maxAge: 24 * 60 * 60 * 1000 // 24 hours
    }
}));

// Database connection pool
const dbConfig = {
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'rideflow_db',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
};

const pool = mysql.createPool(dbConfig);

// Authentication middleware
function requireAuth(req, res, next) {
    if (!req.session.userId) {
        return res.redirect('/login');
    }
    next();
}

function requireRole(role) {
    return (req, res, next) => {
        if (!req.session.userId) {
            return res.redirect('/login');
        }
        if (req.session.role !== role && req.session.role !== 'ADMIN' && req.session.role !== 'SUPER_ADMIN') {
            return res.status(403).send('Access denied');
        }
        next();
    };
}

// Routes

// Home / Login
app.get('/', (req, res) => {
    if (req.session.userId) {
        // Redirect based on role
        const roleRedirects = {
            'RIDER': '/rider/dashboard-modern',
            'DRIVER': '/driver/dashboard',
            'ADMIN': '/admin/dashboard',
            'SUPER_ADMIN': '/admin/dashboard'
        };
        return res.redirect(roleRedirects[req.session.role] || '/login-modern');
    }
    res.redirect('/login-modern');
});

app.get('/login', (req, res) => {
    res.sendFile(__dirname + '/public/login.html');
});

app.get('/login-modern', (req, res) => {
    res.sendFile(__dirname + '/public/login-modern.html');
});

// Authentication API
app.post('/api/login', async (req, res) => {
    const { email, password } = req.body;
    
    try {
        const [users] = await pool.execute(
            'SELECT * FROM users WHERE email = ?',
            [email]
        );
        
        if (users.length === 0) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }
        
        const user = users[0];
        const validPassword = await bcrypt.compare(password, user.password_hash);
        
        if (!validPassword) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }
        
        req.session.userId = user.user_id;
        req.session.role = user.role;
        req.session.userName = user.full_name;
        
        res.json({ 
            success: true, 
            role: user.role,
            name: user.full_name
        });
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

app.post('/api/logout', (req, res) => {
    req.session.destroy();
    res.json({ success: true });
});

// Dashboard routes
app.get('/dashboard', requireAuth, (req, res) => {
    const role = req.session.role;
    if (role === 'RIDER') {
        res.redirect('/rider/dashboard');
    } else if (role === 'DRIVER') {
        res.redirect('/driver/dashboard');
    } else if (role === 'ADMIN' || role === 'SUPER_ADMIN') {
        res.redirect('/admin/dashboard');
    } else {
        res.redirect('/login');
    }
});

// ==================== RIDER DASHBOARD ====================

app.get('/rider/dashboard', requireRole('RIDER'), (req, res) => {
    res.sendFile(__dirname + '/public/rider/dashboard.html');
});

app.get('/rider/dashboard-modern', requireRole('RIDER'), (req, res) => {
    res.sendFile(__dirname + '/public/rider/dashboard-modern.html');
});

app.get('/rider/book', requireRole('RIDER'), (req, res) => {
    res.sendFile(__dirname + '/public/rider/book.html');
});

app.get('/rider/book-with-maps', requireRole('RIDER'), (req, res) => {
    res.sendFile(__dirname + '/public/rider/book-with-maps.html');
});

app.get('/rider/history', requireRole('RIDER'), (req, res) => {
    res.sendFile(__dirname + '/public/rider/history.html');
});

app.get('/rider/wallet', requireRole('RIDER'), (req, res) => {
    res.sendFile(__dirname + '/public/rider/wallet.html');
});

// Rider API endpoints
app.get('/api/rider/profile', requireRole('RIDER'), async (req, res) => {
    try {
        const [rows] = await pool.execute(
            'SELECT user_id, full_name, email, phone, wallet_balance FROM users WHERE user_id = ?',
            [req.session.userId]
        );
        res.json(rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/rider/rides', requireRole('RIDER'), async (req, res) => {
    try {
        const [rows] = await pool.execute(
            `SELECT r.ride_id, r.requested_at, r.ride_status, r.distance_km, r.duration_min, r.fare,
                    u.full_name as driver_name, v.make, v.model, v.license_plate,
                    p.address as pickup, d.address as dropoff, p.city as pickup_city
             FROM rides r
             JOIN drivers dr ON r.driver_id = dr.driver_id
             JOIN users u ON dr.user_id = u.user_id
             JOIN vehicles v ON r.vehicle_id = v.vehicle_id
             JOIN locations p ON r.pickup_loc_id = p.location_id
             JOIN locations d ON r.dropoff_loc_id = d.location_id
             WHERE r.rider_id = ?
             ORDER BY r.requested_at DESC`,
            [req.session.userId]
        );
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/rider/book', requireRole('RIDER'), async (req, res) => {
    const { pickup_loc_id, dropoff_loc_id, vehicle_type, scheduled_at } = req.body;
    
    try {
        // Call stored procedure to book ride
        const [result] = await pool.execute(
            'CALL BookRide(?, ?, ?, ?, ?, @ride_id, @fare)',
            [req.session.userId, pickup_loc_id, dropoff_loc_id, vehicle_type, scheduled_at || null]
        );
        
        // Get the output parameters
        const [output] = await pool.execute('SELECT @ride_id as ride_id, @fare as fare');
        
        res.json({ 
            success: true, 
            ride_id: output[0].ride_id,
            estimated_fare: output[0].fare
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Maps-based booking - creates locations from Google Maps data
app.post('/api/rider/book-with-maps', requireRole('RIDER'), async (req, res) => {
    const { 
        pickup_address, pickup_lat, pickup_lng,
        dropoff_address, dropoff_lat, dropoff_lng,
        vehicle_type, distance_km, duration_min, estimated_fare
    } = req.body;
    
    const conn = await pool.getConnection();
    
    try {
        await conn.beginTransaction();
        
        // 1. Create or get pickup location
        const [pickupResult] = await conn.execute(
            `INSERT INTO locations (latitude, longitude, city, address, label) 
             VALUES (?, ?, ?, ?, ?)
             ON DUPLICATE KEY UPDATE location_id=LAST_INSERT_ID(location_id)`,
            [pickup_lat, pickup_lng, 'Auto-Detected', pickup_address, 'Pickup']
        );
        const pickup_loc_id = pickupResult.insertId;
        
        // 2. Create or get dropoff location
        const [dropoffResult] = await conn.execute(
            `INSERT INTO locations (latitude, longitude, city, address, label) 
             VALUES (?, ?, ?, ?, ?)
             ON DUPLICATE KEY UPDATE location_id=LAST_INSERT_ID(location_id)`,
            [dropoff_lat, dropoff_lng, 'Auto-Detected', dropoff_address, 'Dropoff']
        );
        const dropoff_loc_id = dropoffResult.insertId;
        
        // 3. Get fare rule for the vehicle type
        const [fareRules] = await conn.execute(
            'SELECT rule_id FROM fare_rules WHERE vehicle_type = ?',
            [vehicle_type]
        );
        
        if (fareRules.length === 0) {
            await conn.rollback();
            return res.status(400).json({ error: 'Invalid vehicle type' });
        }
        
        const fare_rule_id = fareRules[0].rule_id;
        
        // 4. Assign an available driver
        const [drivers] = await conn.execute(
            `SELECT d.driver_id FROM drivers d
             JOIN vehicles v ON d.driver_id = v.driver_id
             WHERE d.avail_status = 'ONLINE' 
             AND d.verif_status = 'VERIFIED'
             AND v.vehicle_type = ?
             AND v.verif_status = 'VERIFIED'
             ORDER BY RAND()
             LIMIT 1`,
            [vehicle_type]
        );
        
        if (drivers.length === 0) {
            await conn.rollback();
            return res.status(400).json({ error: 'No available drivers for this vehicle type' });
        }
        
        const driver_id = drivers[0].driver_id;
        
        // 5. Get a vehicle for the driver
        const [vehicles] = await conn.execute(
            `SELECT vehicle_id FROM vehicles 
             WHERE driver_id = ? AND vehicle_type = ? AND verif_status = 'VERIFIED'
             LIMIT 1`,
            [driver_id, vehicle_type]
        );
        
        const vehicle_id = vehicles[0].vehicle_id;
        
        // 6. Create the ride
        const [rideResult] = await conn.execute(
            `INSERT INTO rides (rider_id, driver_id, vehicle_id, pickup_loc_id, dropoff_loc_id, 
                               fare_rule_id, distance_km, duration_min, ride_status, fare)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'REQUESTED', ?)`,
            [req.session.userId, driver_id, vehicle_id, pickup_loc_id, dropoff_loc_id,
             fare_rule_id, distance_km, duration_min, estimated_fare]
        );
        
        const ride_id = rideResult.insertId;
        
        // 7. Update driver status
        await conn.execute(
            "UPDATE drivers SET avail_status = 'ON_TRIP' WHERE driver_id = ?",
            [driver_id]
        );
        
        await conn.commit();
        
        res.json({ 
            success: true, 
            ride_id: ride_id,
            estimated_fare: estimated_fare,
            driver_assigned: true
        });
        
    } catch (error) {
        await conn.rollback();
        console.error('Maps booking error:', error);
        res.status(500).json({ error: error.message });
    } finally {
        conn.release();
    }
});

app.get('/api/locations', async (req, res) => {
    try {
        const [rows] = await pool.execute('SELECT * FROM locations ORDER BY city, address');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/fare-rules', async (req, res) => {
    try {
        const [rows] = await pool.execute('SELECT * FROM fare_rules');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ==================== DRIVER DASHBOARD ====================

app.get('/driver/dashboard', requireRole('DRIVER'), (req, res) => {
    res.sendFile(__dirname + '/public/driver/dashboard.html');
});

app.get('/driver/earnings', requireRole('DRIVER'), (req, res) => {
    res.sendFile(__dirname + '/public/driver/earnings.html');
});

app.get('/driver/history', requireRole('DRIVER'), (req, res) => {
    res.sendFile(__dirname + '/public/driver/history.html');
});

// Driver API endpoints
app.get('/api/driver/profile', requireRole('DRIVER'), async (req, res) => {
    try {
        const [rows] = await pool.execute(
            `SELECT d.driver_id, d.license_num, d.verif_status, d.avail_status, 
                    d.avg_rating, d.total_trips, d.wallet_balance,
                    u.full_name, u.email, u.phone, u.user_id
             FROM drivers d
             JOIN users u ON d.user_id = u.user_id
             WHERE u.user_id = ?`,
            [req.session.userId]
        );
        res.json(rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/driver/toggle-status', requireRole('DRIVER'), async (req, res) => {
    const { status } = req.body; // 'ONLINE' or 'OFFLINE'
    
    try {
        await pool.execute(
            'UPDATE drivers SET avail_status = ? WHERE user_id = ?',
            [status, req.session.userId]
        );
        res.json({ success: true, status });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/driver/rides', requireRole('DRIVER'), async (req, res) => {
    try {
        const [rows] = await pool.execute(
            `SELECT r.ride_id, r.requested_at, r.ride_status, r.distance_km, r.duration_min, r.fare,
                    u.full_name as rider_name, u.phone as rider_phone,
                    p.address as pickup, d.address as dropoff, p.city as pickup_city
             FROM rides r
             JOIN users u ON r.rider_id = u.user_id
             JOIN locations p ON r.pickup_loc_id = p.location_id
             JOIN locations d ON r.dropoff_loc_id = d.location_id
             JOIN drivers dr ON r.driver_id = dr.driver_id
             WHERE dr.user_id = ?
             ORDER BY r.requested_at DESC`,
            [req.session.userId]
        );
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/driver/available-rides', requireRole('DRIVER'), async (req, res) => {
    try {
        // Get available rides for this driver based on their vehicle type and location
        const [rows] = await pool.execute(
            `SELECT r.ride_id, r.requested_at, r.scheduled_at, r.ride_status, 
                    r.distance_km, r.fare, r.rider_id,
                    u.full_name as rider_name,
                    p.address as pickup, p.city as pickup_city,
                    d.address as dropoff, d.city as dropoff_city,
                    fr.vehicle_type
             FROM rides r
             JOIN users u ON r.rider_id = u.user_id
             JOIN locations p ON r.pickup_loc_id = p.location_id
             JOIN locations d ON r.dropoff_loc_id = d.location_id
             JOIN fare_rules fr ON r.fare_rule_id = fr.rule_id
             WHERE r.ride_status = 'REQUESTED'
             ORDER BY r.requested_at ASC`
        );
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/driver/accept-ride', requireRole('DRIVER'), async (req, res) => {
    const { ride_id } = req.body;
    
    try {
        // Get driver_id
        const [drivers] = await pool.execute(
            'SELECT driver_id FROM drivers WHERE user_id = ?',
            [req.session.userId]
        );
        
        if (drivers.length === 0) {
            return res.status(404).json({ error: 'Driver not found' });
        }
        
        const driver_id = drivers[0].driver_id;
        
        // Accept the ride
        await pool.execute(
            `UPDATE rides SET ride_status = 'ACCEPTED', driver_id = ? 
             WHERE ride_id = ? AND ride_status = 'REQUESTED'`,
            [driver_id, ride_id]
        );
        
        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/driver/update-ride-status', requireRole('DRIVER'), async (req, res) => {
    const { ride_id, status } = req.body;
    
    try {
        await pool.execute(
            'UPDATE rides SET ride_status = ? WHERE ride_id = ?',
            [status, ride_id]
        );
        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/driver/earnings', requireRole('DRIVER'), async (req, res) => {
    try {
        const [rows] = await pool.execute(
            `SELECT de.earning_id, de.ride_id, de.gross_fare, de.commission_pct, 
                    de.net_earning, de.earned_at, de.payout_status,
                    r.requested_at, r.distance_km
             FROM driver_earnings de
             JOIN rides r ON de.ride_id = r.ride_id
             JOIN drivers d ON de.driver_id = d.driver_id
             WHERE d.user_id = ?
             ORDER BY de.earned_at DESC`,
            [req.session.userId]
        );
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ==================== ADMIN DASHBOARD ====================

app.get('/admin/dashboard', requireRole('ADMIN'), (req, res) => {
    res.sendFile(__dirname + '/public/admin/dashboard.html');
});

app.get('/admin/users', requireRole('ADMIN'), (req, res) => {
    res.sendFile(__dirname + '/public/admin/users.html');
});

app.get('/admin/vehicles', requireRole('ADMIN'), (req, res) => {
    res.sendFile(__dirname + '/public/admin/vehicles.html');
});

app.get('/admin/fare-rules', requireRole('ADMIN'), (req, res) => {
    res.sendFile(__dirname + '/public/admin/fare-rules.html');
});

app.get('/admin/reports', requireRole('ADMIN'), (req, res) => {
    res.sendFile(__dirname + '/public/admin/reports.html');
});

app.get('/admin/active-rides', requireRole('ADMIN'), (req, res) => {
    res.sendFile(__dirname + '/public/admin/active-rides.html');
});

// Admin API endpoints
app.get('/api/admin/stats', requireRole('ADMIN'), async (req, res) => {
    try {
        // Get dashboard statistics
        const [[totalUsers]] = await pool.execute('SELECT COUNT(*) as count FROM users');
        const [[totalRiders]] = await pool.execute("SELECT COUNT(*) as count FROM users WHERE role = 'RIDER'");
        const [[totalDrivers]] = await pool.execute("SELECT COUNT(*) as count FROM users WHERE role = 'DRIVER'");
        const [[totalRides]] = await pool.execute('SELECT COUNT(*) as count FROM rides');
        const [[activeRides]] = await pool.execute(
            "SELECT COUNT(*) as count FROM rides WHERE ride_status IN ('REQUESTED', 'ACCEPTED', 'DRIVER_EN_ROUTE', 'IN_PROGRESS')"
        );
        const [[completedRides]] = await pool.execute("SELECT COUNT(*) as count FROM rides WHERE ride_status = 'COMPLETED'");
        const [[totalRevenue]] = await pool.execute(
            "SELECT COALESCE(SUM(amount), 0) as total FROM payments WHERE payment_status = 'PAID'"
        );
        
        res.json({
            totalUsers: totalUsers.count,
            totalRiders: totalRiders.count,
            totalDrivers: totalDrivers.count,
            totalRides: totalRides.count,
            activeRides: activeRides.count,
            completedRides: completedRides.count,
            totalRevenue: totalRevenue.total
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/admin/users', requireRole('ADMIN'), async (req, res) => {
    try {
        const [rows] = await pool.execute(
            `SELECT u.user_id, u.full_name, u.email, u.phone, u.role, u.acc_status, u.reg_date,
                    d.driver_id, d.verif_status, d.avg_rating, d.total_trips, d.wallet_balance
             FROM users u
             LEFT JOIN drivers d ON u.user_id = d.user_id
             ORDER BY u.reg_date DESC`
        );
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/admin/drivers', requireRole('ADMIN'), async (req, res) => {
    try {
        const [rows] = await pool.execute(
            `SELECT d.driver_id, u.full_name, u.email, u.phone, d.license_num, 
                    d.verif_status, d.avail_status, d.avg_rating, d.total_trips,
                    v.make, v.model, v.license_plate, v.verif_status as vehicle_status
             FROM drivers d
             JOIN users u ON d.user_id = u.user_id
             LEFT JOIN vehicles v ON v.driver_id = d.driver_id
             ORDER BY d.avg_rating DESC`
        );
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/admin/vehicles', requireRole('ADMIN'), async (req, res) => {
    try {
        const [rows] = await pool.execute(
            `SELECT v.*, u.full_name as driver_name
             FROM vehicles v
             JOIN drivers d ON v.driver_id = d.driver_id
             JOIN users u ON d.user_id = u.user_id
             ORDER BY v.verif_status, v.make`
        );
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/admin/verify-vehicle', requireRole('ADMIN'), async (req, res) => {
    const { vehicle_id, status } = req.body;
    
    try {
        await pool.execute(
            'UPDATE vehicles SET verif_status = ? WHERE vehicle_id = ?',
            [status, vehicle_id]
        );
        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/admin/fare-rules', requireRole('ADMIN'), async (req, res) => {
    try {
        const [rows] = await pool.execute('SELECT * FROM fare_rules');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/admin/fare-rule', requireRole('ADMIN'), async (req, res) => {
    const { rule_id, base_rate, per_km_rate, per_min_rate, surge_multiplier, is_surge_active } = req.body;
    
    try {
        await pool.execute(
            `UPDATE fare_rules 
             SET base_rate = ?, per_km_rate = ?, per_min_rate = ?, 
                 surge_multiplier = ?, is_surge_active = ?
             WHERE rule_id = ?`,
            [base_rate, per_km_rate, per_min_rate, surge_multiplier, is_surge_active, rule_id]
        );
        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/admin/active-rides', requireRole('ADMIN'), async (req, res) => {
    try {
        const [rows] = await pool.execute('SELECT * FROM ActiveRidesView');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/admin/top-drivers', requireRole('ADMIN'), async (req, res) => {
    try {
        const [rows] = await pool.execute('SELECT * FROM TopDriversView');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/admin/revenue-report', requireRole('ADMIN'), async (req, res) => {
    try {
        const { start_date, end_date } = req.query;
        let query = 'SELECT * FROM RevenueReportView';
        let params = [];
        
        if (start_date && end_date) {
            query = `
                SELECT 
                    DATE(r.requested_at) as ride_date,
                    l.city,
                    COUNT(*) as total_rides,
                    SUM(r.fare) as total_fare,
                    SUM(p.amount) as total_collected,
                    SUM(p.promo_discount) as total_discounts,
                    p.payment_method,
                    COUNT(CASE WHEN r.ride_status = 'COMPLETED' THEN 1 END) as completed_rides,
                    COUNT(CASE WHEN r.ride_status = 'CANCELLED' THEN 1 END) as cancelled_rides
                FROM rides r
                JOIN locations l ON r.pickup_loc_id = l.location_id
                JOIN payments p ON p.ride_id = r.ride_id
                WHERE DATE(r.requested_at) BETWEEN ? AND ?
                GROUP BY DATE(r.requested_at), l.city, p.payment_method
                ORDER BY ride_date DESC
            `;
            params = [start_date, end_date];
        }
        
        const [rows] = await pool.execute(query, params);
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/admin/city-revenue', requireRole('ADMIN'), async (req, res) => {
    try {
        const [rows] = await pool.execute(
            `SELECT 
                l.city,
                COUNT(r.ride_id) as total_rides,
                SUM(p.amount) as total_revenue,
                AVG(p.amount) as avg_fare
             FROM rides r
             JOIN locations l ON r.pickup_loc_id = l.location_id
             JOIN payments p ON p.ride_id = r.ride_id
             WHERE p.payment_status = 'PAID'
             GROUP BY l.city
             ORDER BY total_revenue DESC`
        );
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Start server
app.listen(PORT, () => {
    console.log(`=================================`);
    console.log(`  RideFlow Server Running`);
    console.log(`  Port: ${PORT}`);
    console.log(`  Database: ${dbConfig.database}`);
    console.log(`=================================`);
    console.log(`  URLs:`);
    console.log(`  - Login: http://localhost:${PORT}/login`);
    console.log(`  - Rider Dashboard: http://localhost:${PORT}/rider/dashboard`);
    console.log(`  - Driver Dashboard: http://localhost:${PORT}/driver/dashboard`);
    console.log(`  - Admin Dashboard: http://localhost:${PORT}/admin/dashboard`);
    console.log(`=================================`);
});

module.exports = app;
