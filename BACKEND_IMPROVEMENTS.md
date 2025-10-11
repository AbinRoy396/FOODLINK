# 🔧 Backend & Database Improvements

## 📊 Current Analysis

### **What's Good:** ✅
- Clean Express.js structure
- JWT authentication working
- Password hashing with bcrypt
- SQLite database (good for development)
- CORS enabled
- Request logging
- Role-based access control
- Graceful shutdown handling

### **What Needs Improvement:** ⚠️

---

## 🚀 Recommended Improvements

### **1. Database Schema Enhancements**

#### **Add Missing Fields:**

**Donations Table:**
```sql
ALTER TABLE donations ADD COLUMN latitude REAL;
ALTER TABLE donations ADD COLUMN longitude REAL;
ALTER TABLE donations ADD COLUMN imageUrl TEXT;
ALTER TABLE donations ADD COLUMN ngoId INTEGER;
ALTER TABLE donations ADD COLUMN allocatedAt TEXT;
ALTER TABLE donations ADD COLUMN deliveredAt TEXT;
ALTER TABLE donations ADD COLUMN updatedAt TEXT;
```

**Requests Table:**
```sql
ALTER TABLE requests ADD COLUMN latitude REAL;
ALTER TABLE requests ADD COLUMN longitude REAL;
ALTER TABLE requests ADD COLUMN ngoId INTEGER;
ALTER TABLE requests ADD COLUMN donationId INTEGER;
ALTER TABLE requests ADD COLUMN allocatedAt TEXT;
ALTER TABLE requests ADD COLUMN fulfilledAt TEXT;
ALTER TABLE requests ADD COLUMN updatedAt TEXT;
```

**Users Table:**
```sql
ALTER TABLE users ADD COLUMN latitude REAL;
ALTER TABLE users ADD COLUMN longitude REAL;
ALTER TABLE users ADD COLUMN verified BOOLEAN DEFAULT 0;
ALTER TABLE users ADD COLUMN profileImage TEXT;
ALTER TABLE users ADD COLUMN lastLogin TEXT;
ALTER TABLE users ADD COLUMN updatedAt TEXT;
```

#### **New Tables to Add:**

**1. Allocations Table** (Track NGO assignments):
```sql
CREATE TABLE allocations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  donationId INTEGER NOT NULL,
  requestId INTEGER NOT NULL,
  ngoId INTEGER NOT NULL,
  status TEXT NOT NULL DEFAULT 'Pending',
  notes TEXT,
  createdAt TEXT NOT NULL,
  updatedAt TEXT,
  FOREIGN KEY (donationId) REFERENCES donations(id),
  FOREIGN KEY (requestId) REFERENCES requests(id),
  FOREIGN KEY (ngoId) REFERENCES users(id)
);
```

**2. Notifications Table**:
```sql
CREATE TABLE notifications (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  userId INTEGER NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL,
  read BOOLEAN DEFAULT 0,
  relatedId INTEGER,
  createdAt TEXT NOT NULL,
  FOREIGN KEY (userId) REFERENCES users(id)
);
```

**3. Chat Messages Table**:
```sql
CREATE TABLE messages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  senderId INTEGER NOT NULL,
  receiverId INTEGER NOT NULL,
  message TEXT NOT NULL,
  read BOOLEAN DEFAULT 0,
  createdAt TEXT NOT NULL,
  FOREIGN KEY (senderId) REFERENCES users(id),
  FOREIGN KEY (receiverId) REFERENCES users(id)
);
```

**4. Activity Log Table**:
```sql
CREATE TABLE activity_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  userId INTEGER NOT NULL,
  action TEXT NOT NULL,
  details TEXT,
  ipAddress TEXT,
  createdAt TEXT NOT NULL,
  FOREIGN KEY (userId) REFERENCES users(id)
);
```

**5. Reviews/Ratings Table**:
```sql
CREATE TABLE reviews (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  donationId INTEGER NOT NULL,
  reviewerId INTEGER NOT NULL,
  revieweeId INTEGER NOT NULL,
  rating INTEGER NOT NULL CHECK(rating >= 1 AND rating <= 5),
  comment TEXT,
  createdAt TEXT NOT NULL,
  FOREIGN KEY (donationId) REFERENCES donations(id),
  FOREIGN KEY (reviewerId) REFERENCES users(id),
  FOREIGN KEY (revieweeId) REFERENCES users(id)
);
```

---

### **2. Security Improvements**

#### **Add Rate Limiting:**
```javascript
const rateLimit = require('express-rate-limit');

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts
  message: 'Too many login attempts, please try again later'
});

app.post("/api/login", loginLimiter, async (req, res) => {
  // ... login logic
});
```

