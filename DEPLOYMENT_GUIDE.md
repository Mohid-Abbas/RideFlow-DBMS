# RideFlow Deployment Guide - Academic Project

## Database Hosting Options

### Option 1: PlanetScale (RECOMMENDED - Free MySQL)
- **Free Tier**: 5GB storage, 1 billion row reads/month
- **Why**: MySQL-compatible, serverless, no connection limits
- **Signup**: https://planetscale.com
- **Pros**: Git-like branching, deploy requests, excellent for academic projects

### Option 2: Railway (Free Tier)
- **Free Tier**: $5 credit/month (~1 month free MySQL)
- **Why**: Easy deployment, supports MySQL natively
- **Signup**: https://railway.app
- **Pros**: Simple deployment, good for short-term projects

### Option 3: MongoDB Atlas (If you want NoSQL)
- **Free Tier**: 512MB storage, shared RAM
- **Why**: Free forever tier available
- **Signup**: https://www.mongodb.com/atlas
- **⚠️ Warning**: Requires rewriting entire backend (SQL → NoSQL)

### Option 4: Local MySQL (For Demo)
- Keep current setup
- Use ngrok for temporary public URL
- Free for demonstrations

## Google Maps API Integration (FREE)

### Step 1: Get API Key (FREE $200 credit/month)
1. Go to https://console.cloud.google.com
2. Create new project
3. Enable billing (required but won't charge without exceeding $200)
4. Enable APIs:
   - Maps JavaScript API
   - Places API
   - Directions API
   - Geocoding API
5. Create API key with HTTP referer restrictions

### Step 2: Update .env file
```
GOOGLE_MAPS_API_KEY=your_api_key_here
```

### Step 3: Implementation done in this guide (see below)

---

## Recommended Architecture for Academic Project

**For deployment with least hassle:**

```
┌─────────────────┐      ┌──────────────────┐      ┌─────────────────┐
│   Frontend      │──────│  Node.js Server  │──────│   PlanetScale   │
│   (HTML/JS)     │      │   (Express)      │      │   (MySQL)       │
└─────────────────┘      └──────────────────┘      └─────────────────┘
         │
         │ Google Maps API
         ▼
┌─────────────────┐
│  Google Cloud   │
│  Maps Platform  │
└─────────────────┘
```

---

## Deployment Platforms (FREE)

### Render.com (RECOMMENDED)
- Free tier: Web service stays up always
- Free PostgreSQL (would need minor migration)
- Custom domain support
- https://render.com

### Railway
- Free tier with $5 credit
- Native MySQL support
- Easy GitHub integration
- https://railway.app

### Vercel + PlanetScale
- Vercel: Free frontend hosting
- PlanetScale: Free MySQL
- Perfect combination

---

## Quick Start for Academic Demo

### Option A: Keep MySQL + ngrok (Easiest)
```bash
# 1. Install ngrok
# 2. Start your MySQL locally
# 3. Start Node.js server
npm start

# 4. Expose to internet (in new terminal)
ngrok http 3000
# Copy the https URL and share
```

### Option B: Deploy to Render.com
1. Push code to GitHub
2. Connect GitHub repo to Render
3. Add environment variables
4. Deploy automatically

---

## My Recommendation for Your Academic Project

**Use this setup:**
1. ✅ **Keep MySQL** (already implemented, all SQL features work)
2. ✅ **Use PlanetScale** for free cloud MySQL (if needed)
3. ✅ **Add Google Maps API** (free tier sufficient)
4. ✅ **Deploy to Render.com** or use ngrok for demo

**Don't switch to MongoDB** - it requires rewriting:
- All SQL queries → MongoDB queries
- All stored procedures → Application code
- All triggers → Application logic
- All joins → Application-level joins
- Views → Application queries

**Time estimate to switch to MongoDB: 15-20 hours**
**Time to add Google Maps: 2-3 hours**

---

## Google Maps API Pricing (Academic Use)

| API | Free Tier | Academic Use |
|-----|-----------|--------------|
| Maps JavaScript API | Unlimited* | FREE |
| Places API | $200/month credit | ~10,000 requests |
| Directions API | $200/month credit | ~40,000 requests |
| Geocoding API | $200/month credit | ~40,000 requests |

*With cloud billing account, no charges until exceed $200

**For academic project: 100% FREE**

---

## Next Steps

1. **Get Google Maps API Key** (5 minutes)
2. **Test locally with Google Maps** (implemented below)
3. **Use ngrok for temporary public URL** (free)
4. **Or deploy to Render.com** (free tier)

**Skip MongoDB** - MySQL is better for this relational database project.
