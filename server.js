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

// Create tables if they don't exist
function initializeDatabase() {
  db.serialize(() => {
    // Users table
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
      createdAt TEXT NOT NULL
    )`);

    // Donations table
    db.run(`CREATE TABLE IF NOT EXISTS donations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      donorId INTEGER NOT NULL,
      foodType TEXT NOT NULL,
      quantity TEXT NOT NULL,
      pickupAddress TEXT NOT NULL,
      expiryTime TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'Pending',
      createdAt TEXT NOT NULL,
      FOREIGN KEY (donorId) REFERENCES users(id)
    )`);

    // Requests table
    db.run(`CREATE TABLE IF NOT EXISTS requests (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      receiverId INTEGER NOT NULL,
      foodType TEXT NOT NULL,
      quantity TEXT NOT NULL,
      address TEXT NOT NULL,
      notes TEXT,
      status TEXT NOT NULL DEFAULT 'Requested',
      createdAt TEXT NOT NULL,
      FOREIGN KEY (receiverId) REFERENCES users(id)
    )`);

    console.log("✅ Database tables initialized");
  });
}

// Middleware
app.use(cors({ origin: "*" }));
app.use(express.json());

// Request logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Auth Middleware (protect routes)
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];  // Bearer TOKEN
  if (!token) return res.status(401).json({ error: "Access denied" });

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ error: "Invalid token" });
    req.user = user;  // Attach user to req
    next();
  });
};

// Routes
// Health check endpoint
app.get("/api/health", (req, res) => {
  db.get("SELECT COUNT(*) as count FROM users", (err, row) => {
    if (err) {
      return res.status(500).json({ 
        status: "error", 
        message: "Database connection failed",
        error: err.message 
      });
    }
    res.json({ 
      status: "ok", 
      message: "FoodLink API is running",
      database: "connected",
      users: row.count,
      timestamp: new Date().toISOString()
    });
  });
});

// 1. User Registration
app.post("/api/register", async (req, res) => {
  const { email, password, name, role, address, phone, description, familySize } = req.body;
  
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
    // Check if user exists
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

    // Insert new user
    const result = await new Promise((resolve, reject) => {
      db.run(
        `INSERT INTO users (email, password, name, role, address, phone, description, familySize, createdAt) 
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [email, hashedPassword, name, role, address, phone, description, familySize, createdAt],
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
      createdAt
    };

    // Generate JWT
    const token = jwt.sign({ id: newUser.id, role: newUser.role }, JWT_SECRET, { expiresIn: "24h" });
    res.status(201).json({ user: newUser, token });
  } catch (error) {
    console.error("Registration error:", error);
    res.status(500).json({ error: "Registration failed" });
  }
});

// 2. User Login
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

    // Remove password from response
    const { password: _, ...userWithoutPassword } = user;
    const token = jwt.sign({ id: user.id, role: user.role }, JWT_SECRET, { expiresIn: "24h" });
    res.json({ user: userWithoutPassword, token });
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({ error: "Login failed" });
  }
});

// 3. Get User Profile (protected)
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

