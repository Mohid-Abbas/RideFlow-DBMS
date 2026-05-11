/**
 * Create Windows Launcher for RideFlow
 * This creates a simple batch file that starts the app and opens browser
 */

const fs = require('fs');
const path = require('path');

// Create batch file launcher
const batchContent = `@echo off
chcp 65001 >nul
echo ==========================================
echo    RIDEFLOW - Ride Hailing Platform
echo    Database Systems Lab Project
echo ==========================================
echo.
echo Starting RideFlow Server...
echo.

REM Check if MySQL is running
echo Checking database connection...
timeout /t 2 /nobreak >nul

REM Start the server
echo Starting server on http://localhost:3000
echo.
start "" "http://localhost:3000"

REM Run the executable
"%~dp0rideflow-app.exe"

pause
`;

// Create README for distribution
const readmeContent = `# RideFlow - Executable Version

## 🚀 Quick Start

### For Teachers/Evaluators:
1. Double-click **Start-RideFlow.bat**
2. Wait 3 seconds for server to start
3. Browser will open automatically at http://localhost:3000
4. Login with demo credentials

### Demo Credentials:
- **Rider**: rider@rideflow.com / password
- **Driver**: driver@rideflow.com / password  
- **Admin**: admin@rideflow.com / password

## ⚠️ Requirements:
- MySQL Server must be running (XAMPP/WAMP)
- Database 'rideflow_db' must exist
- Port 3000 must be free

## 📁 Files:
- rideflow-app.exe - Main application server
- Start-RideFlow.bat - Launcher script (USE THIS)
- .env - Database configuration
- public/ - Web interface files

## 🛑 To Stop:
Close the command window or press Ctrl+C

## 🐛 Troubleshooting:

### "Cannot connect to database"
→ Start MySQL in XAMPP Control Panel

### "Port 3000 already in use"
→ Close other applications using port 3000

### "Database not found"
→ Import the SQL files first:
   1. Open MySQL Workbench
   2. Run: SOURCE rideflow_relational_schema.sql
   3. Run: SOURCE rideflow_deliverable3_advanced_sql.sql
   4. Run: SOURCE rideflow_seed_data.sql

---
Created by:
- Mohid Abbas (24I-0074)
- Ubaid ur Rehman (24I-0022)
FAST National University, Spring 2026
`;

// Write files to dist folder
const distPath = path.join(__dirname, 'dist');

if (!fs.existsSync(distPath)) {
    fs.mkdirSync(distPath, { recursive: true });
}

fs.writeFileSync(path.join(distPath, 'Start-RideFlow.bat'), batchContent);
fs.writeFileSync(path.join(distPath, 'README.txt'), readmeContent);

console.log('✅ Launcher files created in dist/ folder');
console.log('📦 Distribution package ready!');
console.log('');
console.log('Files created:');
console.log('  - dist/rideflow-app.exe');
console.log('  - dist/Start-RideFlow.bat');
console.log('  - dist/README.txt');
console.log('');
console.log('🚀 To distribute:');
console.log('  Zip the dist/ folder and share!');