#### **Add Helmet for Security Headers:**
```javascript
const helmet = require('helmet');
app.use(helmet());
```

#### **Add Input Sanitization:**
```javascript
const validator = require('validator');

// Sanitize email
const sanitizedEmail = validator.normalizeEmail(email);
const escapedName = validator.escape(name);
```

#### **Environment Variables:**
Create `.env` file:
```env
PORT=3000
JWT_SECRET=your-super-secret-key-min-32-characters-long
DB_PATH=./foodlink.db
NODE_ENV=development
ALLOWED_ORIGINS=http://localhost:3000,http://192.168.4.88:3000
```

---

### **3. API Improvements**

#### **Add Pagination:**
```javascript
app.get("/api/donations", authenticateToken, async (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 20;
  const offset = (page - 1) * limit;
  
  try {
    const donations = await new Promise((resolve, reject) => {
      db.all(
        "SELECT * FROM donations ORDER BY createdAt DESC LIMIT ? OFFSET ?",
        [limit, offset],
        (err, rows) => {
          if (err) reject(err);
          else resolve(rows);
        }
      );
    });
    
    const total = await new Promise((resolve, reject) => {
      db.get("SELECT COUNT(*) as count FROM donations", [], (err, row) => {
        if (err) reject(err);
        else resolve(row.count);
      });
    });
    
    res.json({
      data: donations,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    res.status(500).json({ error: "Failed to get donations" });
  }
});
```

#### **Add Filtering & Search:**
```javascript
app.get("/api/donations/search", authenticateToken, async (req, res) => {
  const { status, foodType, location, radius } = req.query;
  
  let query = "SELECT * FROM donations WHERE 1=1";
  const params = [];
  
  if (status) {
    query += " AND status = ?";
    params.push(status);
  }
  
  if (foodType) {
    query += " AND foodType LIKE ?";
    params.push(`%${foodType}%`);
  }
  
  // Add location-based filtering using Haversine formula
  if (location && radius) {
    const [lat, lng] = location.split(',');
    query += ` AND (
      6371 * acos(
        cos(radians(?)) * cos(radians(latitude)) *
        cos(radians(longitude) - radians(?)) +
        sin(radians(?)) * sin(radians(latitude))
      )
    ) <= ?`;
    params.push(lat, lng, lat, radius);
  }
  
  query += " ORDER BY createdAt DESC";
  
  try {
    const donations = await new Promise((resolve, reject) => {
      db.all(query, params, (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      });
    });
    res.json(donations);
  } catch (error) {
    res.status(500).json({ error: "Search failed" });
  }
});
```

#### **Add Statistics Endpoint:**
```javascript
app.get("/api/stats", authenticateToken, async (req, res) => {
  try {
    const stats = await new Promise((resolve, reject) => {
      db.get(`
        SELECT 
          (SELECT COUNT(*) FROM donations) as totalDonations,
          (SELECT COUNT(*) FROM donations WHERE status = 'Delivered') as deliveredDonations,
          (SELECT COUNT(*) FROM requests) as totalRequests,
          (SELECT COUNT(*) FROM requests WHERE status = 'Fulfilled') as fulfilledRequests,
          (SELECT COUNT(*) FROM users WHERE role = 'Donor') as totalDonors,
          (SELECT COUNT(*) FROM users WHERE role = 'NGO') as totalNGOs,
          (SELECT COUNT(*) FROM users WHERE role = 'Receiver') as totalReceivers
      `, [], (err, row) => {
        if (err) reject(err);
        else resolve(row);
      });
    });
    res.json(stats);
  } catch (error) {
    res.status(500).json({ error: "Failed to get stats" });
  }
});
```

---

### **4. Performance Improvements**

#### **Add Database Indexes:**
```javascript
function initializeDatabase() {
  db.serialize(() => {
    // ... existing table creation ...
    
    // Add indexes for better query performance
    db.run("CREATE INDEX IF NOT EXISTS idx_donations_donor ON donations(donorId)");
    db.run("CREATE INDEX IF NOT EXISTS idx_donations_status ON donations(status)");
    db.run("CREATE INDEX IF NOT EXISTS idx_donations_created ON donations(createdAt)");
    db.run("CREATE INDEX IF NOT EXISTS idx_requests_receiver ON requests(receiverId)");
    db.run("CREATE INDEX IF NOT EXISTS idx_requests_status ON requests(status)");
    db.run("CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)");
    db.run("CREATE INDEX IF NOT EXISTS idx_users_role ON users(role)");
    
    console.log("✅ Database indexes created");
  });
}
```

