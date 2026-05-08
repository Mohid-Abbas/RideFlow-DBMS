# Google Maps API Setup Guide for RideFlow

## Overview
This guide helps you integrate real Google Maps API for location search, route calculation, and fare estimation.

---

## Step 1: Get Your FREE Google Maps API Key

### 1.1 Create Google Cloud Account
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Sign in with your Google account
3. Click "Select a project" → "New Project"
4. Name it: `RideFlow-Project`
5. Click "Create"

### 1.2 Enable Billing (FREE - Won't Charge)
1. Go to [Billing](https://console.cloud.google.com/billing)
2. Click "Link a billing account"
3. Add a payment method (required but **FREE $200/month credit**)
4. You **WON'T** be charged unless you exceed $200/month

### 1.3 Enable Required APIs
1. Go to [APIs & Services → Library](https://console.cloud.google.com/apis/library)
2. Search and enable these APIs:
   - ✅ **Maps JavaScript API** - For displaying maps
   - ✅ **Places API** - For location search autocomplete
   - ✅ **Directions API** - For route calculation
   - ✅ **Geocoding API** - For address to coordinates conversion

### 1.4 Create API Key
1. Go to [Credentials](https://console.cloud.google.com/apis/credentials)
2. Click "Create Credentials" → "API Key"
3. Copy your API key (looks like: `AIzaSyB...`)
4. Click "Restrict Key" for security:
   - Application restrictions: **HTTP referrers**
   - Add your domain or `localhost:3000/*` for testing

---

## Step 2: Add API Key to Project

### 2.1 Update HTML File
Open `app/public/rider/book-with-maps.html`:

```html
<!-- Replace this line -->
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&libraries=places&callback=initMap" async defer></script>

<!-- With your actual key -->
<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyB...YOUR_KEY...&libraries=places&callback=initMap" async defer></script>
```

### 2.2 Alternative: Use Environment Variable (Recommended for Production)
Add to `.env`:
```
GOOGLE_MAPS_API_KEY=AIzaSyB...YOUR_KEY...
```

---

## Step 3: Test the Integration

### 3.1 Start the Server
```bash
cd app
npm start
```

### 3.2 Access Maps Booking
1. Login as a rider: http://localhost:3000/login
2. Go to: http://localhost:3000/rider/book-with-maps

### 3.3 Test Features
- ✅ Search pickup location (autocomplete)
- ✅ Search dropoff location (autocomplete)
- ✅ See route on map
- ✅ View distance and duration
- ✅ Get accurate fare estimate
- ✅ Book ride with real coordinates

---

## Pricing (FREE for Academic Use)

| API | Monthly Free Tier | Academic Use |
|-----|-------------------|--------------|
| Maps JavaScript API | Unlimited* | FREE |
| Places API | $200 credit | ~10,000 requests |
| Directions API | $200 credit | ~40,000 requests |
| Geocoding API | $200 credit | ~40,000 requests |

*With cloud billing account, no charges until exceed $200/month

**For your academic project: 100% FREE**

---

## Deployment Options

### Option A: ngrok (Quick Demo - FREE)
Expose your local server to internet:
```bash
# Install ngrok
choco install ngrok

# Or download from https://ngrok.com

# Start your app
npm start

# In another terminal
ngrok http 3000

# Copy the https URL and share
```

### Option B: Render.com (FREE Hosting)
1. Push code to GitHub
2. Sign up at [Render.com](https://render.com)
3. Create "Web Service" from GitHub
4. Add environment variables:
   - `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`
   - `GOOGLE_MAPS_API_KEY`
   - `SESSION_SECRET`
5. Deploy automatically

### Option C: PlanetScale + Vercel (FREE Database + Hosting)
1. **Database**: [PlanetScale](https://planetscale.com) - Free MySQL
2. **Hosting**: [Vercel](https://vercel.com) - Free Node.js hosting
3. Connect GitHub repo to Vercel
4. Add environment variables in Vercel dashboard

---

## Troubleshooting

### Map Not Loading?
1. Check API key is correct
2. Verify APIs are enabled in Google Cloud Console
3. Check browser console for errors
4. Ensure billing is enabled

### "API Key Invalid" Error?
1. Regenerate key in Google Cloud Console
2. Remove HTTP referrer restrictions temporarily for testing
3. Check for extra spaces in key

### Places Autocomplete Not Working?
1. Ensure Places API is enabled
2. Check callback function name matches (`initMap`)

---

## Security Best Practices

### For Academic Project (Acceptable)
- ✅ Use API key directly in HTML (simple, works)
- ✅ Restrict key to your domain/localhost
- ✅ No billing worries with $200 credit

### For Production (Not Required for Academic)
- ✅ Store key in environment variables
- ✅ Use backend proxy for API calls
- ✅ Implement rate limiting
- ✅ Rotate keys periodically

---

## API Key Restrictions Setup

1. Go to [Credentials](https://console.cloud.google.com/apis/credentials)
2. Click your API key
3. Under "Application restrictions":
   ```
   HTTP referrers (websites)
   ```
4. Add these entries:
   ```
   localhost:3000/*
   http://localhost:3000/*
   https://your-render-url.onrender.com/*
   ```

---

## Summary

| Task | Time | Cost |
|------|------|------|
| Get API Key | 5 min | FREE |
| Add to Project | 2 min | FREE |
| Test Locally | 5 min | FREE |
| Deploy with ngrok | 2 min | FREE |
| Deploy to Render | 10 min | FREE |

**Total Cost: $0.00**

---

## Next Steps
1. ✅ Get your API key from Google Cloud
2. ✅ Replace `YOUR_API_KEY` in `book-with-maps.html`
3. ✅ Test at http://localhost:3000/rider/book-with-maps
4. ✅ Deploy using ngrok or Render
5. ✅ Present your project with real Google Maps!

---

**Need Help?**
- Google Maps Platform Docs: https://developers.google.com/maps
- Google Cloud Support: https://cloud.google.com/support
- Your API Dashboard: https://console.cloud.google.com/apis/dashboard
