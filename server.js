const express = require("express");
const app = express();
const PORT = 3000;

// Middleware
app.use(express.json());

// Routes
const foodRoutes = require("./routes/foodRoutes");
app.use("/api", foodRoutes);

// Default route
app.get("/", (req, res) => {
  res.send("Welcome to FoodLink API 🚀");
});

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
