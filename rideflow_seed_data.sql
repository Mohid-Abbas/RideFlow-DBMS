-- RideFlow Seed Data for Testing
-- Run this after creating the database schema

USE rideflow_db;

-- Insert Users (Riders, Drivers, Admin)
-- Passwords are hashed using bcrypt (password: 'password')
INSERT INTO users (full_name, email, phone, password_hash, role, acc_status) VALUES
-- Admin
('System Administrator', 'admin@rideflow.com', '03001234567', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'ADMIN', 'ACTIVE'),
-- Riders
('Ahmed Khan', 'rider@rideflow.com', '03011234567', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'RIDER', 'ACTIVE'),
('Fatima Ali', 'fatima@rideflow.com', '03021234567', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'RIDER', 'ACTIVE'),
('Omar Hassan', 'omar@rideflow.com', '03031234567', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'RIDER', 'ACTIVE'),
('Sana Iqbal', 'sana@rideflow.com', '03041234567', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'RIDER', 'ACTIVE'),
('Bilal Ahmad', 'bilal@rideflow.com', '03051234567', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'RIDER', 'SUSPENDED'),
-- Drivers
('Muhammad Ali', 'driver@rideflow.com', '03111234567', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'DRIVER', 'ACTIVE'),
('Kamran Shah', 'kamran@rideflow.com', '03121234567', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'DRIVER', 'ACTIVE'),
('Imran Qureshi', 'imran@rideflow.com', '03131234567', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'DRIVER', 'ACTIVE'),
('Rashid Mehmood', 'rashid@rideflow.com', '03141234567', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'DRIVER', 'ACTIVE'),
('Tariq Aziz', 'tariq@rideflow.com', '03151234567', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'DRIVER', 'ACTIVE');

-- Insert Drivers (linked to user accounts)
INSERT INTO drivers (user_id, license_num, cnic, verif_status, avail_status, avg_rating, total_trips, wallet_balance) VALUES
(7, 'LHR-2018-001', '35201-1234567-1', 'VERIFIED', 'ONLINE', 4.75, 156, 45000.00),
(8, 'LHR-2019-002', '35201-2345678-2', 'VERIFIED', 'OFFLINE', 4.50, 89, 28000.00),
(9, 'LHR-2020-003', '35201-3456789-3', 'VERIFIED', 'ONLINE', 4.85, 234, 62000.00),
(10, 'LHR-2021-004', '35201-4567890-4', 'PENDING', 'OFFLINE', 3.20, 12, 5000.00),
(11, 'LHR-2022-005', '35201-5678901-5', 'VERIFIED', 'ONLINE', 4.60, 178, 55000.00);

-- Insert Locations (Cities: Lahore, Karachi, Islamabad)
INSERT INTO locations (latitude, longitude, city, address, label) VALUES
-- Lahore
(31.5204, 74.3587, 'Lahore', 'Allama Iqbal International Airport', 'Airport'),
(31.4854, 74.3260, 'Lahore', 'Gulberg Main Boulevard', 'Gulberg'),
(31.5546, 74.3576, 'Lahore', 'Badshahi Mosque', 'Old City'),
(31.4669, 74.3863, 'Lahore', 'DHA Phase 5', 'DHA'),
(31.5200, 74.4100, 'Lahore', 'Johar Town', 'Johar Town'),
(31.5820, 74.3800, 'Lahore', 'University of the Punjab', 'University Area'),
-- Karachi
(24.8607, 67.0011, 'Karachi', 'Jinnah International Airport', 'Airport'),
(24.8142, 67.0504, 'Karachi', 'Clifton Beach', 'Clifton'),
(24.9180, 67.0971, 'Karachi', 'Gulshan-e-Iqbal', 'Gulshan'),
(24.8847, 67.1754, 'Karachi', 'National Stadium', 'Stadium'),
-- Islamabad
(33.6844, 73.0479, 'Islamabad', 'Benazir Bhutto International Airport', 'Airport'),
(33.7295, 73.0372, 'Islamabad', 'Faisal Mosque', 'Faisal Mosque'),
(33.7074, 73.0983, 'Islamabad', 'DHA Phase 2', 'DHA Islamabad'),
(33.5651, 73.0169, 'Islamabad', 'Pakistan Monument', 'Shakarparian');

-- Insert Fare Rules
INSERT INTO fare_rules (vehicle_type, base_rate, per_km_rate, per_min_rate, surge_multiplier, is_surge_active) VALUES
('ECONOMY', 100.00, 15.00, 3.00, 1.50, TRUE),
('PREMIUM', 200.00, 30.00, 6.00, 1.75, TRUE),
('BIKE', 50.00, 8.00, 1.50, 1.25, TRUE);

