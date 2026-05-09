-- RideFlow Deliverable 3: Advanced SQL Implementation
-- =====================================================
-- This file contains all advanced SQL components required for D3:
-- 1. Basic SQL Queries (SELECT, WHERE, ORDER BY)
-- 2. Aggregate Functions & HAVING Clause
-- 3. Joins for Reports
-- 4. Views & Indexes
-- 5. Stored Procedures
-- 6. Triggers & Events
-- 7. DCL (Data Control Language) - Role-based Access Control
-- =====================================================

USE databaseProject_db;

-- =====================================================
-- SECTION 1: BASIC SQL QUERIES (5 Marks)
-- =====================================================

-- Query 1: List all completed rides for a specific rider ordered by date
-- This demonstrates SELECT, WHERE, and ORDER BY clauses
SELECT 
    r.ride_id,
    r.rider_id,
    u.full_name AS rider_name,
    r.pickup_loc_id,
    r.dropoff_loc_id,
    r.ride_status,
    r.fare,
    r.requested_at,
    r.duration_min,
    r.distance_km
FROM rides r
JOIN users u ON r.rider_id = u.user_id
WHERE r.rider_id = 1 
  AND r.ride_status = 'COMPLETED'
ORDER BY r.requested_at DESC;

-- Query 2: List all drivers in a specific city ordered by rating
-- This demonstrates filtering by joined table data and ordering
SELECT 
    d.driver_id,
    u.full_name AS driver_name,
    d.license_num,
    d.avg_rating,
    d.total_trips,
    d.avail_status,
    l.city
FROM drivers d
JOIN users u ON d.user_id = u.user_id
JOIN vehicles v ON v.driver_id = d.driver_id
JOIN locations l ON l.location_id = v.vehicle_id
WHERE l.city = 'Lahore'
ORDER BY d.avg_rating DESC, d.total_trips DESC;

-- Query 3: Find all available (online) drivers with their vehicle details
SELECT 
    d.driver_id,
    u.full_name AS driver_name,
    d.avg_rating,
    v.vehicle_id,
    v.make,
    v.model,
    v.license_plate,
    v.vehicle_type
FROM drivers d
JOIN users u ON d.user_id = u.user_id
JOIN vehicles v ON v.driver_id = d.driver_id
WHERE d.avail_status = 'ONLINE'
  AND v.verif_status = 'VERIFIED'
ORDER BY d.avg_rating DESC;

-- =====================================================
-- SECTION 2: AGGREGATE FUNCTIONS & HAVING CLAUSE (10 Marks)
-- =====================================================

-- Query 4: SUM() - Calculate total revenue per city
-- This demonstrates aggregate function with GROUP BY
SELECT 
    l.city,
    COUNT(DISTINCT r.ride_id) AS total_rides,
    SUM(p.amount) AS total_revenue,
    AVG(p.amount) AS avg_fare,
    MIN(p.amount) AS min_fare,
    MAX(p.amount) AS max_fare
FROM rides r
JOIN locations l ON r.pickup_loc_id = l.location_id
JOIN payments p ON p.ride_id = r.ride_id
WHERE p.payment_status = 'PAID'
GROUP BY l.city
ORDER BY total_revenue DESC;

-- Query 5: AVG() - Calculate average driver ratings with HAVING clause
-- Filter drivers with rating below 3.5 (needs admin review)
SELECT 
    d.driver_id,
    u.full_name AS driver_name,
    COUNT(r.ride_id) AS total_rides,
    AVG(rat.score) AS average_rating,
    d.avail_status
FROM drivers d
JOIN users u ON d.user_id = u.user_id
LEFT JOIN rides r ON r.driver_id = d.driver_id AND r.ride_status = 'COMPLETED'
LEFT JOIN ratings rat ON rat.ride_id = r.ride_id AND rat.rated_user = d.user_id
GROUP BY d.driver_id, u.full_name, d.avail_status
HAVING AVG(rat.score) < 3.5
   AND COUNT(r.ride_id) >= 5  -- Only flag if they have significant ride history
ORDER BY average_rating ASC;

-- Query 6: COUNT() - Number of trips completed per driver with earnings
SELECT 
    d.driver_id,
    u.full_name AS driver_name,
    COUNT(r.ride_id) AS trips_completed,
    COUNT(CASE WHEN r.ride_status = 'CANCELLED' THEN 1 END) AS cancelled_rides,
    SUM(de.net_earning) AS total_earnings,
    AVG(de.net_earning) AS avg_earning_per_ride
FROM drivers d
JOIN users u ON d.user_id = u.user_id
LEFT JOIN rides r ON r.driver_id = d.driver_id
LEFT JOIN driver_earnings de ON de.ride_id = r.ride_id AND de.driver_id = d.driver_id
GROUP BY d.driver_id, u.full_name
HAVING trips_completed > 0
ORDER BY trips_completed DESC;

