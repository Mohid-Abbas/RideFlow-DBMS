# 🗺️ RideFlow Map Features Guide

## ✅ Features Added

### 1. 📍 Click on Map to Set Locations

**How it works:**
- Click the **"🗺️ Set by Clicking Map"** button next to Pickup or Dropoff
- Cursor changes to crosshair
- Click anywhere on the map to set that location
- Address is automatically reverse-geocoded from coordinates

**Alternative:** Just click on the map directly:
- First click = Pickup location
- Second click = Dropoff location

### 2. 📡 Live Location Tracking

**Functions Available:**
- `setLiveLocationMarker(location)` - Shows blue dot for user's current position
- `startLiveLocationTracking()` - Continuously updates location as user moves
- `stopLiveLocationTracking()` - Stops tracking

**Usage:** Call `startLiveLocationTracking()` during an active ride to track the driver/rider movement in real-time.

### 3. 💰 Fare Calculation Logic

**Mathematical Formula:**
```
Fare = (Base + Distance_Cost + Time_Cost) × Surge_Multiplier
```

**Breakdown:**
| Component | Formula | Example |
|-----------|---------|---------|
| **Base** | Fixed rate | PKR 100 (Economy) |
| **Distance** | `per_km_rate × km` | PKR 15 × 5km = PKR 75 |
| **Time** | `per_min_rate × minutes` | PKR 3 × 15min = PKR 45 |
| **Subtotal** | Base + Distance + Time | PKR 220 |
| **Surge** | `subtotal × multiplier` (peak hours only) | PKR 220 × 1.5 = PKR 330 |

**Peak Hours (Surge Pricing):**
- 🌅 Morning: 7:00 AM - 9:00 AM
- 🌆 Evening: 5:00 PM - 8:00 PM

**Vehicle Types & Rates:**
| Type | Base | Per KM | Per Min | Surge Multiplier |
|------|------|--------|---------|------------------|
| 🚗 Economy | PKR 100 | PKR 15 | PKR 3 | 1.5x |
| 🚙 Premium | PKR 200 | PKR 30 | PKR 6 | 1.75x |
| 🏍️ Bike | PKR 50 | PKR 8 | PKR 1.5 | 1.25x |

**Example Calculation (5km, 15min, Economy, Peak Hour):**
```
Base:           PKR 100.00
Distance:       PKR 15 × 5 = PKR 75.00
Time:           PKR 3 × 15 = PKR 45.00
Subtotal:       PKR 220.00
Surge (1.5x):   PKR 220 × 1.5 = PKR 330.00
─────────────────────────────────────
Final Fare:     PKR 330.00
```

## 🎯 How to Use

1. **Open** `http://localhost:3000/rider/book-maps`
2. **Click map** or use **search boxes** to set pickup & dropoff
3. **Select vehicle** type
4. **See fare breakdown** update in real-time
5. **Click "Request Ride"** to book

## 🔧 Admin Controls

Admins can update fare rules at `/admin/fare-rules`:
- Change base rates
- Adjust per km/min rates
- Enable/disable surge pricing
- Set surge multipliers

## 📱 Live Tracking During Ride

To enable live tracking during an active ride, the driver's app would call:
```javascript
startLiveLocationTracking();
```

This updates the marker position every few seconds as the driver moves.

## 🎨 UI Improvements

- ✅ Click-to-select on map
- ✅ Blue dot showing live location
- ✅ Fare breakdown with math explanation
- ✅ Surge pricing indicator (yellow text)
- ✅ Toast notifications for user feedback
- ✅ Distance & duration display

---

**All features are now live!** Refresh the page to see them in action.
