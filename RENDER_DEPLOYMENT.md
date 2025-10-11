# 🚀 Deploy FoodLink to Render

## Step-by-Step Deployment Guide

### 1. Prepare Your Repository

Make sure your code is pushed to GitHub:

```bash
git add .
git commit -m "Prepare for Render deployment"
git push origin main
```

### 2. Create Render Account

1. Go to https://render.com
2. Click **"Get Started"** or **"Sign Up"**
3. Sign up with GitHub (recommended for easy integration)

### 3. Deploy Backend

1. **Click "New +"** in the top right
2. Select **"Web Service"**
3. **Connect your GitHub repository:**
   - Click "Connect account" if not already connected
   - Find and select your `FoodLink` repository
   - Click "Connect"

4. **Configure the service:**
   ```
   Name: foodlink-api (or any name you prefer)
   Region: Choose closest to your users
   Branch: main
   Root Directory: (leave empty)
   Runtime: Node
   Build Command: npm install
   Start Command: npm start
   ```

5. **Select Plan:**
   - Choose **"Free"** plan (0$/month)
   - Note: Free tier sleeps after 15 min of inactivity

6. **Add Environment Variables:**
   Click "Advanced" → "Add Environment Variable"
   
   Add these variables:
   ```
   JWT_SECRET = <click "Generate" to create a secure random string>
   NODE_ENV = production
   ```

7. **Click "Create Web Service"**

### 4. Wait for Deployment

- Render will automatically build and deploy your app
- Watch the logs in real-time
- Deployment usually takes 2-5 minutes
- Once complete, you'll see "Live" status

### 5. Get Your API URL

Your backend will be available at:
```
https://foodlink-api.onrender.com
```
(Replace `foodlink-api` with your chosen service name)

### 6. Test Your API

Open in browser or use curl:
```bash
curl https://foodlink-api.onrender.com/api/test
```

---

## 📱 Update Flutter App with Production URL

### Update API Service

Edit `food_link_app/lib/services/api_service.dart`:

```dart
// Change this line:
static const String baseUrl = 'http://localhost:3000';

// To your Render URL:
static const String baseUrl = 'https://foodlink-api.onrender.com';
```

---

## 🔧 Important Notes

### Free Tier Limitations:
- ✅ 750 hours/month (enough for 24/7 operation)
- ⚠️ Sleeps after 15 min of inactivity
- ⚠️ Cold start takes 30-60 seconds
- ✅ Automatic HTTPS
- ✅ Auto-deploy on git push

### Database Persistence:
- SQLite file will persist on Render's disk
- ⚠️ Free tier: disk is ephemeral (resets on redeploy)
- 💡 Consider upgrading to paid tier for persistent disk
- 💡 Or migrate to PostgreSQL (Render offers free PostgreSQL)

### Keep Service Awake:
To prevent cold starts, you can:
1. Upgrade to paid tier ($7/month)
2. Use a cron job to ping your API every 10 minutes
3. Use a service like UptimeRobot (free)

---

## 🔄 Auto-Deploy on Git Push

Once connected, Render automatically deploys when you push to GitHub:

```bash
git add .
git commit -m "Update feature"
git push origin main
# Render will automatically deploy!
```

---

## 📊 Monitor Your Deployment

### View Logs:
1. Go to your service dashboard
2. Click "Logs" tab
3. See real-time application logs

### View Metrics:
1. Click "Metrics" tab
2. See CPU, memory, and request metrics

---

## 🆘 Troubleshooting

### Deployment Failed:
- Check logs for specific errors
- Verify `package.json` has all dependencies
- Ensure Node version compatibility

### Can't Connect to API:
- Verify service is "Live" (not sleeping)
- Check URL is correct (https, not http)
- Test with browser first

### Database Issues:
- SQLite works but is ephemeral on free tier
- Consider PostgreSQL for production:
  1. Create new PostgreSQL database in Render
  2. Update connection string in your app
  3. Migrate schema

---

## 🎉 Next Steps

1. ✅ Deploy backend to Render
2. ✅ Update Flutter app with production URL
3. ✅ Build and test Flutter APK
4. ✅ Distribute app to users
5. 📈 Monitor usage and performance

---

## 💰 Upgrade Options

If you need better performance:

**Starter Plan ($7/month):**
- No sleep/cold starts
- Persistent disk
- Better performance
- Custom domains

**Standard Plan ($25/month):**
- More resources
- Priority support
- Advanced features
