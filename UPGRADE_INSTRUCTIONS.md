# 🚀 Backend Upgrade Instructions

## 📋 What's Been Created:

1. **`BACKEND_IMPROVEMENTS.md`** - Comprehensive improvement recommendations
2. **`server_improved.js`** - Enhanced server with all critical features

---

## ✨ New Features in Enhanced Server:

### **1. GPS Location Support**
- ✅ Latitude/longitude fields for donations, requests, and users
- ✅ Location-based filtering (coming soon)
- ✅ Distance calculations

### **2. Notifications System**
- ✅ New `notifications` table
- ✅ GET `/api/notifications` - Get user notifications
- ✅ PUT `/api/notifications/:id/read` - Mark as read
- ✅ Auto-notifications on status updates

### **3. Activity Logging**
- ✅ New `activity_log` table
- ✅ Tracks all user actions
- ✅ IP address logging
- ✅ Audit trail for security

### **4. Enhanced Data**
- ✅ `imageUrl` for donations
- ✅ `lastLogin` timestamp for users
- ✅ `updatedAt` timestamps on all tables
- ✅ `ngoId` tracking on donations/requests

### **5. Statistics Endpoint**
- ✅ GET `/api/stats` - Dashboard statistics
- ✅ Total donations, requests, users
- ✅ Completion rates

### **6. Performance**
- ✅ Database indexes on all foreign keys
- ✅ Indexes on frequently queried fields
- ✅ Pagination support (page & limit params)

---

## 🔄 How to Upgrade:

### **Option 1: Keep Existing Data (Recommended)**

1. **Backup your current database:**
   ```bash
   copy foodlink.db foodlink_backup.db
   ```

2. **Run migration script** (I'll create this):
   ```bash
   node migrate_database.js
   ```

3. **Test the new server:**
   ```bash
   node server_improved.js
   ```

4. **If everything works, replace old server:**
   ```bash
   copy server.js server_old.js
   copy server_improved.js server.js
   ```

### **Option 2: Fresh Start**

1. **Delete old database:**
   ```bash
   del foodlink.db
   ```

2. **Run improved server:**
   ```bash
   node server_improved.js
   ```

3. **New tables will be created automatically**

---

## 📦 New Dependencies (Optional):

For full improvements, install these:

```bash
npm install dotenv helmet express-rate-limit validator winston joi
```

Then create `.env` file:
```env
PORT=3000
JWT_SECRET=your-super-secret-key-at-least-32-characters-long
NODE_ENV=development
```

---

## 🗄️ Database Schema Changes:

### **Users Table - New Fields:**
- `latitude REAL`
- `longitude REAL`
- `verified BOOLEAN`
- `profileImage TEXT`
- `lastLogin TEXT`
- `updatedAt TEXT`

### **Donations Table - New Fields:**
- `latitude REAL`
- `longitude REAL`
- `imageUrl TEXT`
- `ngoId INTEGER`
- `allocatedAt TEXT`
- `deliveredAt TEXT`
- `updatedAt TEXT`

### **Requests Table - New Fields:**
- `latitude REAL`
- `longitude REAL`
- `ngoId INTEGER`
- `donationId INTEGER`
- `allocatedAt TEXT`
- `fulfilledAt TEXT`
- `updatedAt TEXT`

### **New Tables:**
- `notifications` - User notifications
- `activity_log` - Audit trail

---

## 🎯 API Changes:

### **New Endpoints:**
```
GET    /api/notifications          - Get user notifications
PUT    /api/notifications/:id/read - Mark notification as read
GET    /api/stats                   - Get platform statistics
```

### **Enhanced Endpoints:**
```
POST   /api/register    - Now accepts latitude/longitude
POST   /api/donations   - Now accepts latitude/longitude/imageUrl
POST   /api/requests    - Now accepts latitude/longitude
GET    /api/donations   - Now supports pagination (?page=1&limit=20)
```

---

## 🧪 Testing the Upgrade:

1. **Start improved server:**
   ```bash
   node server_improved.js
   ```

2. **Test registration with location:**
   ```bash
   curl -X POST http://localhost:3000/api/register \
     -H "Content-Type: application/json" \
     -d '{
       "email": "test@example.com",
       "password": "password123",
       "name": "Test User",
       "role": "Donor",
       "latitude": 10.5276,
       "longitude": 76.2144
     }'
   ```

3. **Test statistics:**
   ```bash
   curl http://localhost:3000/api/stats \
     -H "Authorization: Bearer YOUR_TOKEN"
   ```

4. **Test notifications:**
   ```bash
   curl http://localhost:3000/api/notifications \
     -H "Authorization: Bearer YOUR_TOKEN"
   ```

---

## 📱 Frontend Changes Needed:

Update your Flutter app to send location data:

```dart
// When creating donation
final response = await ApiService.createDonation(
  foodType: foodType,
  quantity: quantity,
  pickupAddress: address,
  latitude: position.latitude,   // NEW
  longitude: position.longitude, // NEW
  expiryTime: expiryTime,
);

// When registering
final response = await ApiService.register(
  email: email,
  password: password,
  name: name,
  role: role,
  latitude: position.latitude,   // NEW
  longitude: position.longitude, // NEW
);
```

---

## 🔍 Monitoring:

The improved server logs:
- ✅ All API requests with timestamps
- ✅ User activities (login, create donation, etc.)
- ✅ IP addresses for security
- ✅ Database errors

Check logs in console or add Winston for file logging.

---

## 🚨 Important Notes:

1. **Backup First!** Always backup `foodlink.db` before upgrading
2. **Test Locally** Run `server_improved.js` on a different port first
3. **Update Frontend** App needs to send latitude/longitude
4. **Environment Variables** Use `.env` for production secrets
5. **Database Migration** Existing data will work, new fields will be NULL

---

## ✅ Benefits of Upgrade:

- 🗺️ **Location-based features** - Find nearby donations
- 🔔 **Notifications** - Real-time updates for users
- 📊 **Statistics** - Dashboard insights
- 🔒 **Activity logging** - Security and audit trail
- ⚡ **Better performance** - Database indexes
- 📈 **Scalability** - Pagination support
- 🎯 **Enhanced tracking** - NGO assignments, timestamps

---

## 🆘 Rollback Plan:

If something goes wrong:

1. **Stop new server:**
   ```bash
   Ctrl+C
   ```

2. **Restore backup:**
   ```bash
   copy foodlink_backup.db foodlink.db
   ```

3. **Run old server:**
   ```bash
   node server.js
   ```

---

**Ready to upgrade? Start with Option 1 (keep existing data) for safety!**
