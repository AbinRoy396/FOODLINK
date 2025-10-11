# 🚀 FoodLink Quick Reference

Quick commands and information for developers.

---

## 🏃 Quick Start

```bash
# Backend
cd FoodLink
npm install
npm start

# Frontend
cd food_link_app
flutter pub get
flutter run
```

---

## 🔧 Common Commands

### Backend
```bash
npm start              # Start server
npm run dev            # Start with auto-reload
node server.js         # Direct start
```

### Flutter
```bash
flutter run            # Run app
flutter run --release  # Release mode
flutter clean          # Clean build
flutter pub get        # Install dependencies
flutter doctor         # Check setup
flutter devices        # List devices
flutter analyze        # Analyze code
flutter test           # Run tests
```

---

## 🔌 API Quick Reference

### Base URL
```
http://localhost:3000/api
```

### Authentication
```bash
# Register
POST /api/register
Body: { email, password, name, role, address, phone }

# Login
POST /api/login
Body: { email, password, role }

# Get Profile
GET /api/profile/:id
Headers: { Authorization: Bearer TOKEN }
```

### Donations
```bash
# Create
POST /api/donations
Headers: { Authorization: Bearer TOKEN }
Body: { foodType, quantity, pickupAddress, expiryTime }

# Get All
GET /api/donations
Headers: { Authorization: Bearer TOKEN }

# Get User Donations
GET /api/donations/:userId
Headers: { Authorization: Bearer TOKEN }

# Update Status
PUT /api/donations/:id/status
Headers: { Authorization: Bearer TOKEN }
Body: { status }
```

### Requests
```bash
# Create
POST /api/requests
Headers: { Authorization: Bearer TOKEN }
Body: { foodType, quantity, address, notes }

# Get User Requests
GET /api/requests/:userId
Headers: { Authorization: Bearer TOKEN }

# Update Status
PUT /api/requests/:id/status
Headers: { Authorization: Bearer TOKEN }
Body: { status }
```

---

## 🗄️ Database

### Location
```
FoodLink/foodlink.db
```

### Access
```bash
sqlite3 foodlink.db
.tables
SELECT * FROM users;
SELECT * FROM donations;
SELECT * FROM requests;
.quit
```

### Reset
```bash
# Stop server, then:
rm foodlink.db
npm start  # Recreates database
```

---

## 🔐 Environment Variables

### .env File
```env
PORT=3000
JWT_SECRET=your-secret-key
```

### Generate Secret
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

---

## 🐛 Troubleshooting

### Port in Use
```bash
# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# macOS/Linux
lsof -ti:3000 | xargs kill -9
```

### Flutter Issues
```bash
flutter clean
flutter pub get
flutter run
```

### Backend Issues
```bash
rm -rf node_modules
npm install
npm start
```

---

## 📱 Device Connection

### Android Emulator
```bash
flutter emulators
flutter emulators --launch <id>
```

### Physical Device
- Enable USB Debugging
- Connect via USB
- Accept debugging prompt

### Check Devices
```bash
flutter devices
```

---

## 🧪 Testing

### Test Registration
```bash
curl -X POST http://localhost:3000/api/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test123","name":"Test","role":"Donor","address":"123 St"}'
```

### Test Login
```bash
curl -X POST http://localhost:3000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test123","role":"Donor"}'
```

---

## 📊 Status Codes

- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `500` - Server Error

---

## 🎨 User Roles

- **Donor** - Create donations
- **NGO** - Verify & allocate
- **Receiver** - Request food

---

## 📝 Key Files

```
server.js              # Backend server
package.json           # Backend deps
.env                   # Environment vars
foodlink.db            # Database

food_link_app/
  lib/main.dart        # App entry
  lib/services/        # Business logic
  lib/screens/         # UI screens
  pubspec.yaml         # Flutter deps
```

---

## 🔗 Important Links

- [README](README.md) - Full documentation
- [SETUP_GUIDE](SETUP_GUIDE.md) - Setup instructions
- [CHANGELOG](CHANGELOG.md) - Version history
- [GitHub](https://github.com/AbinRoy396/FoodLink-)

---

## 💡 Tips

- Use `npm run dev` for auto-reload
- Use `flutter run --release` for better performance
- Check `flutter doctor` if issues occur
- Use `.env` for secrets, never commit it
- Database auto-creates on first run
- JWT tokens expire in 24 hours

---

**Quick help**: See SETUP_GUIDE.md for detailed instructions
