# 🍽️ FoodLink - Food Donation Management Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.35.3-blue.svg)](https://flutter.dev/)
[![Node.js](https://img.shields.io/badge/Node.js-20+-green.svg)](https://nodejs.org/)
[![SQLite](https://img.shields.io/badge/SQLite-3-blue.svg)](https://www.sqlite.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**FoodLink** is a comprehensive food donation management platform connecting donors, NGOs, and receivers to reduce food waste and help those in need. Built with Flutter for mobile and Node.js/Express for the backend.

---

## 🎯 Features

### Core Functionality
- **Multi-Role System** - Separate interfaces for Donors, NGOs, and Receivers
- **Donation Management** - Create, track, and manage food donations
- **Request System** - Receivers can request specific food items
- **Interactive Maps** - Find nearby donations with GPS integration
- **Real-Time Updates** - Live status tracking for donations and requests
- **Offline Support** - Queue operations when offline, sync when online
- **Search & Filter** - Advanced donation discovery

### Security & Performance
- **JWT Authentication** - Secure token-based authentication (24h expiry)
- **Password Hashing** - bcrypt encryption for user passwords
- **Input Validation** - Comprehensive server and client-side validation
- **SQLite Database** - Persistent data storage with foreign key constraints
- **Auto-Retry Logic** - Automatic retry on network failures (3 attempts)
- **Session Management** - Auto-logout on token expiry

### UI/UX Enhancements
- **Password Visibility Toggle** - Show/hide password in all forms
- **Dark Mode Support** - Beautiful light/dark themes
- **Skeleton Loading** - Shimmer effects for better UX
- **Swipe Actions** - Delete and share with gestures
- **Haptic Feedback** - Touch feedback on interactions
- **Accessibility** - Screen reader support

---

## 🚀 Quick Start

### Prerequisites
- **Flutter SDK** 3.35.3 or higher
- **Dart** 3.6.0 or higher
- **Node.js** 20 or higher
- **npm** or **yarn**

### Backend Setup

1. **Navigate to project root:**
```bash
cd FoodLink
```

2. **Install dependencies:**
```bash
npm install
```

3. **Configure environment (optional):**
```bash
cp .env.example .env
# Edit .env and set JWT_SECRET
```

4. **Start the server:**
```bash
npm start
# or for development with auto-reload:
npm run dev
```

The server will start at `http://localhost:3000` and create a `foodlink.db` SQLite database automatically.

### Flutter App Setup

1. **Navigate to Flutter app:**
```bash
cd food_link_app
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Run the app:**
```bash
# For Android emulator
flutter run

# For specific device
flutter run -d <device-id>
```

---

## 📁 Project Structure

```
FoodLink/
├── server.js                 # Node.js/Express backend
├── package.json              # Backend dependencies
├── .env.example              # Environment variables template
├── foodlink.db              # SQLite database (auto-created)
│
└── food_link_app/           # Flutter mobile app
    ├── lib/
    │   ├── main.dart        # App entry point
    │   ├── models/          # Data models
    │   ├── screens/         # UI screens
    │   ├── services/        # API & business logic
    │   ├── utils/           # Utilities & helpers
    │   └── widgets/         # Reusable widgets
    ├── pubspec.yaml         # Flutter dependencies
    └── README.md            # Flutter app documentation
```

---

## 🔌 API Endpoints

### Authentication
- `POST /api/register` - Register new user
- `POST /api/login` - User login
- `GET /api/profile/:id` - Get user profile (protected)

### Donations
- `POST /api/donations` - Create donation (Donor only)
- `GET /api/donations` - Get all donations (protected)
- `GET /api/donations/:userId` - Get user donations (protected)
- `PUT /api/donations/:id/status` - Update donation status (NGO only)

### Requests
- `POST /api/requests` - Create request (Receiver only)
- `GET /api/requests/:userId` - Get user requests (protected)
- `PUT /api/requests/:id/status` - Update request status (NGO only)

---

## 🗄️ Database Schema

### Users Table
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  name TEXT NOT NULL,
  role TEXT NOT NULL,
  address TEXT,
  phone TEXT,
  description TEXT,
  familySize INTEGER,
  createdAt TEXT NOT NULL
);
```

### Donations Table
```sql
CREATE TABLE donations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  donorId INTEGER NOT NULL,
  foodType TEXT NOT NULL,
  quantity TEXT NOT NULL,
  pickupAddress TEXT NOT NULL,
  expiryTime TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'Pending',
  createdAt TEXT NOT NULL,
  FOREIGN KEY (donorId) REFERENCES users(id)
);
```

### Requests Table
```sql
CREATE TABLE requests (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  receiverId INTEGER NOT NULL,
  foodType TEXT NOT NULL,
  quantity TEXT NOT NULL,
  address TEXT NOT NULL,
  notes TEXT,
  status TEXT NOT NULL DEFAULT 'Requested',
  createdAt TEXT NOT NULL,
  FOREIGN KEY (receiverId) REFERENCES users(id)
);
```

---

## 🎨 Key Improvements Made

### Backend Enhancements
✅ **Persistent Database** - Migrated from in-memory to SQLite  
✅ **Enhanced Validation** - Email format, password length, role validation  
✅ **Better Error Handling** - Comprehensive try-catch blocks  
✅ **Environment Variables** - Support for .env configuration  
✅ **Request Logging** - Middleware for request tracking  
✅ **Graceful Shutdown** - Proper database connection cleanup  
✅ **Missing Endpoint** - Added GET /api/donations for map view  

### Frontend Enhancements
✅ **Password Visibility Toggle** - All login/register forms  
✅ **Improved Security** - Password never exposed in responses  
✅ **Better UX** - Loading states, error messages  
✅ **Offline Queue** - Operations queued when offline  

---

## 🔐 Security Features

- **Password Hashing** - bcrypt with 10 salt rounds
- **JWT Tokens** - 24-hour expiration
- **Role-Based Access** - Endpoint protection by user role
- **Input Sanitization** - Validation on all inputs
- **SQL Injection Prevention** - Parameterized queries
- **Session Management** - Auto-logout on token expiry

---

## 🧪 Testing

### Backend Testing
```bash
# Test registration
curl -X POST http://localhost:3000/api/register \
  -H "Content-Type: application/json" \
  -d '{"email":"donor@test.com","password":"test123","name":"Test Donor","role":"Donor","address":"123 Main St"}'

# Test login
curl -X POST http://localhost:3000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"donor@test.com","password":"test123","role":"Donor"}'
```

### Flutter Testing
```bash
flutter test
flutter analyze
```

---

## 📱 User Roles

### Donor
- Create food donations
- Track donation status
- View donations on map
- Share donations

### NGO
- Verify donations
- Allocate to receivers
- Update donation/request status
- View all donations and requests

### Receiver
- Browse available donations
- Create food requests
- Track request status
- View nearby donations on map

---

## 🛠️ Tech Stack

### Backend
- **Node.js** - Runtime environment
- **Express.js** - Web framework
- **SQLite3** - Database
- **bcryptjs** - Password hashing
- **jsonwebtoken** - JWT authentication
- **cors** - Cross-origin resource sharing

### Frontend
- **Flutter** - UI framework
- **Provider** - State management
- **Google Maps** - Interactive maps
- **Cached Network Image** - Image caching
- **Shimmer** - Loading animations
- **Flutter Slidable** - Swipe actions

---

## 📝 Environment Variables

Create a `.env` file in the project root:

```env
PORT=3000
JWT_SECRET=your-super-secret-jwt-key-change-this
```

Generate a secure JWT secret:
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

---

## 🚧 Known Limitations

- Firebase features disabled (Chat, Notifications, Cloud Storage)
- Admin dashboard not fully implemented
- Map markers require Google Maps API key configuration

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License.

---

## 👨‍💻 Author

**Abin Roy**
- GitHub: [@AbinRoy396](https://github.com/AbinRoy396)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Express.js community
- SQLite for lightweight database solution
- All contributors and testers

---

## 📞 Support

For issues, questions, or feature requests:
- 🐛 Issues: [GitHub Issues](https://github.com/AbinRoy396/FoodLink-/issues)
- 📧 Email: support@foodlink.app

---

**Built with ❤️ to reduce food waste and help those in need**

**Version**: 2.0.0  
**Last Updated**: October 11, 2025  
**Status**: ✅ Production Ready
