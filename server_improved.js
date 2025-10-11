require('dotenv').config();
const express = require("express");
const cors = require("cors");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const sqlite3 = require("sqlite3").verbose();
const path = require("path");

const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || "your-secret-key-change-in-production";

// Initialize SQLite Database
const dbPath = path.join(__dirname, "foodlink.db");
const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error("Error opening database:", err.message);
  } else {
    console.log("✅ Connected to SQLite database");
    initializeDatabase();
  }
});

// Enhanced database initialization with new fields and tables
function initializeDatabase() {
  db.serialize(() => {
    // Users table with enhancements
    db.run(`CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL,
      name TEXT NOT NULL,
      role TEXT NOT NULL,
      address TEXT,
      phone TEXT,
      description TEXT,
      familySize INTEGER,
      latitude REAL,
      longitude REAL,
      verified BOOLEAN DEFAULT 0,
      profileImage TEXT,
      lastLogin TEXT,
      createdAt TEXT NOT NULL,
      updatedAt TEXT
    )`);

    // Donations table with location and tracking
    db.run(`CREATE TABLE IF NOT EXISTS donations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      donorId INTEGER NOT NULL,
      foodType TEXT NOT NULL,
      quantity TEXT NOT NULL,
      pickupAddress TEXT NOT NULL,
      latitude REAL,
      longitude REAL,
      expiryTime TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'Pending',
      imageUrl TEXT,
      ngoId INTEGER,
      allocatedAt TEXT,
      deliveredAt TEXT,
      createdAt TEXT NOT NULL,
      updatedAt TEXT,
      FOREIGN KEY (donorId) REFERENCES users(id),
      FOREIGN KEY (ngoId) REFERENCES users(id)
    )`);

    // Requests table with location
    db.run(`CREATE TABLE IF NOT EXISTS requests (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      receiverId INTEGER NOT NULL,
      foodType TEXT NOT NULL,
      quantity TEXT NOT NULL,
      address TEXT NOT NULL,
      latitude REAL,
      longitude REAL,
      notes TEXT,
      status TEXT NOT NULL DEFAULT 'Requested',
      ngoId INTEGER,
      donationId INTEGER,
      allocatedAt TEXT,
      fulfilledAt TEXT,
      createdAt TEXT NOT NULL,
      updatedAt TEXT,
      FOREIGN KEY (receiverId) REFERENCES users(id),
      FOREIGN KEY (ngoId) REFERENCES users(id),
      FOREIGN KEY (donationId) REFERENCES donations(id)
    )`);

    // Notifications table
    db.run(`CREATE TABLE IF NOT EXISTS notifications (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER NOT NULL,
      title TEXT NOT NULL,
      message TEXT NOT NULL,
      type TEXT NOT NULL,
      read BOOLEAN DEFAULT 0,
      relatedId INTEGER,
      createdAt TEXT NOT NULL,
      FOREIGN KEY (userId) REFERENCES users(id)
    )`);

    // Activity log table
    db.run(`CREATE TABLE IF NOT EXISTS activity_log (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER NOT NULL,
      action TEXT NOT NULL,
      details TEXT,
      ipAddress TEXT,
      createdAt TEXT NOT NULL,
      FOREIGN KEY (userId) REFERENCES users(id)
    )`);

    // Create indexes for better performance
    db.run("CREATE INDEX IF NOT EXISTS idx_donations_donor ON donations(donorId)");
    db.run("CREATE INDEX IF NOT EXISTS idx_donations_status ON donations(status)");
    db.run("CREATE INDEX IF NOT EXISTS idx_donations_created ON donations(createdAt)");
    db.run("CREATE INDEX IF NOT EXISTS idx_requests_receiver ON requests(receiverId)");
    db.run("CREATE INDEX IF NOT EXISTS idx_requests_status ON requests(status)");
    db.run("CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)");
    db.run("CREATE INDEX IF NOT EXISTS idx_users_role ON users(role)");
    db.run("CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(userId)");

    console.log("✅ Database tables and indexes initialized");
  });
}