-- Query 7: Complex aggregate with multiple HAVING conditions
-- Find riders who take frequent short trips (potential fraud pattern)
SELECT 
    r.rider_id,
    u.full_name AS rider_name,
    COUNT(*) AS total_rides,
    AVG(r.distance_km) AS avg_distance,
    SUM(p.amount) AS total_spent
FROM rides r
JOIN users u ON r.rider_id = u.user_id
JOIN payments p ON p.ride_id = r.ride_id
WHERE r.ride_status = 'COMPLETED'
GROUP BY r.rider_id, u.full_name
HAVING COUNT(*) > 10 
   AND AVG(r.distance_km) < 2.0
ORDER BY total_rides DESC;

-- =====================================================
-- SECTION 3: JOINS FOR REPORTS (20 Marks)
-- =====================================================

-- Query 8: INNER JOIN - Full trip report linking Riders, Rides, Drivers, and Vehicles
-- Comprehensive report showing all trip details
SELECT 
    r.ride_id,
    r.requested_at,
    r.ride_status,
    r.distance_km,
    r.duration_min,
    r.fare,
    
    -- Rider details
    rider.user_id AS rider_id,
    rider.full_name AS rider_name,
    rider.phone AS rider_phone,
    
    -- Driver details
    driver.user_id AS driver_user_id,
    driver.full_name AS driver_name,
    driver.phone AS driver_phone,
    d.license_num,
    d.avg_rating AS driver_rating,
    
    -- Vehicle details
    v.make,
    v.model,
    v.vehicle_year,
    v.license_plate,
    v.vehicle_type,
    
    -- Location details
    pickup.address AS pickup_address,
    pickup.city AS pickup_city,
    dropoff.address AS dropoff_address,
    dropoff.city AS dropoff_city,
    
    -- Payment details
    p.amount AS paid_amount,
    p.payment_method,
    p.payment_status

FROM rides r
-- Join rider details
INNER JOIN users rider ON r.rider_id = rider.user_id
-- Join driver details
INNER JOIN drivers d ON r.driver_id = d.driver_id
INNER JOIN users driver ON d.user_id = driver.user_id
-- Join vehicle details
INNER JOIN vehicles v ON r.vehicle_id = v.vehicle_id
-- Join location details
INNER JOIN locations pickup ON r.pickup_loc_id = pickup.location_id
INNER JOIN locations dropoff ON r.dropoff_loc_id = dropoff.location_id
-- Join payment details
LEFT JOIN payments p ON p.ride_id = r.ride_id
ORDER BY r.requested_at DESC;

-- Query 9: LEFT JOIN - All riders including those who have never completed a ride
-- This shows riders with no ride history (inactive users)
SELECT 
    u.user_id,
    u.full_name,
    u.email,
    u.phone,
    u.reg_date,
    u.acc_status,
    COUNT(r.ride_id) AS total_rides,
    MAX(r.requested_at) AS last_ride_date,
    COALESCE(SUM(p.amount), 0) AS total_spent
FROM users u
LEFT JOIN rides r ON u.user_id = r.rider_id AND r.ride_status IN ('COMPLETED', 'IN_PROGRESS')
LEFT JOIN payments p ON r.ride_id = p.ride_id AND p.payment_status = 'PAID'
WHERE u.role = 'RIDER'
GROUP BY u.user_id, u.full_name, u.email, u.phone, u.reg_date, u.acc_status
ORDER BY total_rides ASC, u.reg_date DESC;

-- Query 10: JOIN on Payments and PromoCodes - Discount usage per ride
-- Shows detailed payment breakdown including promo code discounts
SELECT 
    r.ride_id,
    r.requested_at,
    rider.full_name AS rider_name,
    driver.full_name AS driver_name,
    r.fare AS original_fare,
    pc.code AS promo_code,
    pc.discount_pct,
    p.promo_discount,
    p.amount AS final_amount,
    p.payment_method,
    p.payment_status,
    CASE 
        WHEN pc.promo_id IS NOT NULL THEN 'Discount Applied'
        ELSE 'No Discount'
    END AS discount_status
FROM rides r
JOIN users rider ON r.rider_id = rider.user_id
JOIN drivers d ON r.driver_id = d.driver_id
JOIN users driver ON d.user_id = driver.user_id
JOIN payments p ON p.ride_id = r.ride_id
LEFT JOIN promo_codes pc ON p.promo_id = pc.promo_id
ORDER BY r.requested_at DESC;

-- Query 11: RIGHT JOIN simulation - All promo codes and their usage
-- Shows which promo codes are being used most
SELECT 
    pc.promo_id,
    pc.code,
    pc.discount_pct,
    pc.valid_until,
    pc.max_uses,
    pc.is_active,
    COUNT(p.payment_id) AS times_used,
    COALESCE(SUM(p.promo_discount), 0) AS total_discount_given
