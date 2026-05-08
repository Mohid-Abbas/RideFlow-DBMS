# Aiven Free MySQL Database Setup Guide

## Why Aiven?
- ✅ **FREE** - 5GB storage (no credit card required)
- ✅ **MySQL 8.0** - Full compatibility
- ✅ **SSL included** - Secure by default
- ✅ **Global regions** - Choose closest to you
- ✅ **No expiration** - Free tier is forever

---

## Step 1: Create Aiven Account (2 minutes)

1. Go to **https://aiven.io**
2. Click **"Sign Up"** (top right)
3. Sign up with:
   - Email + Password, OR
   - Google/GitHub account
4. Verify your email

---

## Step 2: Create MySQL Service (5 minutes)

### 2.1 Create New Service
1. Click **"Create Service"** (big blue button)
2. Select **"MySQL"** from the database options

### 2.2 Select Plan (IMPORTANT!)
- Choose **"Hobbyist"** or **"Free"** plan
- If not visible: Look for **"Startup-4"** or similar free tier
- **Cost should show: $0.00**

### 2.3 Select Region
Choose closest to your location:
- **Asia**: `ap-south-1` (Mumbai) or `ap-southeast-1` (Singapore)
- **Europe**: `eu-west-1` (Ireland) or `eu-central-1` (Frankfurt)
- **USA**: `us-east-1` (Virginia) or `us-west-2` (Oregon)

### 2.4 Service Name
```
Service name: rideflow-mysql
Project: default (or create new)
```

### 2.5 Click "Create Service"
Wait 2-3 minutes for the service to start (status turns green)

---

## Step 3: Get Connection Details

### 3.1 Overview Tab
Once service is running:
1. Click on your **rideflow-mysql** service
2. Go to **"Overview"** tab

### 3.2 Copy These Values
```
Host:       mysql-xxxxxxxx-xxxxx.aivencloud.com
Port:       22256 (or different)
Database:   defaultdb
User:       avnadmin
Password:   [Click "Show Password"]
```

