const express = require("express");
const cors = require("cors");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const { Pool } = require("pg");

const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || "your-secret-key-change-in-production";

// Initialize PostgreSQL connection pool
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

// Test database connection and initialize tables
async function initializeDatabase() {
  try {
    const client = await pool.connect();
    console.log("✅ Connected to PostgreSQL database");

    // Create tables if they don't exist
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        name VARCHAR(255) NOT NULL,
        role VARCHAR(50) NOT NULL,
        address TEXT,
        phone VARCHAR(50),
        description TEXT,
        familySize INTEGER,
        createdAt TIMESTAMP NOT NULL DEFAULT NOW()
      )
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS donations (
        id SERIAL PRIMARY KEY,
        donorId INTEGER NOT NULL,
        foodType VARCHAR(255) NOT NULL,
        quantity VARCHAR(255) NOT NULL,
        pickupAddress TEXT NOT NULL,
        expiryTime VARCHAR(255) NOT NULL,
        status VARCHAR(50) NOT NULL DEFAULT 'Pending',
        createdAt TIMESTAMP NOT NULL DEFAULT NOW(),
        FOREIGN KEY (donorId) REFERENCES users(id)
      )
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS requests (
        id SERIAL PRIMARY KEY,
        receiverId INTEGER NOT NULL,
        foodType VARCHAR(255) NOT NULL,
        quantity VARCHAR(255) NOT NULL,
        address TEXT NOT NULL,
        notes TEXT,
        status VARCHAR(50) NOT NULL DEFAULT 'Requested',
        createdAt TIMESTAMP NOT NULL DEFAULT NOW(),
        FOREIGN KEY (receiverId) REFERENCES users(id)
      )
    `);

    console.log("✅ Database tables initialized");
    client.release();
  } catch (err) {
    console.error("❌ Database initialization error:", err);
    process.exit(1);
  }
}

initializeDatabase();

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
  const token = authHeader && authHeader.split(" ")[1];
  if (!token) return res.status(401).json({ error: "Access denied" });

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ error: "Invalid token" });
    req.user = user;
    next();
  });
};

// Routes
// Health check endpoint
app.get("/api/health", async (req, res) => {
  try {
    const result = await pool.query("SELECT COUNT(*) as count FROM users");
    res.json({
      status: "ok",
      message: "FoodLink API is running",
      database: "PostgreSQL connected",
      users: parseInt(result.rows[0].count),
      timestamp: new Date().toISOString()
    });
  } catch (err) {
    res.status(500).json({
      status: "error",
      message: "Database connection failed",
      error: err.message
    });
  }
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
    const existingUser = await pool.query("SELECT * FROM users WHERE email = $1", [email]);

    if (existingUser.rows.length > 0) {
      return res.status(400).json({ error: "User already exists" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert new user
    const result = await pool.query(
      `INSERT INTO users (email, password, name, role, address, phone, description, familySize, createdAt) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW()) RETURNING *`,
      [email, hashedPassword, name, role, address, phone, description, familySize]
    );

    const newUser = result.rows[0];
    const { password: _, ...userWithoutPassword } = newUser;

    // Generate JWT
    const token = jwt.sign({ id: newUser.id, role: newUser.role }, JWT_SECRET, { expiresIn: "24h" });
    res.status(201).json({ user: userWithoutPassword, token });
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
    const result = await pool.query("SELECT * FROM users WHERE email = $1 AND role = $2", [email, role]);

    if (result.rows.length === 0) {
      return res.status(401).json({ error: "Invalid credentials or role" });
    }

    const user = result.rows[0];

    if (!(await bcrypt.compare(password, user.password))) {
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
    const result = await pool.query("SELECT * FROM users WHERE id = $1", [parseInt(req.params.id)]);

    if (result.rows.length === 0 || req.user.id !== result.rows[0].id) {
      return res.status(403).json({ error: "Access denied" });
    }

    const { password: _, ...userWithoutPassword } = result.rows[0];
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
    const result = await pool.query(
      `INSERT INTO donations (donorId, foodType, quantity, pickupAddress, expiryTime, status, createdAt) 
       VALUES ($1, $2, $3, $4, $5, 'Pending', NOW()) RETURNING *`,
      [req.user.id, foodType, quantity, pickupAddress, expiryTime]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error("Create donation error:", error);
    res.status(500).json({ error: "Failed to create donation" });
  }
});

// Get all donations (for map view and NGO dashboard)
app.get("/api/donations", authenticateToken, async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM donations ORDER BY createdAt DESC");
    res.json(result.rows);
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
    const result = await pool.query(
      "SELECT * FROM donations WHERE donorId = $1 ORDER BY createdAt DESC",
      [parseInt(req.params.userId)]
    );
    res.json(result.rows);
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
    const result = await pool.query(
      "UPDATE donations SET status = $1 WHERE id = $2 RETURNING *",
      [status, parseInt(req.params.id)]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Donation not found" });
    }

    res.json(result.rows[0]);
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
    const result = await pool.query(
      `INSERT INTO requests (receiverId, foodType, quantity, address, notes, status, createdAt) 
       VALUES ($1, $2, $3, $4, $5, 'Requested', NOW()) RETURNING *`,
      [req.user.id, foodType, quantity, address, notes]
    );

    res.status(201).json(result.rows[0]);
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
    const result = await pool.query(
      "SELECT * FROM requests WHERE receiverId = $1 ORDER BY createdAt DESC",
      [parseInt(req.params.userId)]
    );
    res.json(result.rows);
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
    const result = await pool.query(
      "UPDATE requests SET status = $1 WHERE id = $2 RETURNING *",
      [status, parseInt(req.params.id)]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Request not found" });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error("Update request status error:", error);
    res.status(500).json({ error: "Failed to update request status" });
  }
});

// Your original foods route (kept for compatibility)
app.get("/api/foods", (req, res) => {
  res.json([{ id: 1, name: "Pizza", price: 250 }]);
});

app.post("/api/foods", (req, res) => {
  res.status(201).json({ message: "Food added" });
});

// Default route
app.get("/", (req, res) => {
  res.send("Welcome to FoodLink API 🚀 (PostgreSQL)");
});

// Graceful shutdown
process.on('SIGINT', async () => {
  await pool.end();
  console.log('\n✅ Database connection closed');
  process.exit(0);
});

app.listen(PORT, () => {
  console.log(`\n🚀 FoodLink API Server running at http://localhost:${PORT}`);
  console.log(`📊 Database: PostgreSQL`);
  console.log(`🔐 JWT Secret: ${JWT_SECRET === 'your-secret-key-change-in-production' ? '⚠️  Using default (change in production!)' : '✅ Custom'}`);
  console.log(`\nEndpoints:`);
  console.log(`  GET    /api/health`);
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