-- Insert Vehicles
INSERT INTO vehicles (driver_id, make, model, vehicle_year, color, license_plate, vehicle_type, verif_status) VALUES
(1, 'Toyota', 'Corolla', 2020, 'White', 'LHR-1234', 'ECONOMY', 'VERIFIED'),
(1, 'Honda', 'Civic', 2021, 'Black', 'LHR-5678', 'PREMIUM', 'VERIFIED'),
(2, 'Suzuki', 'Alto', 2019, 'Silver', 'LHR-9012', 'ECONOMY', 'VERIFIED'),
(3, 'Toyota', 'Yaris', 2022, 'Blue', 'LHR-3456', 'ECONOMY', 'VERIFIED'),
(3, 'Honda', 'City', 2021, 'Red', 'LHR-7890', 'PREMIUM', 'VERIFIED'),
(4, 'United', 'US-125', 2020, 'Black', 'LHR-1111', 'BIKE', 'PENDING'),
(5, 'Suzuki', 'Cultus', 2020, 'Grey', 'LHR-2222', 'ECONOMY', 'VERIFIED'),
(5, 'Yamaha', 'YBR-125', 2021, 'Blue', 'LHR-3333', 'BIKE', 'VERIFIED');

-- Insert Promo Codes
INSERT INTO promo_codes (code, discount_pct, valid_until, max_uses, is_active) VALUES
('WELCOME20', 20.00, DATE_ADD(CURDATE(), INTERVAL 30 DAY), 100, TRUE),
('RIDEFLOW50', 50.00, DATE_ADD(CURDATE(), INTERVAL 7 DAY), 50, TRUE),
('LAHORE10', 10.00, DATE_ADD(CURDATE(), INTERVAL 14 DAY), 200, TRUE),
('WEEKEND25', 25.00, DATE_ADD(CURDATE(), INTERVAL 5 DAY), 75, TRUE),
('EXPIRED50', 50.00, DATE_SUB(CURDATE(), INTERVAL 5 DAY), 10, FALSE),
('MORNING15', 15.00, DATE_ADD(CURDATE(), INTERVAL 60 DAY), 150, TRUE);

-- Insert Rides (Sample ride history)
INSERT INTO rides (rider_id, driver_id, vehicle_id, pickup_loc_id, dropoff_loc_id, fare_rule_id, requested_at, scheduled_at, duration_min, distance_km, ride_status, fare) VALUES
-- Completed rides
(2, 1, 1, 1, 3, 1, DATE_SUB(CURDATE(), INTERVAL 2 DAY), NULL, 25, 8.5, 'COMPLETED', 227.50),
(2, 1, 1, 4, 2, 1, DATE_SUB(CURDATE(), INTERVAL 1 DAY), NULL, 18, 6.2, 'COMPLETED', 193.00),
(3, 2, 3, 2, 5, 1, DATE_SUB(CURDATE(), INTERVAL 3 DAY), NULL, 22, 7.0, 'COMPLETED', 205.00),
(4, 3, 4, 3, 1, 1, DATE_SUB(CURDATE(), INTERVAL 5 DAY), NULL, 35, 12.0, 'COMPLETED', 280.00),
(5, 5, 7, 4, 6, 1, DATE_SUB(CURDATE(), INTERVAL 1 DAY), NULL, 15, 5.5, 'COMPLETED', 182.50),
-- Cancelled rides
(2, 1, 1, 1, 4, 1, DATE_SUB(CURDATE(), INTERVAL 4 DAY), NULL, 0, 0, 'CANCELLED', 0.00),
(3, 3, 4, 2, 3, 1, DATE_SUB(CURDATE(), INTERVAL 6 DAY), NULL, 0, 0, 'CANCELLED', 0.00),
-- Active/In Progress rides
(2, 1, 1, 1, 5, 1, DATE_SUB(NOW(), INTERVAL 30 MINUTE), NULL, 0, 0, 'IN_PROGRESS', 175.00),
(4, 5, 7, 4, 2, 1, DATE_SUB(NOW(), INTERVAL 45 MINUTE), NULL, 0, 0, 'DRIVER_EN_ROUTE', 192.50),
-- Requested rides
(5, 1, 1, 6, 1, 1, DATE_SUB(NOW(), INTERVAL 5 MINUTE), NULL, 0, 0, 'REQUESTED', 165.00);

-- Insert Payments
INSERT INTO payments (ride_id, rider_id, promo_id, payment_method, amount, payment_status, txn_date, promo_discount) VALUES
(1, 2, 1, 'CASH', 182.00, 'PAID', DATE_SUB(CURDATE(), INTERVAL 2 DAY), 45.50),
(2, 2, NULL, 'CARD', 193.00, 'PAID', DATE_SUB(CURDATE(), INTERVAL 1 DAY), 0.00),
(3, 3, NULL, 'WALLET', 205.00, 'PAID', DATE_SUB(CURDATE(), INTERVAL 3 DAY), 0.00),
(4, 4, 2, 'CASH', 140.00, 'PAID', DATE_SUB(CURDATE(), INTERVAL 5 DAY), 140.00),
(5, 5, NULL, 'CARD', 182.50, 'PAID', DATE_SUB(CURDATE(), INTERVAL 1 DAY), 0.00),
(6, 2, NULL, 'CASH', 0.00, 'FAILED', DATE_SUB(CURDATE(), INTERVAL 4 DAY), 0.00),
(8, 4, NULL, 'WALLET', 192.50, 'PENDING', NOW(), 0.00),
(9, 5, 3, 'CASH', 148.50, 'PENDING', NOW(), 16.50);