### 3.3 Download CA Certificate (IMPORTANT!)
1. Go to **"Overview"** tab
2. Click **"CA Certificate"** dropdown
3. Click **"Download"** or **"Show"**
4. Save the certificate content (you'll need it)

---

## Step 4: Update .env File

### 4.1 Create/Update `app/.env`:
```env
# ============================================
# AIVEN CLOUD DATABASE (Free 5GB)
# ============================================
DB_HOST=mysql-xxxxxxxx-xxxxx.aivencloud.com
DB_PORT=22256
DB_USER=avnadmin
DB_PASSWORD=YOUR_PASSWORD_HERE
DB_NAME=defaultdb
DB_SSL=true
DB_SSL_CA_PATH=./ca-certificate.crt  # Path to downloaded cert

# ============================================
# SERVER CONFIGURATION
# ============================================
PORT=3000
NODE_ENV=production

# ============================================
# SECURITY - Generate strong secret
# ============================================
# Run: node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
SESSION_SECRET=your_super_secret_key_here_64_characters_long_minimum

# ============================================
# GOOGLE MAPS API (Optional)
# ============================================
# Get from: https://console.cloud.google.com
GOOGLE_MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY
```

---

## Step 5: Save CA Certificate

### Option A: In Project Root
1. Create file: `ca-certificate.crt`
2. Paste the certificate content from Aiven
3. Keep in same folder as `app/`

### Option B: In App Folder
1. Create file: `app/ca-certificate.crt`
2. Paste certificate content
3. Update `.env`: `DB_SSL_CA_PATH=./ca-certificate.crt`

**Certificate file should look like:**
```
-----BEGIN CERTIFICATE-----
MIIDXTCCAkWgAwIBAgIJAJC1HiIAZAiUMA0GCSqGSIb3Qa3BajELMAkGA1UEBhMC
... (more lines)
-----END CERTIFICATE-----
```

---

## Step 6: Update server.js for Aiven

### 6.1 Update Database Connection
Open `app/server.js` and update the pool configuration:

```javascript
const fs = require('fs');
const path = require('path');

const dbConfig = {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT || 3306,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    ssl: process.env.DB_SSL === 'true' ? {
        ca: fs.readFileSync(path.join(__dirname, process.env.DB_SSL_CA_PATH)),
        rejectUnauthorized: true
    } : false,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
};

const pool = mysql.createPool(dbConfig);
```

### 6.2 Test Connection
Add this test after creating pool:
```javascript
pool.getConnection()
    .then(conn => {
        console.log('✅ Aiven MySQL Connected!');
        conn.release();
    })
    .catch(err => {
        console.error('❌ Database connection failed:', err.message);
    });
```

---

## Step 7: Import Database Schema

### Option A: Using Aiven Console
1. In Aiven dashboard, go to **"Queries"** or **"Connect"** tab
2. Click **"MySQL CLI"** or use built-in query editor
3. Run your SQL files in order:
   ```sql
   -- First: Schema
   SOURCE /path/to/rideflow_relational_schema.sql;
   
   -- Second: Advanced SQL
   SOURCE /path/to/rideflow_deliverable3_advanced_sql.sql;
   
   -- Third: Seed Data
   SOURCE /path/to/rideflow_seed_data.sql;
   ```

### Option B: Using Local MySQL Client
```bash
# Connect to Aiven MySQL
mysql --host=mysql-xxxxxxxx-xxxxx.aivencloud.com \
      --port=22256 \
      --user=avnadmin \
      --password \
      --ssl-mode=REQUIRED \
      defaultdb

# Then run:
SOURCE rideflow_relational_schema.sql;
SOURCE rideflow_deliverable3_advanced_sql.sql;
SOURCE rideflow_seed_data.sql;
```

### Option C: Using MySQL Workbench
1. Open MySQL Workbench
2. Click **"+"** to add new connection
3. Configure:
   - Hostname: `mysql-xxxxxxxx-xxxxx.aivencloud.com`
   - Port: `22256`
   - Username: `avnadmin`
   - Password: [Your password]
   - SSL: **REQUIRED**
   - SSL CA File: [Select your ca-certificate.crt]
4. Test connection
5. Run SQL files

---

## Step 8: Test Locally

### 8.1 Start Server
```bash
cd app
npm start
```

### 8.2 Check Console Output
You should see:
```
=================================
  RideFlow Server Running
  Port: 3000
  Database: Aiven MySQL (Cloud)
=================================
  ✅ Connected to Aiven MySQL
=================================
```

### 8.3 Test in Browser
- http://localhost:3000/login-modern
- Login with test credentials
- Verify data loads from cloud

---

## Step 9: Deploy Application

### Deploy to Render.com with Aiven
1. Push code to GitHub
2. Create new Web Service on Render
3. Add Environment Variables:
   ```
   DB_HOST=mysql-xxxxxxxx-xxxxx.aivencloud.com
   DB_PORT=22256
   DB_USER=avnadmin
   DB_PASSWORD=your_password
   DB_NAME=defaultdb
   DB_SSL=true
   DB_SSL_CA_PATH=./ca-certificate.crt
   SESSION_SECRET=your_generated_secret
   ```
4. Upload `ca-certificate.crt` as file (or paste content as env var)
5. Deploy!

---

## Troubleshooting

### "SSL connection error"
- Ensure CA certificate is correctly saved
- Verify `DB_SSL_CA_PATH` points to correct file
- Check certificate content is complete (BEGIN/END lines)

### "Access denied"
- Double-check password (no extra spaces)
- Verify service is running (green status in Aiven)
- Check if IP is allowed (Aiven allows all by default)

### "Connection timeout"
- Verify host and port are correct
- Check firewall/antivirus not blocking
- Try different region closer to you

### "Unknown database"
- Use `defaultdb` as database name initially
- Can create `rideflow_db` after first connection

---

## Aiven Free Tier Limits

| Feature | Free Tier |
|---------|-----------|
| Storage | 5GB |
| Connections | 25 concurrent |
| Backups | Daily backups included |
| SSL | Required (secure) |
| Regions | All available |
| Expiration | Never expires |

---

## Quick Reference

**Aiven Dashboard**: https://console.aiven.io

**Service Status**: Green = Running, Yellow = Building, Red = Error

**Connection String Format**:
```
mysql://avnadmin:password@mysql-host.aivencloud.com:22256/defaultdb?ssl-mode=REQUIRED
```

**SSL Certificate**: Always required for Aiven connections

---

## Next Steps

1. ✅ Create Aiven account
2. ✅ Create MySQL service (Hobbyist/Free plan)
3. ✅ Download CA certificate
4. ✅ Update .env file
5. ✅ Import SQL schema
6. ✅ Test local connection
7. ✅ Deploy application

---

**Questions?**
- Aiven Docs: https://aiven.io/docs
- MySQL Help: https://aiven.io/docs/products/mysql

**Need help with the certificate or connection?** Ask me!