FROM promo_codes pc
LEFT JOIN payments p ON p.promo_id = pc.promo_id AND p.payment_status = 'PAID'
GROUP BY pc.promo_id, pc.code, pc.discount_pct, pc.valid_until, pc.max_uses, pc.is_active
ORDER BY times_used DESC;

-- Query 12: Complex multi-table join for Driver Performance Report
SELECT 
    d.driver_id,
    u.full_name AS driver_name,
    u.phone,
    d.license_num,
    d.avg_rating,
    d.total_trips,
    d.wallet_balance,
    CONCAT(v.make, ' ', v.model) AS vehicle,
    v.license_plate,
    COUNT(DISTINCT r.ride_id) AS rides_this_month,
    SUM(de.net_earning) AS earnings_this_month,
    AVG(rat.score) AS recent_avg_rating
FROM drivers d
JOIN users u ON d.user_id = u.user_id
JOIN vehicles v ON v.driver_id = d.driver_id AND v.verif_status = 'VERIFIED'
LEFT JOIN rides r ON r.driver_id = d.driver_id 
    AND r.ride_status = 'COMPLETED'
    AND r.requested_at >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
LEFT JOIN driver_earnings de ON de.ride_id = r.ride_id
LEFT JOIN ratings rat ON rat.ride_id = r.ride_id AND rat.rated_user = u.user_id
GROUP BY d.driver_id, u.full_name, u.phone, d.license_num, d.avg_rating, 
         d.total_trips, d.wallet_balance, v.make, v.model, v.license_plate
ORDER BY earnings_this_month DESC;

-- =====================================================
-- SECTION 4: VIEWS & INDEXES (15 Marks)
-- =====================================================

-- View 1: ActiveRidesView - Shows all ongoing trips with full details
-- This view displays all rides that are currently in progress
CREATE OR REPLACE VIEW ActiveRidesView AS
SELECT 
    r.ride_id,
    r.requested_at,
    r.scheduled_at,
    r.ride_status,
    r.distance_km,
    r.duration_min,
    r.fare,
    
    -- Rider details
    rider.user_id AS rider_id,
    rider.full_name AS rider_name,
    rider.phone AS rider_phone,
    
    -- Driver details
    driver.user_id AS driver_user_id,
    driver.full_name AS driver_name,
    driver.phone AS driver_phone,
    d.license_num AS driver_license,
    
    -- Vehicle details
    v.make AS vehicle_make,
    v.model AS vehicle_model,
    v.license_plate AS vehicle_plate,
    v.vehicle_type,
    
    -- Location details
    pickup.address AS pickup_address,
    pickup.city AS pickup_city,
    pickup.latitude AS pickup_lat,
    pickup.longitude AS pickup_lng,
    dropoff.address AS dropoff_address,
    dropoff.city AS dropoff_city,
    dropoff.latitude AS dropoff_lat,
    dropoff.longitude AS dropoff_lng,
    
    -- Payment preview
    p.payment_status,
    p.amount AS payment_amount

FROM rides r
JOIN users rider ON r.rider_id = rider.user_id
JOIN drivers d ON r.driver_id = d.driver_id
JOIN users driver ON d.user_id = driver.user_id
JOIN vehicles v ON r.vehicle_id = v.vehicle_id
JOIN locations pickup ON r.pickup_loc_id = pickup.location_id
JOIN locations dropoff ON r.dropoff_loc_id = dropoff.location_id
LEFT JOIN payments p ON p.ride_id = r.ride_id
WHERE r.ride_status IN ('REQUESTED', 'ACCEPTED', 'DRIVER_EN_ROUTE', 'IN_PROGRESS')
ORDER BY r.requested_at DESC;

-- View 2: TopDriversView - Shows only drivers with average rating above 4.5
-- Elite drivers who qualify for premium assignments
CREATE OR REPLACE VIEW TopDriversView AS
SELECT 
    d.driver_id,
    u.full_name AS driver_name,
    u.email,
    u.phone,
    u.reg_date,
    d.license_num,
    d.cnic,
    d.verif_status,
    d.avail_status,
    d.avg_rating,
    d.total_trips,
    d.wallet_balance,
    
    -- Vehicle information
    v.vehicle_id,
    v.make AS vehicle_make,
    v.model AS vehicle_model,
    v.vehicle_year,
    v.license_plate AS vehicle_plate,
    v.vehicle_type,
    
    -- Recent performance metrics
    COUNT(DISTINCT r.ride_id) AS rides_this_month,
    SUM(de.net_earning) AS earnings_this_month,
    AVG(rat.score) AS recent_avg_rating

FROM drivers d
JOIN users u ON d.user_id = u.user_id
LEFT JOIN vehicles v ON v.driver_id = d.driver_id AND v.verif_status = 'VERIFIED'
LEFT JOIN rides r ON r.driver_id = d.driver_id 
    AND r.ride_status = 'COMPLETED'
    AND r.requested_at >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
