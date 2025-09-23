const express = require("express");
const cors = require("cors");  // Add CORS for Flutter (mobile/web) access
const jwt = require("jsonwebtoken");  // For auth tokens
const bcrypt = require("bcryptjs");  // For password hashing

const app = express();
const PORT = 3000;
const JWT_SECRET = "your-secret-key";  // Change in production (use env var)

// Middleware
app.use(cors({ origin: "*" }));  // Allow all origins for dev; restrict later
app.use(express.json());

// In-memory "DB" (replace with real DB later)
let users = [];  // { id, email, password (hashed), name, role, address }
let donations = [];  // { id, donorId, foodType, quantity, pickupAddress, expiryTime, status, createdAt }
let requests = [];  // { id, receiverId, foodType, quantity, address, notes, status, createdAt }

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
// 1. User Registration
app.post("/api/register", async (req, res) => {
  const { email, password, name, role, address } = req.body;
  if (!email || !password || !name || !role) {
    return res.status(400).json({ error: "Missing required fields" });
  }
  if (users.find(u => u.email === email)) {
    return res.status(400).json({ error: "User  already exists" });
  }

  const hashedPassword = await bcrypt.hash(password, 10);
  const newUser  = {
    id: users.length + 1,
    email,
    password: hashedPassword,
    name,
    role,  // 'Donor', 'NGO', 'Receiver'
    address,
    createdAt: new Date().toISOString()
  };
  users.push(newUser );

  // Generate JWT
  const token = jwt.sign({ id: newUser .id, role: newUser .role }, JWT_SECRET, { expiresIn: "1h" });
  res.status(201).json({ user: newUser , token });
});

// 2. User Login
app.post("/api/login", async (req, res) => {
  const { email, password, role } = req.body;  // Role from dropdown
  const user = users.find(u => u.email === email && u.role === role);
  if (!user || !(await bcrypt.compare(password, user.password))) {
    return res.status(401).json({ error: "Invalid credentials or role" });
  }

  const token = jwt.sign({ id: user.id, role: user.role }, JWT_SECRET, { expiresIn: "1h" });
  res.json({ user, token });
});

// 3. Get User Profile (protected)
app.get("/api/profile/:id", authenticateToken, (req, res) => {
  const user = users.find(u => u.id === parseInt(req.params.id));
  if (!user || req.user.id !== user.id) {
    return res.status(403).json({ error: "Access denied" });
  }
  res.json(user);
});

// 4. Donations Routes
app.post("/api/donations", authenticateToken, (req, res) => {
  if (req.user.role !== "Donor") return res.status(403).json({ error: "Only donors can create donations" });
  const { foodType, quantity, pickupAddress, expiryTime } = req.body;
  const newDonation = {
    id: donations.length + 1,
    donorId: req.user.id,
    foodType,
    quantity,
    pickupAddress,
    expiryTime,
    status: "Pending",
    createdAt: new Date().toISOString()
  };
  donations.push(newDonation);
  res.status(201).json(newDonation);
});

app.get("/api/donations/:userId", authenticateToken, (req, res) => {
  if (req.user.role !== "Donor" && req.user.role !== "NGO") {
    return res.status(403).json({ error: "Access denied" });
  }
  const userDonations = donations.filter(d => d.donorId === parseInt(req.params.userId));
  res.json(userDonations);
});

// NGO: Update donation status (e.g., verify)
app.put("/api/donations/:id/status", authenticateToken, (req, res) => {
  if (req.user.role !== "NGO") return res.status(403).json({ error: "Only NGOs can update status" });
  const donation = donations.find(d => d.id === parseInt(req.params.id));
  if (!donation) return res.status(404).json({ error: "Donation not found" });
  donation.status = req.body.status;  // e.g., "Verified", "Allocated"
  res.json(donation);
});

// 5. Requests Routes
app.post("/api/requests", authenticateToken, (req, res) => {
  if (req.user.role !== "Receiver") return res.status(403).json({ error: "Only receivers can create requests" });
  const { foodType, quantity, address, notes } = req.body;
  const newRequest = {
    id: requests.length + 1,
    receiverId: req.user.id,
    foodType,
    quantity,
    address,
    notes,
    status: "Requested",
    createdAt: new Date().toISOString()
  };
  requests.push(newRequest);
  res.status(201).json(newRequest);
});

app.get("/api/requests/:userId", authenticateToken, (req, res) => {
  if (req.user.role !== "Receiver" && req.user.role !== "NGO") {
    return res.status(403).json({ error: "Access denied" });
  }
  const userRequests = requests.filter(r => r.receiverId === parseInt(req.params.userId));
  res.json(userRequests);
});

// NGO: Update request status (e.g., allocate)
app.put("/api/requests/:id/status", authenticateToken, (req, res) => {
  if (req.user.role !== "NGO") return res.status(403).json({ error: "Only NGOs can update status" });
  const request = requests.find(r => r.id === parseInt(req.params.id));
  if (!request) return res.status(404).json({ error: "Request not found" });
  request.status = req.body.status;  // e.g., "Matched", "Fulfilled"
  res.json(request);
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

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});