#### **Add Connection Pooling (for production):**
Consider migrating to PostgreSQL or MySQL for production:
```javascript
// Using PostgreSQL with connection pooling
const { Pool } = require('pg');
const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
  max: 20, // maximum number of clients
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});
```

---

### **5. Error Handling Improvements**

#### **Centralized Error Handler:**
```javascript
// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  
  if (err.name === 'ValidationError') {
    return res.status(400).json({ error: err.message });
  }
  
  if (err.name === 'UnauthorizedError') {
    return res.status(401).json({ error: 'Invalid token' });
  }
  
  res.status(500).json({ 
    error: process.env.NODE_ENV === 'production' 
      ? 'Internal server error' 
      : err.message 
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});
```

#### **Async Error Wrapper:**
```javascript
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

// Usage
app.post("/api/donations", authenticateToken, asyncHandler(async (req, res) => {
  // ... your logic
}));
```

---

### **6. Logging Improvements**

#### **Add Winston Logger:**
```javascript
const winston = require('winston');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' }),
    new winston.transports.Console({
      format: winston.format.simple()
    })
  ]
});

// Usage
logger.info('User logged in', { userId: user.id });
logger.error('Database error', { error: err.message });
```

---

### **7. Validation Improvements**

#### **Add Joi for Validation:**
```javascript
const Joi = require('joi');

const registerSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(8).required(),
  name: Joi.string().min(2).max(100).required(),
  role: Joi.string().valid('Donor', 'NGO', 'Receiver').required(),
  phone: Joi.string().pattern(/^[0-9]{10}$/).optional(),
  address: Joi.string().max(500).optional()
});

app.post("/api/register", async (req, res) => {
  const { error, value } = registerSchema.validate(req.body);
  if (error) {
    return res.status(400).json({ error: error.details[0].message });
  }
  // ... rest of logic
});
```

---

### **8. Testing**

#### **Add Unit Tests:**
```javascript
// tests/auth.test.js
const request = require('supertest');
const app = require('../server');

describe('Authentication', () => {
  it('should register a new user', async () => {
    const res = await request(app)
      .post('/api/register')
      .send({
        email: 'test@example.com',
        password: 'password123',
        name: 'Test User',
        role: 'Donor'
      });
    expect(res.statusCode).toBe(201);
    expect(res.body).toHaveProperty('token');
  });
  
  it('should login existing user', async () => {
    const res = await request(app)
      .post('/api/login')
      .send({
        email: 'test@example.com',
        password: 'password123',
        role: 'Donor'
      });
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('token');
  });
});
```

---

### **9. Documentation**

#### **Add Swagger/OpenAPI:**
```javascript
const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');

const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'FoodLink API',
      version: '1.0.0',
      description: 'Food donation and distribution platform API'
    },
    servers: [
      { url: 'http://localhost:3000', description: 'Development server' }
    ]
  },
  apis: ['./server.js']
};

const swaggerSpec = swaggerJsdoc(swaggerOptions);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));
```

---

### **10. Backup & Recovery**

#### **Add Database Backup:**
```javascript
const fs = require('fs');
const cron = require('node-cron');

// Backup database daily at 2 AM
cron.schedule('0 2 * * *', () => {
  const timestamp = new Date().toISOString().replace(/:/g, '-');
  const backupPath = `./backups/foodlink-${timestamp}.db`;
  
  fs.copyFile(dbPath, backupPath, (err) => {
    if (err) {
      logger.error('Backup failed', { error: err.message });
    } else {
      logger.info('Database backed up', { path: backupPath });
    }
  });
});
```

---

## 📦 Additional Packages to Install

```bash
npm install --save helmet express-rate-limit validator dotenv winston joi node-cron
npm install --save-dev jest supertest nodemon
```

---

## 🎯 Priority Improvements

### **High Priority:**
1. ✅ Add latitude/longitude to donations and requests
2. ✅ Add environment variables (.env)
3. ✅ Add rate limiting on login
4. ✅ Add database indexes
5. ✅ Add pagination to API endpoints

### **Medium Priority:**
6. ✅ Add notifications table
7. ✅ Add allocations table
8. ✅ Add search and filtering
9. ✅ Add statistics endpoint
10. ✅ Add input validation with Joi

### **Low Priority:**
11. ✅ Add Swagger documentation
12. ✅ Add unit tests
13. ✅ Add Winston logging
14. ✅ Add database backups
15. ✅ Migrate to PostgreSQL (production)

---

## 📊 Database Migration Script

I'll create a migration script to add all improvements without losing data!

---

**Would you like me to implement any of these improvements right now?**