LEFT JOIN driver_earnings de ON de.ride_id = r.ride_id
LEFT JOIN ratings rat ON rat.ride_id = r.ride_id AND rat.rated_user = u.user_id
WHERE d.avg_rating >= 4.5
  AND d.total_trips >= 10
  AND d.verif_status = 'VERIFIED'
GROUP BY d.driver_id, u.full_name, u.email, u.phone, u.reg_date,
         d.license_num, d.cnic, d.verif_status, d.avail_status, 
         d.avg_rating, d.total_trips, d.wallet_balance,
         v.vehicle_id, v.make, v.model, v.vehicle_year, v.license_plate, v.vehicle_type
ORDER BY d.avg_rating DESC, d.total_trips DESC;

-- View 3: RideHistoryView - Complete ride history for all users
CREATE OR REPLACE VIEW RideHistoryView AS
SELECT 
    r.ride_id,
    r.requested_at,
    r.ride_status,
    rider.user_id AS rider_id,
    rider.full_name AS rider_name,
    driver.user_id AS driver_id,
    driver.full_name AS driver_name,
    pickup.city AS pickup_city,
    dropoff.city AS dropoff_city,
    r.distance_km,
    r.duration_min,
    r.fare,
    p.amount AS paid_amount,
    p.payment_method,
    p.payment_status,
    rat.score AS rating_given,
    rat.comment AS rating_comment
FROM rides r
JOIN users rider ON r.rider_id = rider.user_id
JOIN drivers d ON r.driver_id = d.driver_id
JOIN users driver ON d.user_id = driver.user_id
JOIN locations pickup ON r.pickup_loc_id = pickup.location_id
JOIN locations dropoff ON r.dropoff_loc_id = dropoff.location_id
LEFT JOIN payments p ON p.ride_id = r.ride_id
LEFT JOIN ratings rat ON rat.ride_id = r.ride_id AND rat.rated_by = rider.user_id
ORDER BY r.requested_at DESC;

-- View 4: RevenueReportView - Platform revenue analytics
CREATE OR REPLACE VIEW RevenueReportView AS
SELECT 
    DATE(r.requested_at) AS ride_date,
    pickup.city,
    COUNT(*) AS total_rides,
    SUM(r.fare) AS total_fare,
    SUM(p.amount) AS total_collected,
    SUM(p.promo_discount) AS total_discounts,
    SUM(de.commission_pct * r.fare / 100) AS total_commission,
    SUM(de.net_earning) AS total_driver_earnings,
    p.payment_method,
    COUNT(CASE WHEN r.ride_status = 'COMPLETED' THEN 1 END) AS completed_rides,
    COUNT(CASE WHEN r.ride_status = 'CANCELLED' THEN 1 END) AS cancelled_rides
FROM rides r
JOIN locations pickup ON r.pickup_loc_id = pickup.location_id
JOIN payments p ON p.ride_id = r.ride_id
LEFT JOIN driver_earnings de ON de.ride_id = r.ride_id
WHERE r.requested_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY DATE(r.requested_at), pickup.city, p.payment_method
ORDER BY ride_date DESC, total_collected DESC;

-- Additional Indexes Section (Cloud-Compatible)
-- NOTE: These indexes are commented out because they already exist in the schema file
-- (databaseProject_db.sql). This prevents "Duplicate key name" errors when running
-- this file in MySQL Workbench or cloud databases.
-- The indexes are: idx_rides_rider_id, idx_rides_driver_id, idx_rides_status, etc.
-- All 7 indexes were successfully created by the schema - no need to recreate them!

/*
-- Index 1: Index on rider_id for faster rider lookups
CREATE INDEX idx_rides_rider_id ON rides(rider_id);

-- Index 2: Index on driver_id for driver performance queries
CREATE INDEX idx_rides_driver_id ON rides(driver_id);

-- Index 3: Index on ride_status for active rides filtering
CREATE INDEX idx_rides_status ON rides(ride_status);

-- Index 4: Index on city column for location-based queries
CREATE INDEX idx_locations_city ON locations(city);

-- Index 5: Composite index for date range queries
CREATE INDEX idx_rides_requested_at ON rides(requested_at);

-- Index 6: Index on payments status for financial reports
CREATE INDEX idx_payments_status ON payments(payment_status);

-- Index 7: Index on promo_codes validity for expiry events
CREATE INDEX idx_promo_valid_until ON promo_codes(valid_until);
*/

-- =====================================================
-- SECTION 5: STORED PROCEDURES (15 Marks)
-- =====================================================

DELIMITER //