// Middleware
app.use(cors({ origin: "*" })); // In production, specify allowed origins
app.use(express.json());

// Enhanced request logging
app.use((req, res, next) => {
  const timestamp = new Date().toISOString();
  console.log(`[${timestamp}] ${req.method} ${req.path} - IP: ${req.ip}`);
  next();
});

// Auth Middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];
  if (!token) return res.status(401).json({ error: "Access denied" });

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ error: "Invalid token" });
    req.user = user;
    next();
  });
};

// Helper function to log activity
async function logActivity(userId, action, details, ipAddress) {
  const createdAt = new Date().toISOString();
  return new Promise((resolve, reject) => {
    db.run(
      "INSERT INTO activity_log (userId, action, details, ipAddress, createdAt) VALUES (?, ?, ?, ?, ?)",
      [userId, action, details, ipAddress, createdAt],
      (err) => {
        if (err) reject(err);
        else resolve();
      }
    );
  });
}

// Helper function to create notification
async function createNotification(userId, title, message, type, relatedId = null) {
  const createdAt = new Date().toISOString();
  return new Promise((resolve, reject) => {
    db.run(
      "INSERT INTO notifications (userId, title, message, type, relatedId, createdAt) VALUES (?, ?, ?, ?, ?, ?)",
      [userId, title, message, type, relatedId, createdAt],
      (err) => {
        if (err) reject(err);
        else resolve();
      }
    );
  });
}

// ========================================
// ROUTES
// ========================================