// 4. Donations Routes
app.post("/api/donations", authenticateToken, async (req, res) => {
  if (req.user.role !== "Donor") {
    return res.status(403).json({ error: "Only donors can create donations" });
  }
  
  const { foodType, quantity, pickupAddress, expiryTime } = req.body;
  
  if (!foodType || !quantity || !pickupAddress || !expiryTime) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  try {
    const createdAt = new Date().toISOString();
    const result = await new Promise((resolve, reject) => {
      db.run(
        `INSERT INTO donations (donorId, foodType, quantity, pickupAddress, expiryTime, status, createdAt) 
         VALUES (?, ?, ?, ?, ?, 'Pending', ?)`,
        [req.user.id, foodType, quantity, pickupAddress, expiryTime, createdAt],
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
      expiryTime,
      status: "Pending",
      createdAt
    };

    res.status(201).json(newDonation);
  } catch (error) {
    console.error("Create donation error:", error);
    res.status(500).json({ error: "Failed to create donation" });
  }
});

// Get all donations (for map view and NGO dashboard)
app.get("/api/donations", authenticateToken, async (req, res) => {
  try {
    const donations = await new Promise((resolve, reject) => {
      db.all("SELECT * FROM donations ORDER BY createdAt DESC", [], (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      });
    });
    res.json(donations);
  } catch (error) {
    console.error("Get all donations error:", error);
    res.status(500).json({ error: "Failed to get donations" });
  }
});

app.get("/api/donations/:userId", authenticateToken, async (req, res) => {
  if (req.user.role !== "Donor" && req.user.role !== "NGO") {
    return res.status(403).json({ error: "Access denied" });
  }

  try {
    const userDonations = await new Promise((resolve, reject) => {
      db.all("SELECT * FROM donations WHERE donorId = ? ORDER BY createdAt DESC", [parseInt(req.params.userId)], (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      });
    });
    res.json(userDonations);
  } catch (error) {
    console.error("Get user donations error:", error);
    res.status(500).json({ error: "Failed to get donations" });
  }
});

// NGO: Update donation status
app.put("/api/donations/:id/status", authenticateToken, async (req, res) => {
  if (req.user.role !== "NGO") {
    return res.status(403).json({ error: "Only NGOs can update status" });
  }
  
  const { status } = req.body;
  if (!status) {
    return res.status(400).json({ error: "Status is required" });
  }

  try {
    await new Promise((resolve, reject) => {
      db.run("UPDATE donations SET status = ? WHERE id = ?", [status, parseInt(req.params.id)], function(err) {
        if (err) reject(err);
        else resolve(this.changes);
      });
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

    res.json(donation);
  } catch (error) {
    console.error("Update donation status error:", error);
    res.status(500).json({ error: "Failed to update donation status" });
  }
});

// 5. Requests Routes
app.post("/api/requests", authenticateToken, async (req, res) => {
  if (req.user.role !== "Receiver") {
    return res.status(403).json({ error: "Only receivers can create requests" });
  }
  
  const { foodType, quantity, address, notes } = req.body;
  
  if (!foodType || !quantity || !address) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  try {
    const createdAt = new Date().toISOString();
    const result = await new Promise((resolve, reject) => {
      db.run(
        `INSERT INTO requests (receiverId, foodType, quantity, address, notes, status, createdAt) 
         VALUES (?, ?, ?, ?, ?, 'Requested', ?)`,
        [req.user.id, foodType, quantity, address, notes, createdAt],
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
      notes,
      status: "Requested",
      createdAt
    };

    res.status(201).json(newRequest);
  } catch (error) {
    console.error("Create request error:", error);
    res.status(500).json({ error: "Failed to create request" });
  }
});

app.get("/api/requests/:userId", authenticateToken, async (req, res) => {
  if (req.user.role !== "Receiver" && req.user.role !== "NGO") {
    return res.status(403).json({ error: "Access denied" });
  }

  try {
    const userRequests = await new Promise((resolve, reject) => {
      db.all("SELECT * FROM requests WHERE receiverId = ? ORDER BY createdAt DESC", [parseInt(req.params.userId)], (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      });
    });
    res.json(userRequests);
  } catch (error) {
    console.error("Get user requests error:", error);
    res.status(500).json({ error: "Failed to get requests" });
  }
});

// NGO: Update request status
app.put("/api/requests/:id/status", authenticateToken, async (req, res) => {
  if (req.user.role !== "NGO") {
    return res.status(403).json({ error: "Only NGOs can update status" });
  }
  
  const { status } = req.body;
  if (!status) {
    return res.status(400).json({ error: "Status is required" });
  }

  try {
    await new Promise((resolve, reject) => {
      db.run("UPDATE requests SET status = ? WHERE id = ?", [status, parseInt(req.params.id)], function(err) {
        if (err) reject(err);
        else resolve(this.changes);
      });
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

    res.json(request);
  } catch (error) {
    console.error("Update request status error:", error);
    res.status(500).json({ error: "Failed to update request status" });
  }
});

// Your original foods route (kept for compatibility)
app.get("/api/foods", (req, res) => {
  res.json([{ id: 1, name: "Pizza", price: 250 }]);  // Mock data
});

app.post("/api/foods", (req, res) => {
  res.status(201).json({ message: "Food added" });
});

// Default route
app.get("/", (req, res) => {
  res.send("Welcome to FoodLink API 🚀");
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
  console.log(`\n🚀 FoodLink API Server running at http://localhost:${PORT}`);
  console.log(`📊 Database: ${dbPath}`);
  console.log(`🔐 JWT Secret: ${JWT_SECRET === 'your-secret-key-change-in-production' ? '⚠️  Using default (change in production!)' : '✅ Custom'}`);
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
  console.log(`  PUT    /api/requests/:id/status\n`);
});