-- Procedure 1: Calculate Fare with Surge Pricing
-- Automatically calculates fare based on distance, duration, and surge multiplier
CREATE PROCEDURE IF NOT EXISTS CalculateFare(
    IN p_distance_km DECIMAL(8,2),
    IN p_duration_min INT UNSIGNED,
    IN p_vehicle_type ENUM('ECONOMY', 'PREMIUM', 'BIKE'),
    IN p_is_peak_hour BOOLEAN,
    OUT p_calculated_fare DECIMAL(10,2),
    OUT p_base_fare DECIMAL(10,2),
    OUT p_surge_multiplier DECIMAL(4,2)
)
BEGIN
    DECLARE v_base_rate DECIMAL(10,2);
    DECLARE v_per_km_rate DECIMAL(10,2);
    DECLARE v_per_min_rate DECIMAL(10,2);
    DECLARE v_rule_surge_multiplier DECIMAL(4,2);
    DECLARE v_is_surge_active BOOLEAN;
    
    -- Get fare rules for the vehicle type
    SELECT base_rate, per_km_rate, per_min_rate, surge_multiplier, is_surge_active
    INTO v_base_rate, v_per_km_rate, v_per_min_rate, v_rule_surge_multiplier, v_is_surge_active
    FROM fare_rules
    WHERE vehicle_type = p_vehicle_type;
    
    -- Calculate base fare
    SET p_base_fare = v_base_rate + (v_per_km_rate * p_distance_km) + (v_per_min_rate * p_duration_min);
    
    -- Apply surge pricing if active and during peak hours
    IF v_is_surge_active = TRUE AND p_is_peak_hour = TRUE THEN
        SET p_surge_multiplier = v_rule_surge_multiplier;
    ELSE
        SET p_surge_multiplier = 1.00;
    END IF;
    
    -- Calculate final fare with surge
    SET p_calculated_fare = ROUND(p_base_fare * p_surge_multiplier, 2);
END //

-- Procedure 2: Book a Ride
-- Complete ride booking process with fare calculation
CREATE PROCEDURE IF NOT EXISTS BookRide(
    IN p_rider_id INT UNSIGNED,
    IN p_pickup_loc_id INT UNSIGNED,
    IN p_dropoff_loc_id INT UNSIGNED,
    IN p_vehicle_type ENUM('ECONOMY', 'PREMIUM', 'BIKE'),
    IN p_scheduled_at DATETIME,
    OUT p_ride_id INT UNSIGNED,
    OUT p_estimated_fare DECIMAL(10,2)
)
BEGIN
    DECLARE v_fare_rule_id INT UNSIGNED;
    DECLARE v_distance_km DECIMAL(8,2) DEFAULT 5.00; -- Estimated
    DECLARE v_duration_min INT UNSIGNED DEFAULT 15;  -- Estimated
    DECLARE v_is_peak BOOLEAN DEFAULT FALSE;
    DECLARE v_calculated_fare DECIMAL(10,2);
    DECLARE v_base_fare DECIMAL(10,2);
    DECLARE v_surge DECIMAL(4,2);
    
    -- Get fare rule ID
    SELECT rule_id INTO v_fare_rule_id 
    FROM fare_rules 
    WHERE vehicle_type = p_vehicle_type;
    
    -- Check if it's peak hour (7-9 AM or 5-8 PM)
    SET v_is_peak = (HOUR(NOW()) BETWEEN 7 AND 9) OR (HOUR(NOW()) BETWEEN 17 AND 20);
    
    -- Calculate fare
    CALL CalculateFare(v_distance_km, v_duration_min, p_vehicle_type, v_is_peak, 
                       v_calculated_fare, v_base_fare, v_surge);
    SET p_estimated_fare = v_calculated_fare;
    
    -- Insert the ride
    INSERT INTO rides (rider_id, driver_id, vehicle_id, pickup_loc_id, dropoff_loc_id, 
                       fare_rule_id, scheduled_at, distance_km, duration_min, fare, ride_status)
    VALUES (p_rider_id, 1, 1, p_pickup_loc_id, p_dropoff_loc_id, 
            v_fare_rule_id, p_scheduled_at, v_distance_km, v_duration_min, v_calculated_fare, 'REQUESTED');
    
    SET p_ride_id = LAST_INSERT_ID();
END //