-- Insert Driver Earnings
INSERT INTO driver_earnings (ride_id, driver_id, gross_fare, commission_pct, net_earning, payout_status) VALUES
(1, 1, 227.50, 20.00, 182.00, 'PAID'),
(2, 1, 193.00, 20.00, 154.40, 'PAID'),
(3, 2, 205.00, 20.00, 164.00, 'PAID'),
(4, 3, 280.00, 20.00, 224.00, 'PAID'),
(5, 5, 182.50, 20.00, 146.00, 'PAID'),
(7, 1, 175.00, 20.00, 140.00, 'PENDING'),
(8, 5, 192.50, 20.00, 154.00, 'PENDING');

-- Insert Ratings
INSERT INTO ratings (ride_id, rated_by, rated_user, score, comment, rated_at) VALUES
-- Ride 1: Both rated each other
(1, 2, 7, 5, 'Excellent driver, very professional!', DATE_SUB(CURDATE(), INTERVAL 2 DAY)),
(1, 7, 2, 5, 'Great rider, punctual and polite!', DATE_SUB(CURDATE(), INTERVAL 2 DAY)),
-- Ride 2: Both rated
(2, 2, 7, 4, 'Good ride, smooth driving', DATE_SUB(CURDATE(), INTERVAL 1 DAY)),
(2, 7, 2, 5, 'Nice rider', DATE_SUB(CURDATE(), INTERVAL 1 DAY)),
-- Ride 3: Both rated
(3, 3, 8, 5, 'Very good service', DATE_SUB(CURDATE(), INTERVAL 3 DAY)),
(3, 8, 3, 4, 'Good experience', DATE_SUB(CURDATE(), INTERVAL 3 DAY)),
-- Ride 4: Both rated
(4, 4, 9, 5, 'Excellent service!', DATE_SUB(CURDATE(), INTERVAL 5 DAY)),
(4, 9, 4, 5, 'Polite and friendly rider', DATE_SUB(CURDATE(), INTERVAL 5 DAY)),
-- Ride 5: Both rated
(5, 5, 11, 4, 'Good ride', DATE_SUB(CURDATE(), INTERVAL 1 DAY)),
(5, 11, 5, 5, 'Nice person', DATE_SUB(CURDATE(), INTERVAL 1 DAY)),
-- Low ratings to test trigger (Driver 10 should be flagged)
(20, 2, 10, 2, 'Late arrival', DATE_SUB(CURDATE(), INTERVAL 10 DAY)),
(21, 3, 10, 1, 'Poor driving', DATE_SUB(CURDATE(), INTERVAL 9 DAY)),
(22, 4, 10, 2, 'Car was not clean', DATE_SUB(CURDATE(), INTERVAL 8 DAY)),
(23, 5, 10, 2, 'Not professional', DATE_SUB(CURDATE(), INTERVAL 7 DAY)),
(24, 2, 10, 1, 'Bad experience', DATE_SUB(CURDATE(), INTERVAL 6 DAY));

-- Insert Complaints
INSERT INTO complaints (ride_id, filed_by, against_user, description, comp_status, filed_at) VALUES
(1, 2, 7, 'Driver was late by 5 minutes', 'RESOLVED', DATE_SUB(CURDATE(), INTERVAL 2 DAY)),
(3, 3, 8, 'AC was not working properly', 'IN_PROGRESS', DATE_SUB(CURDATE(), INTERVAL 3 DAY)),
(5, 5, 11, 'Driver took longer route', 'OPEN', DATE_SUB(CURDATE(), INTERVAL 1 DAY));

-- Update driver average ratings based on ratings data
UPDATE drivers d
SET avg_rating = (
    SELECT AVG(score)
    FROM ratings r
    WHERE r.rated_user = d.user_id
),
total_trips = (
    SELECT COUNT(*)
    FROM rides rd
    WHERE rd.driver_id = d.driver_id AND rd.ride_status = 'COMPLETED'
);

-- Update rider wallet balances
UPDATE users 
SET wallet_balance = CASE user_id
    WHEN 2 THEN 500.00
    WHEN 3 THEN 1200.00
    WHEN 4 THEN 0.00
    WHEN 5 THEN 2500.00
    ELSE wallet_balance
END
WHERE role = 'RIDER';

SELECT 'Seed data inserted successfully!' AS message;
SELECT 'Users:', COUNT(*) FROM users;
SELECT 'Drivers:', COUNT(*) FROM drivers;
SELECT 'Rides:', COUNT(*) FROM rides;
SELECT 'Payments:', COUNT(*) FROM payments;
SELECT 'Ratings:', COUNT(*) FROM ratings;