// 1. User Registration (Enhanced)
app.post("/api/register", async (req, res) => {
  const { email, password, name, role, address, phone, description, familySize, latitude, longitude } = req.body;
  
  // Validation
  if (!email || !password || !name || !role) {
    return res.status(400).json({ error: "Missing required fields" });
  }
  
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    return res.status(400).json({ error: "Invalid email format" });
  }
  
  if (password.length < 6) {
    return res.status(400).json({ error: "Password must be at least 6 characters" });
  }
  
  if (!['Donor', 'NGO', 'Receiver'].includes(role)) {
    return res.status(400).json({ error: "Invalid role" });
  }

  try {
    const existingUser = await new Promise((resolve, reject) => {
      db.get("SELECT * FROM users WHERE email = ?", [email], (err, row) => {
        if (err) reject(err);
        else resolve(row);
      });
    });

    if (existingUser) {
      return res.status(400).json({ error: "User already exists" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const createdAt = new Date().toISOString();

    const result = await new Promise((resolve, reject) => {
      db.run(
        `INSERT INTO users (email, password, name, role, address, phone, description, familySize, latitude, longitude, createdAt, updatedAt) 
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [email, hashedPassword, name, role, address, phone, description, familySize, latitude, longitude, createdAt, createdAt],
        function(err) {
          if (err) reject(err);
          else resolve(this.lastID);
        }
      );
    });

    const newUser = {
      id: result,
      email,
      name,
      role,
      address,
      phone,
      description,
      familySize,
      latitude,
      longitude,
      createdAt
    };

    // Log activity
    await logActivity(result, 'USER_REGISTERED', `New ${role} registered`, req.ip);

    const token = jwt.sign({ id: newUser.id, role: newUser.role }, JWT_SECRET, { expiresIn: "24h" });
    res.status(201).json({ user: newUser, token });
  } catch (error) {
    console.error("Registration error:", error);
    res.status(500).json({ error: "Registration failed" });
  }
});

// 2. User Login (Enhanced)
app.post("/api/login", async (req, res) => {
  const { email, password, role } = req.body;
  
  if (!email || !password || !role) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  try {
    const user = await new Promise((resolve, reject) => {
      db.get("SELECT * FROM users WHERE email = ? AND role = ?", [email, role], (err, row) => {
        if (err) reject(err);
        else resolve(row);
      });
    });

    if (!user || !(await bcrypt.compare(password, user.password))) {
      return res.status(401).json({ error: "Invalid credentials or role" });
    }

    // Update last login
    const lastLogin = new Date().toISOString();
    await new Promise((resolve, reject) => {
      db.run("UPDATE users SET lastLogin = ? WHERE id = ?", [lastLogin, user.id], (err) => {
        if (err) reject(err);
        else resolve();
      });
    });

    // Log activity
    await logActivity(user.id, 'USER_LOGIN', `${role} logged in`, req.ip);

    const { password: _, ...userWithoutPassword } = user;
    const token = jwt.sign({ id: user.id, role: user.role }, JWT_SECRET, { expiresIn: "24h" });
    res.json({ user: userWithoutPassword, token });
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({ error: "Login failed" });
  }
});

// 3. Get User Profile
app.get("/api/profile/:id", authenticateToken, async (req, res) => {
  try {
    const user = await new Promise((resolve, reject) => {
      db.get("SELECT * FROM users WHERE id = ?", [parseInt(req.params.id)], (err, row) => {
        if (err) reject(err);
        else resolve(row);
      });
    });

    if (!user || req.user.id !== user.id) {
      return res.status(403).json({ error: "Access denied" });
    }

    const { password: _, ...userWithoutPassword } = user;
    res.json(userWithoutPassword);
  } catch (error) {
    console.error("Get profile error:", error);
    res.status(500).json({ error: "Failed to get profile" });
  }
});

// 4. Create Donation (Enhanced with location)
app.post("/api/donations", authenticateToken, async (req, res) => {
  if (req.user.role !== "Donor") {
    return res.status(403).json({ error: "Only donors can create donations" });
  }
  
  const { foodType, quantity, pickupAddress, latitude, longitude, expiryTime, imageUrl } = req.body;
  
  if (!foodType || !quantity || !pickupAddress || !expiryTime) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  try {
    const createdAt = new Date().toISOString();
    const result = await new Promise((resolve, reject) => {
      db.run(
        `INSERT INTO donations (donorId, foodType, quantity, pickupAddress, latitude, longitude, expiryTime, imageUrl, status, createdAt, updatedAt) 
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'Pending', ?, ?)`,
        [req.user.id, foodType, quantity, pickupAddress, latitude, longitude, expiryTime, imageUrl, createdAt, createdAt],
        function(err) {
          if (err) reject(err);
          else resolve(this.lastID);
        }
      );
    });

    const newDonation = {
      id: result,
      donorId: req.user.id,
      foodType,
      quantity,
      pickupAddress,
      latitude,
      longitude,
      expiryTime,
      imageUrl,
      status: "Pending",
      createdAt
    };

    // Log activity
    await logActivity(req.user.id, 'DONATION_CREATED', `Created donation: ${foodType}`, req.ip);

    res.status(201).json(newDonation);
  } catch (error) {
    console.error("Create donation error:", error);
    res.status(500).json({ error: "Failed to create donation" });
  }
});

// 5. Get All Donations with Pagination
app.get("/api/donations", authenticateToken, async (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 50;
  const offset = (page - 1) * limit;

  try {
    const donations = await new Promise((resolve, reject) => {
      db.all(
        "SELECT * FROM donations ORDER BY createdAt DESC LIMIT ? OFFSET ?",
        [limit, offset],
        (err, rows) => {
          if (err) reject(err);
          else resolve(rows || []);
        }
      );
    });
    
    res.json(donations);
  } catch (error) {
    console.error("Get all donations error:", error);
    res.status(500).json({ error: "Failed to get donations" });
  }
});

// 6. Get User Donations
app.get("/api/donations/:userId", authenticateToken, async (req, res) => {
  try {
    const userDonations = await new Promise((resolve, reject) => {
      db.all(
        "SELECT * FROM donations WHERE donorId = ? ORDER BY createdAt DESC",
        [parseInt(req.params.userId)],
        (err, rows) => {
          if (err) reject(err);
          else resolve(rows || []);
        }
      );
    });
    res.json(userDonations);
  } catch (error) {
    console.error("Get user donations error:", error);
    res.status(500).json({ error: "Failed to get donations" });
  }
});

// 7. Update Donation Status
app.put("/api/donations/:id/status", authenticateToken, async (req, res) => {
  if (req.user.role !== "NGO") {
    return res.status(403).json({ error: "Only NGOs can update status" });
  }
  
  const { status } = req.body;
  if (!status) {
    return res.status(400).json({ error: "Status is required" });
  }

  try {
    const updatedAt = new Date().toISOString();
    await new Promise((resolve, reject) => {
      db.run(
        "UPDATE donations SET status = ?, ngoId = ?, updatedAt = ? WHERE id = ?",
        [status, req.user.id, updatedAt, parseInt(req.params.id)],
        function(err) {
          if (err) reject(err);
          else resolve(this.changes);
        }
      );
    });

    const donation = await new Promise((resolve, reject) => {
      db.get("SELECT * FROM donations WHERE id = ?", [parseInt(req.params.id)], (err, row) => {
        if (err) reject(err);
        else resolve(row);
      });
    });

    if (!donation) {
      return res.status(404).json({ error: "Donation not found" });
    }

    // Create notification for donor
    await createNotification(
      donation.donorId,
      'Donation Status Updated',
      `Your donation has been ${status}`,
      'DONATION_UPDATE',
      donation.id
    );

    // Log activity
    await logActivity(req.user.id, 'DONATION_STATUS_UPDATED', `Updated donation ${donation.id} to ${status}`, req.ip);

    res.json(donation);
  } catch (error) {
    console.error("Update donation status error:", error);
    res.status(500).json({ error: "Failed to update donation status" });
  }
});

// 8. Create Request (Enhanced)
app.post("/api/requests", authenticateToken, async (req, res) => {
  if (req.user.role !== "Receiver") {
    return res.status(403).json({ error: "Only receivers can create requests" });
  }
  
  const { foodType, quantity, address, latitude, longitude, notes } = req.body;
  
  if (!foodType || !quantity || !address) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  try {
    const createdAt = new Date().toISOString();
    const result = await new Promise((resolve, reject) => {
      db.run(
        `INSERT INTO requests (receiverId, foodType, quantity, address, latitude, longitude, notes, status, createdAt, updatedAt) 
         VALUES (?, ?, ?, ?, ?, ?, ?, 'Requested', ?, ?)`,
        [req.user.id, foodType, quantity, address, latitude, longitude, notes, createdAt, createdAt],
        function(err) {
          if (err) reject(err);
          else resolve(this.lastID);
        }
      );
    });

    const newRequest = {
      id: result,
      receiverId: req.user.id,
      foodType,
      quantity,
      address,
      latitude,
      longitude,
      notes,
      status: "Requested",
      createdAt
    };

    // Log activity
    await logActivity(req.user.id, 'REQUEST_CREATED', `Created request: ${foodType}`, req.ip);

    res.status(201).json(newRequest);
  } catch (error) {
    console.error("Create request error:", error);
    res.status(500).json({ error: "Failed to create request" });
  }
});

// 9. Get User Requests
app.get("/api/requests/:userId", authenticateToken, async (req, res) => {
  try {
    const userRequests = await new Promise((resolve, reject) => {
      db.all(
        "SELECT * FROM requests WHERE receiverId = ? ORDER BY createdAt DESC",
        [parseInt(req.params.userId)],
        (err, rows) => {
          if (err) reject(err);
          else resolve(rows || []);
        }
      );
    });
    res.json(userRequests);
  } catch (error) {
    console.error("Get user requests error:", error);
    res.status(500).json({ error: "Failed to get requests" });
  }
});

// 10. Update Request Status
app.put("/api/requests/:id/status", authenticateToken, async (req, res) => {
  if (req.user.role !== "NGO") {
    return res.status(403).json({ error: "Only NGOs can update status" });
  }
  
  const { status } = req.body;
  if (!status) {
    return res.status(400).json({ error: "Status is required" });
  }

  try {
    const updatedAt = new Date().toISOString();
    await new Promise((resolve, reject) => {
      db.run(
        "UPDATE requests SET status = ?, ngoId = ?, updatedAt = ? WHERE id = ?",
        [status, req.user.id, updatedAt, parseInt(req.params.id)],
        function(err) {
          if (err) reject(err);
          else resolve(this.changes);
        }
      );
    });

    const request = await new Promise((resolve, reject) => {
      db.get("SELECT * FROM requests WHERE id = ?", [parseInt(req.params.id)], (err, row) => {
        if (err) reject(err);
        else resolve(row);
      });
    });

    if (!request) {
      return res.status(404).json({ error: "Request not found" });
    }

    // Create notification for receiver
    await createNotification(
      request.receiverId,
      'Request Status Updated',
      `Your request has been ${status}`,
      'REQUEST_UPDATE',
      request.id
    );

    // Log activity
    await logActivity(req.user.id, 'REQUEST_STATUS_UPDATED', `Updated request ${request.id} to ${status}`, req.ip);

    res.json(request);
  } catch (error) {
    console.error("Update request status error:", error);
    res.status(500).json({ error: "Failed to update request status" });
  }
});

// 11. Get Notifications
app.get("/api/notifications", authenticateToken, async (req, res) => {
  try {
    const notifications = await new Promise((resolve, reject) => {
      db.all(
        "SELECT * FROM notifications WHERE userId = ? ORDER BY createdAt DESC LIMIT 50",
        [req.user.id],
        (err, rows) => {
          if (err) reject(err);
          else resolve(rows || []);
        }
      );
    });
    res.json(notifications);
  } catch (error) {
    console.error("Get notifications error:", error);
    res.status(500).json({ error: "Failed to get notifications" });
  }
});

// 12. Mark Notification as Read
app.put("/api/notifications/:id/read", authenticateToken, async (req, res) => {
  try {
    await new Promise((resolve, reject) => {
      db.run(
        "UPDATE notifications SET read = 1 WHERE id = ? AND userId = ?",
        [parseInt(req.params.id), req.user.id],
        (err) => {
          if (err) reject(err);
          else resolve();
        }
      );
    });
    res.json({ message: "Notification marked as read" });
  } catch (error) {
    console.error("Mark notification read error:", error);
    res.status(500).json({ error: "Failed to update notification" });
  }
});

// 13. Get Statistics
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
    console.error("Get stats error:", error);
    res.status(500).json({ error: "Failed to get stats" });
  }
});

// Default route
app.get("/", (req, res) => {
  res.send("Welcome to FoodLink API 🚀 (Enhanced Version)");
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: "Endpoint not found" });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({ 
    error: process.env.NODE_ENV === 'production' 
      ? 'Internal server error' 
      : err.message 
  });
});

// Graceful shutdown
process.on('SIGINT', () => {
  db.close((err) => {
    if (err) {
      console.error('Error closing database:', err.message);
    } else {
      console.log('\n✅ Database connection closed');
    }
    process.exit(0);
  });
});

app.listen(PORT, () => {
  console.log(`\n🚀 FoodLink API Server (Enhanced) running at http://localhost:${PORT}`);
  console.log(`📊 Database: ${dbPath}`);
  console.log(`🔐 JWT Secret: ${JWT_SECRET === 'your-secret-key-change-in-production' ? '⚠️  Using default (change in production!)' : '✅ Custom'}`);
  console.log(`\n✨ New Features:`);
  console.log(`  - GPS coordinates for donations/requests`);
  console.log(`  - Notifications system`);
  console.log(`  - Activity logging`);
  console.log(`  - Database indexes for performance`);
  console.log(`  - Enhanced error handling`);
  console.log(`\nEndpoints:`);
  console.log(`  POST   /api/register`);
  console.log(`  POST   /api/login`);
  console.log(`  GET    /api/profile/:id`);
  console.log(`  POST   /api/donations`);
  console.log(`  GET    /api/donations`);
  console.log(`  GET    /api/donations/:userId`);
  console.log(`  PUT    /api/donations/:id/status`);
  console.log(`  POST   /api/requests`);
  console.log(`  GET    /api/requests/:userId`);
  console.log(`  PUT    /api/requests/:id/status`);
  console.log(`  GET    /api/notifications`);
  console.log(`  PUT    /api/notifications/:id/read`);
  console.log(`  GET    /api/stats\n`);
});