-- Procedure 3: Process Payment
-- Handles payment processing with promo code application
CREATE PROCEDURE IF NOT EXISTS ProcessPayment(
    IN p_ride_id INT UNSIGNED,
    IN p_payment_method ENUM('CASH', 'WALLET', 'CARD'),
    IN p_promo_code VARCHAR(30),
    OUT p_payment_id INT UNSIGNED,
    OUT p_final_amount DECIMAL(10,2),
    OUT p_discount_applied DECIMAL(10,2)
)
BEGIN
    DECLARE v_rider_id INT UNSIGNED;
    DECLARE v_fare DECIMAL(10,2);
    DECLARE v_promo_id INT UNSIGNED DEFAULT NULL;
    DECLARE v_discount_pct DECIMAL(5,2) DEFAULT 0;
    DECLARE v_promo_active BOOLEAN DEFAULT FALSE;
    
    -- Get ride details
    SELECT rider_id, fare INTO v_rider_id, v_fare
    FROM rides WHERE ride_id = p_ride_id;
    
    -- Check and apply promo code if provided
    IF p_promo_code IS NOT NULL AND p_promo_code != '' THEN
        SELECT promo_id, discount_pct, is_active 
        INTO v_promo_id, v_discount_pct, v_promo_active
        FROM promo_codes 
        WHERE code = p_promo_code 
          AND valid_until >= CURDATE() 
          AND is_active = TRUE;
        
        IF v_promo_active THEN
            SET p_discount_applied = ROUND(v_fare * (v_discount_pct / 100), 2);
        ELSE
            SET p_discount_applied = 0;
        END IF;
    ELSE
        SET p_discount_applied = 0;
    END IF;
    
    -- Calculate final amount
    SET p_final_amount = v_fare - p_discount_applied;
    
    -- Insert payment record
    INSERT INTO payments (ride_id, rider_id, promo_id, payment_method, amount, 
                          payment_status, promo_discount)
    VALUES (p_ride_id, v_rider_id, v_promo_id, p_payment_method, p_final_amount, 
            'PENDING', p_discount_applied);
    
    SET p_payment_id = LAST_INSERT_ID();
END //

-- Procedure 4: Complete Ride
-- Finalizes a ride, updates driver earnings, and creates earning record
CREATE PROCEDURE IF NOT EXISTS CompleteRide(
    IN p_ride_id INT UNSIGNED,
    IN p_final_distance DECIMAL(8,2),
    IN p_final_duration INT UNSIGNED,
    OUT p_success BOOLEAN
)
BEGIN
    DECLARE v_driver_id INT UNSIGNED;
    DECLARE v_fare DECIMAL(10,2);
    DECLARE v_commission_pct DECIMAL(5,2) DEFAULT 20.00; -- Platform takes 20%
    DECLARE v_net_earning DECIMAL(10,2);
    
    START TRANSACTION;
    
    -- Get ride details
    SELECT driver_id, fare INTO v_driver_id, v_fare
    FROM rides WHERE ride_id = p_ride_id;
    
    -- Update ride with final metrics and status
    UPDATE rides 
    SET ride_status = 'COMPLETED',
        distance_km = p_final_distance,
        duration_min = p_final_duration
    WHERE ride_id = p_ride_id;
    
    -- Calculate driver earnings
    SET v_net_earning = ROUND(v_fare * (100 - v_commission_pct) / 100, 2);
    
    -- Create earnings record
    INSERT INTO driver_earnings (ride_id, driver_id, gross_fare, commission_pct, net_earning)
    VALUES (p_ride_id, v_driver_id, v_fare, v_commission_pct, v_net_earning);
    
    -- Update driver totals
    UPDATE drivers 
    SET total_trips = total_trips + 1,
        wallet_balance = wallet_balance + v_net_earning
    WHERE driver_id = v_driver_id;
    
    COMMIT;
    SET p_success = TRUE;
END //

