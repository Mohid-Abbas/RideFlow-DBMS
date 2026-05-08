# PlanetScale Cloud Database Setup Guide

## Why PlanetScale?
- ✅ **FREE** - 5GB storage, 1 billion row reads/month
- ✅ **MySQL Compatible** - No code changes needed
- ✅ **Serverless** - Auto-scales, always available
- ✅ **Git-like Branching** - Create branches for dev/prod
- ✅ **Deploy Requests** - Review schema changes like code reviews

---

## Step 1: Create Account & Database (5 minutes)

### 1.1 Sign Up
1. Go to https://planetscale.com
2. Click "Get Started" → Sign up with GitHub
3. Verify email

### 1.2 Create Database
1. Click "Create Database"
2. Name: `rideflow-db`
3. Region: Choose closest (e.g., `ap-south-1` for Asia)
4. Click "Create Database"

### 1.3 Create Schema
```sql
-- Go to "Console" tab in PlanetScale dashboard
-- Paste your schema from rideflow_relational_schema.sql

CREATE TABLE users (
  user_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('ADMIN', 'SUPER_ADMIN', 'RIDER', 'DRIVER') NOT NULL DEFAULT 'RIDER',
  acc_status ENUM('ACTIVE', 'SUSPENDED', 'BANNED') NOT NULL DEFAULT 'ACTIVE',
  reg_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  wallet_balance DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  CONSTRAINT uk_users_email UNIQUE (email),
  CONSTRAINT uk_users_phone UNIQUE (phone)
) ENGINE=InnoDB;

-- Continue with all other tables...
```

### 1.4 Run SQL Files
1. Go to PlanetScale Console
2. Copy-paste contents of `rideflow_relational_schema.sql`
3. Then `rideflow_deliverable3_advanced_sql.sql`
4. Then `rideflow_seed_data.sql`

---

## Step 2: Get Connection Credentials

### 2.1 Create Password
1. In PlanetScale dashboard, click "Connect"
2. Select "Connect with: `@planetscale/database`" 
3. OR select "MySQL" for traditional connection
4. Create password: Click "New Password"
5. Copy the credentials

### 2.2 Connection String Format
```
Database: rideflow-db
Username: xxxxxxx
Password: pscale_pw_xxxxxxxx
Host: xxxxxxx.ap-south-1.psdb.cloud
Port: 3306
```

---

## Step 3: Update .env File

### Option A: Using @planetscale/database (Recommended)
Update `app/.env`:
```env
# PlanetScale Database (Recommended)
DB_HOST=xxxxxxx.ap-south-1.psdb.cloud
DB_USER=xxxxxxx
DB_PASSWORD=pscale_pw_xxxxxxxx
DB_NAME=rideflow-db

# For @planetscale/database driver
DATABASE_URL=mysql://xxxxxxx:pscale_pw_xxxxxxxx@xxxxxxx.ap-south-1.psdb.cloud/rideflow-db?sslaccept=strict

# Server
PORT=3000
SESSION_SECRET=rideflow_secret_key_2026_cloud
```

### Option B: Using mysql2 with SSL (Traditional)
```env
DB_HOST=xxxxxxx.ap-south-1.psdb.cloud
DB_USER=xxxxxxx
DB_PASSWORD=pscale_pw_xxxxxxxx
DB_NAME=rideflow-db
DB_SSL=true
DB_SSL_REJECT_UNAUTHORIZED=false
PORT=3000
SESSION_SECRET=rideflow_secret_key_2026_cloud
```

---

## Step 4: Update server.js for PlanetScale

### Option A: Using @planetscale/database (Best)
Install driver:
```bash
cd app
npm install @planetscale/database
```

Update connection in `server.js`:
```javascript
// Replace mysql2/promise with PlanetScale
const { connect } = require('@planetscale/database');

const config = {
  host: process.env.DB_HOST,
  username: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
};

const conn = connect(config);
```

### Option B: Using mysql2 with SSL (Keep Current Code)
Just update `.env` and add SSL options:
```javascript
const dbConfig = {
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    ssl: {
        rejectUnauthorized: true
    },
    waitForConnections: true,
    connectionLimit: 10
};
```

---

## Step 5: Test Connection

### 5.1 Start Server
```bash
cd app
npm start
```

### 5.2 Check Console
You should see:
```
=================================
  RideFlow Server Running
  Port: 3000
  Database: rideflow-db (PlanetScale)
=================================
```

### 5.3 Test in Browser
- http://localhost:3000/login
- Login with test accounts
- Verify data loads from cloud

---

## Step 6: Branching (Optional but Cool)

### Create Dev Branch
1. In PlanetScale dashboard
2. Click "Branches" → "Create Branch"
3. Name: `development`
4. Make schema changes safely
5. Create "Deploy Request" to merge to main

---

## Troubleshooting

### Connection Timeout?
- Check firewall allows port 3306
- Verify SSL settings
- Check PlanetScale dashboard for outages

### SSL Error?
```javascript
// In server.js, add this to dbConfig
ssl: {
    rejectUnauthorized: false  // For development only
}
```

### Authentication Error?
- Regenerate password in PlanetScale
- Update .env file
- Restart server

---

## Quick Reference

| Task | Command/Link |
|------|--------------|
| Dashboard | https://app.planetscale.com |
| Create DB | Click "Create Database" |
| Connect | Click "Connect" button |
| Console | Dashboard → Console tab |
| Branches | Dashboard → Branches tab |
| Passwords | Dashboard → Settings → Passwords |

---

## Next Steps

1. ✅ Sign up at PlanetScale
2. ✅ Create `rideflow-db` database
3. ✅ Import SQL schema
4. ✅ Copy credentials to `.env`
5. ✅ Test local connection
6. ✅ Deploy to Render/Vercel

---

**Questions?**
- PlanetScale Docs: https://planetscale.com/docs
- MySQL Compatibility: https://planetscale.com/docs/reference/mysql-compatibility

---

**Ready to make your UI ultra-modern next!** 🎨
