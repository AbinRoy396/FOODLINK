# Changelog

All notable changes to the FoodLink project will be documented in this file.

## [2.0.0] - 2025-10-11

### 🎉 Major Improvements

#### Backend
- **✅ Persistent Database**: Migrated from in-memory arrays to SQLite database
  - Data now persists across server restarts
  - Added proper database schema with foreign key constraints
  - Automatic table creation on first run
  
- **✅ Enhanced API Validation**:
  - Email format validation using regex
  - Password minimum length requirement (6 characters)
  - Role validation (Donor, NGO, Receiver only)
  - Required field validation on all endpoints
  
- **✅ Improved Error Handling**:
  - Comprehensive try-catch blocks on all async operations
  - Specific error messages for different failure scenarios
  - Proper HTTP status codes (400, 401, 403, 404, 500)
  
- **✅ Security Enhancements**:
  - JWT token expiry increased to 24 hours
  - Password never exposed in API responses
  - Parameterized SQL queries to prevent injection
  - Environment variable support for sensitive data
  
- **✅ Missing Endpoint Added**:
  - `GET /api/donations` - Retrieve all donations for map view
  - Properly authenticated and returns sorted results
  
- **✅ Better Logging**:
  - Request logging middleware
  - Timestamp on all log entries
  - Startup information display
  
- **✅ Graceful Shutdown**:
  - Proper database connection cleanup on SIGINT
  - Prevents database corruption

#### Frontend (Flutter)
- **✅ Password Visibility Toggle**:
  - Added to Login screen
  - Added to Admin Login screen
  - Added to all Registration screens (Donor, NGO, Receiver)
  - Eye icon shows/hides password
  
- **✅ Improved User Experience**:
  - Better loading states
  - Enhanced error messages
  - Consistent styling across forms

#### Infrastructure
- **✅ Environment Configuration**:
  - `.env.example` file created
  - Support for PORT and JWT_SECRET environment variables
  - Secure secret generation instructions
  
- **✅ Updated Dependencies**:
  - Added `sqlite3` to package.json
  - Updated .gitignore for database files and .env
  
- **✅ Comprehensive Documentation**:
  - Complete README with setup instructions
  - API endpoint documentation
  - Database schema documentation
  - Security features documented
  - Testing examples provided

### 🔧 Technical Details

#### Database Schema
```sql
- users (id, email, password, name, role, address, phone, description, familySize, createdAt)
- donations (id, donorId, foodType, quantity, pickupAddress, expiryTime, status, createdAt)
- requests (id, receiverId, foodType, quantity, address, notes, status, createdAt)
```

#### API Changes
- All endpoints now use async/await with proper error handling
- Database operations wrapped in Promises for better control
- Consistent response format across all endpoints

#### Security Improvements
- bcrypt salt rounds: 10
- JWT expiry: 24 hours
- Password validation: minimum 6 characters
- Email validation: RFC 5322 compliant regex

### 📦 Dependencies Added
- `sqlite3: ^5.1.7` - SQLite database driver

### 🐛 Bug Fixes
- Fixed missing GET /api/donations endpoint
- Fixed password exposure in API responses
- Fixed inconsistent error handling

### 📝 Documentation
- Created comprehensive README.md
- Added .env.example with instructions
- Updated .gitignore
- Created CHANGELOG.md

---

## [1.0.0] - 2025-10-08

### Initial Release
- Basic food donation management system
- Multi-role support (Donor, NGO, Receiver)
- In-memory data storage
- JWT authentication
- Flutter mobile app
- Google Maps integration
- Offline support
- Dark mode

---

## Future Enhancements

### Planned for v2.1.0
- [ ] Pull-to-refresh on list screens
- [ ] Empty state UI for lists
- [ ] Image upload for donations
- [ ] Push notifications
- [ ] Real-time chat
- [ ] Advanced analytics dashboard

### Planned for v3.0.0
- [ ] PostgreSQL/MySQL support
- [ ] Admin dashboard implementation
- [ ] Multi-language support
- [ ] Voice commands
- [ ] Biometric authentication
- [ ] PDF export for reports
- [ ] Rating system for donations

---

**Note**: This project follows [Semantic Versioning](https://semver.org/).