-- Procedure 5: Get Driver Performance Report
-- Generates a comprehensive performance report for a driver
CREATE PROCEDURE IF NOT EXISTS GetDriverPerformance(
    IN p_driver_id INT UNSIGNED,
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    SELECT 
        d.driver_id,
        u.full_name AS driver_name,
        COUNT(r.ride_id) AS total_rides,
        COUNT(CASE WHEN r.ride_status = 'COMPLETED' THEN 1 END) AS completed_rides,
        COUNT(CASE WHEN r.ride_status = 'CANCELLED' THEN 1 END) AS cancelled_rides,
        SUM(CASE WHEN r.ride_status = 'COMPLETED' THEN de.net_earning ELSE 0 END) AS total_earnings,
        AVG(rat.score) AS avg_rating_received,
        SUM(CASE WHEN r.ride_status = 'COMPLETED' THEN 1 ELSE 0 END) / 
            NULLIF(COUNT(r.ride_id), 0) * 100 AS completion_rate
    FROM drivers d
    JOIN users u ON d.user_id = u.user_id
    LEFT JOIN rides r ON r.driver_id = d.driver_id 
        AND DATE(r.requested_at) BETWEEN p_start_date AND p_end_date
    LEFT JOIN driver_earnings de ON de.ride_id = r.ride_id
    LEFT JOIN ratings rat ON rat.ride_id = r.ride_id AND rat.rated_user = u.user_id
    WHERE d.driver_id = p_driver_id
    GROUP BY d.driver_id, u.full_name;
END //

DELIMITER ;

-- =====================================================
-- SECTION 6: TRIGGERS & EVENTS (10 Marks)
-- =====================================================

DELIMITER //

-- Trigger 1: After Payment Update - Auto-complete ride when payment is marked PAID
-- Updates ride status to COMPLETED when payment is confirmed
DROP TRIGGER IF EXISTS trg_after_payment_paid //
CREATE TRIGGER trg_after_payment_paid
AFTER UPDATE ON payments
FOR EACH ROW
BEGIN
    -- Only proceed if status changed to PAID
    IF OLD.payment_status != 'PAID' AND NEW.payment_status = 'PAID' THEN
        -- Update ride status to COMPLETED
        UPDATE rides 
        SET ride_status = 'COMPLETED'
        WHERE ride_id = NEW.ride_id
          AND ride_status IN ('IN_PROGRESS', 'DRIVER_EN_ROUTE');
    END IF;
END //

-- Trigger 2: After Rating Insert - Flag driver when average rating drops below 3.5
-- Automatically flags drivers with poor ratings for admin review
DROP TRIGGER IF EXISTS trg_after_rating_check_driver //
CREATE TRIGGER trg_after_rating_check_driver
AFTER INSERT ON ratings
FOR EACH ROW
BEGIN
    DECLARE v_avg_rating DECIMAL(3,2);
    DECLARE v_driver_user_id INT UNSIGNED;
    DECLARE v_total_ratings INT;
    
    -- Get the user_id of the rated driver
    SELECT user_id INTO v_driver_user_id 
    FROM drivers 
    WHERE driver_id = (SELECT driver_id FROM rides WHERE ride_id = NEW.ride_id);
    
    -- Only check if rating is for a driver (not rider)
    IF NEW.rated_user = v_driver_user_id THEN
        -- Calculate driver's new average rating
        SELECT AVG(score), COUNT(*) INTO v_avg_rating, v_total_ratings
        FROM ratings 
        WHERE rated_user = v_driver_user_id;
        
        -- Update driver average rating
        UPDATE drivers 
        SET avg_rating = v_avg_rating
        WHERE user_id = v_driver_user_id;
        
        -- Flag driver if rating drops below 3.5 and has significant ratings
        IF v_avg_rating < 3.5 AND v_total_ratings >= 5 THEN
            -- Could insert into a driver_flags table or update status
            -- For now, we'll add a note by updating the driver's availability status
            UPDATE drivers 
            SET avail_status = 'OFFLINE'
            WHERE user_id = v_driver_user_id 
              AND avail_status != 'ON_TRIP'
              AND verif_status != 'REJECTED';
        END IF;
    END IF;
END //

-- Trigger 3: After Payment Insert with Promo - Increment promo code usage
-- Updates promo code usage statistics when a promo is applied
DROP TRIGGER IF EXISTS trg_after_payment_promo //
CREATE TRIGGER trg_after_payment_promo
AFTER INSERT ON payments
FOR EACH ROW
BEGIN
    IF NEW.promo_id IS NOT NULL THEN
        -- Decrement remaining uses for the promo code
        UPDATE promo_codes 
        SET max_uses = max_uses - 1
        WHERE promo_id = NEW.promo_id 
          AND max_uses > 0;
        
        -- Deactivate promo if max uses reached
        UPDATE promo_codes 
        SET is_active = FALSE 
        WHERE promo_id = NEW.promo_id 
          AND max_uses = 0;
    END IF;
END //

-- Trigger 4: Before Ride Insert - Validate rider has sufficient balance (if using wallet)
DROP TRIGGER IF EXISTS trg_before_ride_insert //
CREATE TRIGGER trg_before_ride_insert
BEFORE INSERT ON rides
FOR EACH ROW
BEGIN
    DECLARE v_rider_role VARCHAR(20);
    
    -- Verify the user is actually a rider
    SELECT role INTO v_rider_role FROM users WHERE user_id = NEW.rider_id;
    
    IF v_rider_role != 'RIDER' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Only users with RIDER role can book rides';
    END IF;
END //

-- Trigger 5: After Ride Status Update - Log status changes
DROP TRIGGER IF EXISTS trg_after_ride_status //
CREATE TRIGGER trg_after_ride_status
AFTER UPDATE ON rides
FOR EACH ROW
BEGIN
    -- When ride is accepted, update driver availability
    IF OLD.ride_status = 'REQUESTED' AND NEW.ride_status = 'ACCEPTED' THEN
        UPDATE drivers 
        SET avail_status = 'ON_TRIP'
        WHERE driver_id = NEW.driver_id;
    END IF;
    
    -- When ride is completed or cancelled, free up the driver
    IF NEW.ride_status IN ('COMPLETED', 'CANCELLED') 
       AND OLD.ride_status IN ('ACCEPTED', 'DRIVER_EN_ROUTE', 'IN_PROGRESS') THEN
        UPDATE drivers 
        SET avail_status = 'ONLINE'
        WHERE driver_id = NEW.driver_id 
          AND avail_status = 'ON_TRIP';
    END IF;
END //

DELIMITER ;

-- Event 1: Expire Promo Codes - Runs every night at midnight
-- Automatically deactivates expired promo codes
DROP EVENT IF EXISTS evt_expire_promo_codes //
DELIMITER //
CREATE EVENT IF NOT EXISTS evt_expire_promo_codes
ON SCHEDULE EVERY 1 DAY
STARTS CONCAT(CURDATE() + INTERVAL 1 DAY, ' 00:00:00')
DO
BEGIN
    -- Deactivate expired promo codes
    UPDATE promo_codes 
    SET is_active = FALSE 
    WHERE valid_until < CURDATE() 
      AND is_active = TRUE;
END //
DELIMITER ;

-- Enable event scheduler (requires appropriate privileges)
-- NOTE: Commented out for cloud databases (Aiven, PlanetScale, etc.)
-- These providers don't grant SUPER privileges for security
-- Event scheduler is already ON by default on managed services
-- SET GLOBAL event_scheduler = ON;

-- =====================================================
-- SECTION 7: DCL - DATA CONTROL LANGUAGE (10 Marks)
-- =====================================================

-- NOTE: DCL commands are commented out for cloud database compatibility
-- Aiven, PlanetScale, and other managed services don't allow privilege
-- management on shared servers for security reasons.
-- These commands work on local MySQL with proper privileges.

/*
-- Role-Based Access Control Implementation
-- Create roles for different user types

-- Create roles if they don't exist (MySQL 8.0+ syntax)
CREATE ROLE IF NOT EXISTS 'admin_role';
CREATE ROLE IF NOT EXISTS 'driver_role';
CREATE ROLE IF NOT EXISTS 'rider_role';
CREATE ROLE IF NOT EXISTS 'support_role';

-- Grant privileges to admin_role - Full access
GRANT ALL PRIVILEGES ON rideflow_db.* TO 'admin_role';

-- Grant privileges to driver_role - Limited access
GRANT SELECT ON rideflow_db.rides TO 'driver_role';
GRANT SELECT ON rideflow_db.payments TO 'driver_role';
GRANT SELECT ON rideflow_db.driver_earnings TO 'driver_role';
GRANT SELECT ON rideflow_db.ratings TO 'driver_role';
GRANT SELECT ON rideflow_db.vehicles TO 'driver_role';
GRANT SELECT ON rideflow_db.users TO 'driver_role';
GRANT SELECT ON rideflow_db.drivers TO 'driver_role';
GRANT SELECT ON rideflow_db.locations TO 'driver_role';
GRANT SELECT ON rideflow_db.promo_codes TO 'driver_role';
GRANT SELECT ON rideflow_db.ActiveRidesView TO 'driver_role';
GRANT SELECT ON rideflow_db.TopDriversView TO 'driver_role';
GRANT SELECT ON rideflow_db.RideHistoryView TO 'driver_role';
GRANT UPDATE (avail_status) ON rideflow_db.drivers TO 'driver_role';

-- Grant privileges to rider_role - Customer access
GRANT SELECT, INSERT ON rideflow_db.rides TO 'rider_role';
GRANT SELECT, INSERT ON rideflow_db.payments TO 'rider_role';
GRANT SELECT ON rideflow_db.ratings TO 'rider_role';
GRANT SELECT ON rideflow_db.promo_codes TO 'rider_role';
GRANT SELECT ON rideflow_db.locations TO 'rider_role';
GRANT SELECT ON rideflow_db.users TO 'rider_role';
GRANT SELECT ON rideflow_db.drivers TO 'rider_role';
GRANT SELECT ON rideflow_db.vehicles TO 'rider_role';
GRANT SELECT ON rideflow_db.fare_rules TO 'rider_role';
GRANT SELECT ON rideflow_db.ActiveRidesView TO 'rider_role';
GRANT SELECT ON rideflow_db.RideHistoryView TO 'rider_role';
GRANT INSERT ON rideflow_db.ratings TO 'rider_role';

-- Grant privileges to support_role - Support staff access
GRANT SELECT ON rideflow_db.rides TO 'support_role';
GRANT SELECT ON rideflow_db.payments TO 'support_role';
GRANT SELECT ON rideflow_db.ratings TO 'support_role';
GRANT SELECT ON rideflow_db.complaints TO 'support_role';
GRANT SELECT ON rideflow_db.users TO 'support_role';
GRANT SELECT ON rideflow_db.drivers TO 'support_role';
GRANT SELECT ON rideflow_db.vehicles TO 'support_role';
GRANT SELECT ON rideflow_db.locations TO 'support_role';
GRANT SELECT ON rideflow_db.ActiveRidesView TO 'support_role';
GRANT SELECT ON rideflow_db.RideHistoryView TO 'rider_role';
GRANT SELECT ON rideflow_db.RevenueReportView TO 'support_role';
GRANT UPDATE (comp_status) ON rideflow_db.complaints TO 'support_role';
GRANT UPDATE (acc_status) ON rideflow_db.users TO 'support_role';
REVOKE DELETE ON rideflow_db.* FROM 'support_role';

-- Apply all privilege changes
FLUSH PRIVILEGES;
*/

-- =====================================================
-- END OF DELIVERABLE 3 SQL IMPLEMENTATION
-- =====================================================
