# 🐘 PostgreSQL Setup Guide for Render

## Step 1: Create PostgreSQL Database on Render

1. **Go to Render Dashboard**: https://dashboard.render.com
2. **Click "New +"** → Select **"PostgreSQL"**
3. **Configure Database:**
   ```
   Name: foodlink-db
   Database: foodlink
   User: foodlink_user
   Region: Same as your web service (for best performance)
   Plan: Free
   ```
4. **Click "Create Database"**
5. **Wait 1-2 minutes** for database to be created

## Step 2: Get Database Connection String

1. In your PostgreSQL dashboard, find **"Internal Database URL"**
2. Copy the entire connection string (looks like):
   ```
   postgresql://foodlink_user:password@dpg-xxxxx.oregon-postgres.render.com/foodlink
   ```

## Step 3: Add Database URL to Web Service

1. Go to your **foodlink-api** web service dashboard
2. Click **"Environment"** in the left sidebar
3. Click **"Add Environment Variable"**
4. Add:
   ```
   Key: DATABASE_URL
   Value: [paste your Internal Database URL here]
   ```
5. Click **"Save Changes"**

## Step 4: Deploy

Your service will automatically redeploy with PostgreSQL!

---

## ✅ What Changed

### Code Updates:
- ✅ Replaced `sqlite3` with `pg` (PostgreSQL driver)
- ✅ Updated all database queries to use PostgreSQL syntax
- ✅ Changed `INTEGER PRIMARY KEY AUTOINCREMENT` → `SERIAL PRIMARY KEY`
- ✅ Changed `TEXT` → `VARCHAR(255)` for better performance
- ✅ Changed `?` placeholders → `$1, $2, $3` (PostgreSQL style)
- ✅ Updated timestamp handling to use PostgreSQL `NOW()`

### Benefits:
- ✅ **Persistent data** - Never lost on redeploy
- ✅ **Better performance** - Optimized for production
- ✅ **Auto backups** - Daily backups included
- ✅ **Scalable** - Can upgrade as you grow

---

## 🧪 Test After Deployment

Once deployed, test the health endpoint:

```bash
curl https://foodlink-1-1m4w.onrender.com/api/health
```

Expected response:
```json
{
  "status": "ok",
  "message": "FoodLink API is running",
  "database": "PostgreSQL connected",
  "users": 0,
  "timestamp": "2025-10-11T21:30:00.000Z"
}
```

---

## 📊 Database Management

### View Data:
1. Go to PostgreSQL dashboard on Render
2. Click **"Connect"** → **"External Connection"**
3. Use tools like:
   - **pgAdmin** (GUI)
   - **DBeaver** (GUI)
   - **psql** (CLI)

### Backup Data:
- Render automatically backs up your database daily
- Free tier: 7 days retention
- Paid tier: 30 days retention

### Restore Data:
1. Go to PostgreSQL dashboard
2. Click **"Backups"** tab
3. Select backup and restore

---

## 🔧 Local Development

To test PostgreSQL locally:

1. **Install PostgreSQL** on your machine
2. **Create local database:**
   ```bash
   createdb foodlink
   ```
3. **Set environment variable:**
   ```bash
   # Windows PowerShell
   $env:DATABASE_URL="postgresql://localhost/foodlink"
   
   # Then run
   npm start
   ```

---

## 🆘 Troubleshooting

### "Connection refused"
- Check DATABASE_URL is set correctly
- Verify PostgreSQL database is running on Render

### "SSL required"
- The code automatically handles SSL for production
- Set `NODE_ENV=production` in Render

### "Table doesn't exist"
- Tables are created automatically on first run
- Check logs for initialization errors

---

## 💰 Free Tier Limits

**Render PostgreSQL Free Tier:**
- ✅ 256 MB storage
- ✅ 1 GB data transfer/month
- ✅ Shared CPU
- ✅ Daily backups (7 days)
- ✅ No credit card required

**Upgrade if needed:**
- Starter: $7/month (1 GB storage)
- Standard: $20/month (10 GB storage)
