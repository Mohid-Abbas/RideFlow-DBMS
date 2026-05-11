# 🚀 Create RideFlow Executable

This guide shows you how to create a standalone Windows executable (.exe) that anyone can run without installing Node.js!

## 📦 What You'll Get

After building:
```
dist/
├── RideFlow.exe          ← Main executable (double-click to run)
├── Start-RideFlow.bat    ← Launcher with instructions
├── README.txt            ← User guide
└── public/               ← Website files
```

## ⚙️ Prerequisites

1. **Node.js** installed (v14 or higher)
2. **MySQL** running with rideflow_db created
3. All SQL files imported:
   - `rideflow_relational_schema.sql`
   - `rideflow_deliverable3_advanced_sql.sql`
   - `rideflow_seed_data.sql`

## 🛠️ Build Instructions

### Step 1: Install Dependencies

```bash
cd "d:\Projects\DB Project\RideFlow-DBMS\app"
npm install
```

### Step 2: Build the Executable

```bash
npm run build
```

This will:
1. Package the app into `dist/RideFlow.exe`
2. Create `Start-RideFlow.bat` launcher
3. Copy necessary files

### Step 3: Test the Executable

```bash
cd dist
Start-RideFlow.bat
```

The browser should open automatically at `http://localhost:3000`

## 📤 Distribute to Teacher/Evaluator

### Option A: Simple ZIP (Recommended)
1. Zip the `dist/` folder
2. Include this note:

```
🚀 RIDE FLOW - Quick Start

1. Unzip the file
2. Double-click "Start-RideFlow.bat"
3. Wait 3 seconds for browser to open
4. Login with:
   - rider@rideflow.com / password
   - driver@rideflow.com / password
   - admin@rideflow.com / password

⚠️ Requirements:
- MySQL must be running (XAMPP)
- Database 'rideflow_db' must exist
```

### Option B: One-Click Installer (Advanced)
Use Inno Setup to create professional installer

## 🔧 Troubleshooting

### "pkg not found"
```bash
npm install -g pkg
```

### "Cannot connect to database"
Make sure MySQL is running before starting the app

### "Port 3000 in use"
```bash
# Find and kill process
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

## 🎯 What Makes It Work

1. **pkg** - Packages Node.js + your app into single .exe
2. **open** package - Auto-opens browser
3. **.env** - Database credentials included
4. **public/** - Frontend files embedded

## 📊 File Sizes

- Original project: ~50MB
- Executable: ~45MB (includes Node.js runtime)
- Final ZIP: ~15MB (compressed)

## ✨ Features of the Executable

- ✅ No Node.js installation required
- ✅ No command line needed
- ✅ Auto-opens browser
- ✅ Works on any Windows PC
- ✅ Includes all web files
- ✅ Database auto-connects

## 🎓 For Your Teacher

Your teacher can:
1. Download the ZIP
2. Extract to any folder
3. Double-click `Start-RideFlow.bat`
4. Browser opens automatically
5. Test all features immediately

No technical knowledge required! 🎉

---

## 🚀 Alternative: Electron Desktop App

For a more professional desktop app (like VS Code), use Electron:

```bash
npm install electron
```

This creates a proper Windows application with:
- Native window (no browser needed)
- Menu bar and icons
- System tray integration
- Auto-updater

But requires more setup. The .exe method above is perfect for academic demos!

---

**Questions? Check PROJECT_SUMMARY.md or ask!**
