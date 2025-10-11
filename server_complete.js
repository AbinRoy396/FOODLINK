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

    // Create Admins table
    await client.query(`
      CREATE TABLE IF NOT EXISTS admins (
        admin_id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        phone VARCHAR(50),
        created_at TIMESTAMP NOT NULL DEFAULT NOW()
      )
    `);

    // Create NGOs table
    await client.query(`
      CREATE TABLE IF NOT EXISTS ngos (
        ngo_id SERIAL PRIMARY KEY,
        ngo_name VARCHAR(255) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        phone VARCHAR(50),
        address TEXT,
        license_doc VARCHAR(500),
        verified BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP NOT NULL DEFAULT NOW()
      )
    `);

    // Create Users table
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        user_id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        phone VARCHAR(50),
        address TEXT,
        role VARCHAR(50) NOT NULL,
        created_at TIMESTAMP NOT NULL DEFAULT NOW()
      )
    `);

    // Create FoodDonations table
    await client.query(`
      CREATE TABLE IF NOT EXISTS fooddonations (
        donation_id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(user_id),
        ngo_id INTEGER REFERENCES ngos(ngo_id),
        food_type VARCHAR(255) NOT NULL,
        quantity VARCHAR(255) NOT NULL,
        pickup_address TEXT NOT NULL,
        expiry_time VARCHAR(255) NOT NULL,
        status VARCHAR(50) NOT NULL DEFAULT 'Pending',
        created_at TIMESTAMP NOT NULL DEFAULT NOW()
      )
    `);

    // Create Requests table
    await client.query(`
      CREATE TABLE IF NOT EXISTS requests (
        request_id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(user_id),
        food_type VARCHAR(255) NOT NULL,
        quantity VARCHAR(255) NOT NULL,
        delivery_address TEXT NOT NULL,
        status VARCHAR(50) NOT NULL DEFAULT 'Requested',
        created_at TIMESTAMP NOT NULL DEFAULT NOW()
      )
    `);

    // Create Feedback table
    await client.query(`
      CREATE TABLE IF NOT EXISTS feedback (
        feedback_id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(user_id),
        ngo_id INTEGER REFERENCES ngos(ngo_id),
        rating INTEGER CHECK (rating >= 1 AND rating <= 5),
        comments TEXT,
        created_at TIMESTAMP NOT NULL DEFAULT NOW()
      )
    `);

    // Create Transactions table
    await client.query(`
      CREATE TABLE IF NOT EXISTS transactions (
        transaction_id SERIAL PRIMARY KEY,
        donation_id INTEGER REFERENCES fooddonations(donation_id),
        request_id INTEGER REFERENCES requests(request_id),
        ngo_id INTEGER REFERENCES ngos(ngo_id),
        status VARCHAR(50) NOT NULL,
        timestamp TIMESTAMP NOT NULL DEFAULT NOW()
      )
    `);

    console.log("✅ Database tables initialized (Complete Schema)");
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

// Health check endpoint
app.get("/api/health", async (req, res) => {
  try {
    const usersCount = await pool.query("SELECT COUNT(*) as count FROM users");
    const ngosCount = await pool.query("SELECT COUNT(*) as count FROM ngos");
    const donationsCount = await pool.query("SELECT COUNT(*) as count FROM fooddonations");
    
    res.json({
      status: "ok",
      message: "FoodLink API is running (Complete Schema)",
      database: "PostgreSQL connected",
      stats: {
        users: parseInt(usersCount.rows[0].count),
        ngos: parseInt(ngosCount.rows[0].count),
        donations: parseInt(donationsCount.rows[0].count)
      },
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

// ==================== USER ROUTES ====================

// User Registration
app.post("/api/register", async (req, res) => {
  const { email, password, name, role, address, phone } = req.body;

  if (!email || !password || !name || !role) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    return res.status(400).json({ error: "Invalid email format" });
  }

  if (password.length < 6) {
    return res.status(400).json({ error: "Password must be at least 6 characters" });
  }

  if (!['Donor', 'Receiver'].includes(role)) {
    return res.status(400).json({ error: "Invalid role. Use 'Donor' or 'Receiver'" });
  }

  try {
    const existingUser = await pool.query("SELECT * FROM users WHERE email = $1", [email]);

    if (existingUser.rows.length > 0) {
      return res.status(400).json({ error: "User already exists" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const result = await pool.query(
      `INSERT INTO users (email, password_hash, name, role, address, phone, created_at) 
       VALUES ($1, $2, $3, $4, $5, $6, NOW()) RETURNING user_id, email, name, role, address, phone, created_at`,
      [email, hashedPassword, name, role, address, phone]
    );

    const newUser = result.rows[0];
    const token = jwt.sign({ id: newUser.user_id, role: newUser.role, type: 'user' }, JWT_SECRET, { expiresIn: "24h" });
    res.status(201).json({ user: newUser, token });
  } catch (error) {
    console.error("Registration error:", error);
    res.status(500).json({ error: "Registration failed" });
  }
});

// User Login
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

    if (!(await bcrypt.compare(password, user.password_hash))) {
      return res.status(401).json({ error: "Invalid credentials or role" });
    }

    const { password_hash, ...userWithoutPassword } = user;
    const token = jwt.sign({ id: user.user_id, role: user.role, type: 'user' }, JWT_SECRET, { expiresIn: "24h" });
    res.json({ user: userWithoutPassword, token });
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({ error: "Login failed" });
  }
});

// ==================== NGO ROUTES ====================

// NGO Registration
app.post("/api/ngo/register", async (req, res) => {
  const { email, password, ngo_name, phone, address, license_doc } = req.body;

  if (!email || !password || !ngo_name) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  try {
    const existingNGO = await pool.query("SELECT * FROM ngos WHERE email = $1", [email]);

    if (existingNGO.rows.length > 0) {
      return res.status(400).json({ error: "NGO already exists" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const result = await pool.query(
      `INSERT INTO ngos (ngo_name, email, password_hash, phone, address, license_doc, verified, created_at) 
       VALUES ($1, $2, $3, $4, $5, $6, FALSE, NOW()) RETURNING ngo_id, ngo_name, email, phone, address, verified, created_at`,
      [ngo_name, email, hashedPassword, phone, address, license_doc]
    );

    const newNGO = result.rows[0];
    const token = jwt.sign({ id: newNGO.ngo_id, type: 'ngo' }, JWT_SECRET, { expiresIn: "24h" });
    res.status(201).json({ ngo: newNGO, token });
  } catch (error) {
    console.error("NGO registration error:", error);
    res.status(500).json({ error: "NGO registration failed" });
  }
});

// NGO Login
app.post("/api/ngo/login", async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  try {
    const result = await pool.query("SELECT * FROM ngos WHERE email = $1", [email]);

    if (result.rows.length === 0) {
      return res.status(401).json({ error: "Invalid credentials" });
    }

    const ngo = result.rows[0];

    if (!(await bcrypt.compare(password, ngo.password_hash))) {
      return res.status(401).json({ error: "Invalid credentials" });
    }

    const { password_hash, ...ngoWithoutPassword } = ngo;
    const token = jwt.sign({ id: ngo.ngo_id, type: 'ngo' }, JWT_SECRET, { expiresIn: "24h" });
    res.json({ ngo: ngoWithoutPassword, token });
  } catch (error) {
    console.error("NGO login error:", error);
    res.status(500).json({ error: "Login failed" });
  }
});

// ==================== DONATION ROUTES ====================

// Create Donation
app.post("/api/donations", authenticateToken, async (req, res) => {
  if (req.user.type !== 'user' || req.user.role !== "Donor") {
    return res.status(403).json({ error: "Only donors can create donations" });
  }

  const { food_type, quantity, pickup_address, expiry_time } = req.body;

  if (!food_type || !quantity || !pickup_address || !expiry_time) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  try {
    const result = await pool.query(
      `INSERT INTO fooddonations (user_id, food_type, quantity, pickup_address, expiry_time, status, created_at) 
       VALUES ($1, $2, $3, $4, $5, 'Pending', NOW()) RETURNING *`,
      [req.user.id, food_type, quantity, pickup_address, expiry_time]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error("Create donation error:", error);
    res.status(500).json({ error: "Failed to create donation" });
  }
});

// Get all donations
app.get("/api/donations", authenticateToken, async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM fooddonations ORDER BY created_at DESC");
    res.json(result.rows);
  } catch (error) {
    console.error("Get donations error:", error);
    res.status(500).json({ error: "Failed to get donations" });
  }
});

// Get user donations
app.get("/api/donations/:userId", authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT * FROM fooddonations WHERE user_id = $1 ORDER BY created_at DESC",
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
  if (req.user.type !== 'ngo') {
    return res.status(403).json({ error: "Only NGOs can update donation status" });
  }

  const { status } = req.body;
  if (!status) {
    return res.status(400).json({ error: "Status is required" });
  }

  try {
    const result = await pool.query(
      "UPDATE fooddonations SET status = $1, ngo_id = $2 WHERE donation_id = $3 RETURNING *",
      [status, req.user.id, parseInt(req.params.id)]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Donation not found" });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error("Update donation error:", error);
    res.status(500).json({ error: "Failed to update donation" });
  }
});

// ==================== REQUEST ROUTES ====================

// Create Request
app.post("/api/requests", authenticateToken, async (req, res) => {
  if (req.user.type !== 'user' || req.user.role !== "Receiver") {
    return res.status(403).json({ error: "Only receivers can create requests" });
  }

  const { food_type, quantity, delivery_address } = req.body;

  if (!food_type || !quantity || !delivery_address) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  try {
    const result = await pool.query(
      `INSERT INTO requests (user_id, food_type, quantity, delivery_address, status, created_at) 
       VALUES ($1, $2, $3, $4, 'Requested', NOW()) RETURNING *`,
      [req.user.id, food_type, quantity, delivery_address]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error("Create request error:", error);
    res.status(500).json({ error: "Failed to create request" });
  }
});

// Get user requests
app.get("/api/requests/:userId", authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT * FROM requests WHERE user_id = $1 ORDER BY created_at DESC",
      [parseInt(req.params.userId)]
    );
    res.json(result.rows);
  } catch (error) {
    console.error("Get requests error:", error);
    res.status(500).json({ error: "Failed to get requests" });
  }
});

// ==================== FEEDBACK ROUTES ====================

// Create Feedback
app.post("/api/feedback", authenticateToken, async (req, res) => {
  const { ngo_id, rating, comments } = req.body;

  if (!ngo_id || !rating) {
    return res.status(400).json({ error: "NGO ID and rating are required" });
  }

  if (rating < 1 || rating > 5) {
    return res.status(400).json({ error: "Rating must be between 1 and 5" });
  }

  try {
    const result = await pool.query(
      `INSERT INTO feedback (user_id, ngo_id, rating, comments, created_at) 
       VALUES ($1, $2, $3, $4, NOW()) RETURNING *`,
      [req.user.id, ngo_id, rating, comments]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error("Create feedback error:", error);
    res.status(500).json({ error: "Failed to create feedback" });
  }
});

// Get NGO feedback
app.get("/api/feedback/ngo/:ngoId", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT * FROM feedback WHERE ngo_id = $1 ORDER BY created_at DESC",
      [parseInt(req.params.ngoId)]
    );
    res.json(result.rows);
  } catch (error) {
    console.error("Get feedback error:", error);
    res.status(500).json({ error: "Failed to get feedback" });
  }
});

// ==================== TRANSACTION ROUTES ====================

// Create Transaction
app.post("/api/transactions", authenticateToken, async (req, res) => {
  if (req.user.type !== 'ngo') {
    return res.status(403).json({ error: "Only NGOs can create transactions" });
  }

  const { donation_id, request_id, status } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO transactions (donation_id, request_id, ngo_id, status, timestamp) 
       VALUES ($1, $2, $3, $4, NOW()) RETURNING *`,
      [donation_id, request_id, req.user.id, status]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error("Create transaction error:", error);
    res.status(500).json({ error: "Failed to create transaction" });
  }
});

// Get all transactions
app.get("/api/transactions", authenticateToken, async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM transactions ORDER BY timestamp DESC");
    res.json(result.rows);
  } catch (error) {
    console.error("Get transactions error:", error);
    res.status(500).json({ error: "Failed to get transactions" });
  }
});

// Default route
app.get("/", (req, res) => {
  res.send("Welcome to FoodLink API 🚀 (Complete Schema with ER Diagram)");
});

// Graceful shutdown
process.on('SIGINT', async () => {
  await pool.end();
  console.log('\n✅ Database connection closed');
  process.exit(0);
});

app.listen(PORT, () => {
  console.log(`\n🚀 FoodLink API Server running at http://localhost:${PORT}`);
  console.log(`📊 Database: PostgreSQL (Complete Schema)`);
  console.log(`🔐 JWT Secret: ${JWT_SECRET === 'your-secret-key-change-in-production' ? '⚠️  Using default' : '✅ Custom'}`);
  console.log(`\nTables: Users, NGOs, Admins, FoodDonations, Requests, Feedback, Transactions`);
});
