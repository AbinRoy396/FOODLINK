const express = require("express");
const app = express();
const PORT = 3000;

// Middleware to handle JSON request body
app.use(express.json());

// Dummy food data
let foods = [
  { id: 1, name: "Pizza", price: 250 },
  { id: 2, name: "Burger", price: 120 },
  { id: 3, name: "Pasta", price: 180 }
];

// Root route
app.get("/", (req, res) => {
  res.send("Welcome to FoodLink API 🚀");
});

// GET all foods
app.get("/api/foods", (req, res) => {
  res.json(foods);
});

// GET food by ID
app.get("/api/foods/:id", (req, res) => {
  const foodId = parseInt(req.params.id);
  const food = foods.find(f => f.id === foodId);

  if (food) {
    res.json(food);
  } else {
    res.status(404).json({ message: "Food not found" });
  }
});

// ✅ POST - Add a new food
app.post("/api/foods", (req, res) => {
  const { name, price } = req.body;

  if (!name || !price) {
    return res.status(400).json({ message: "Name and price are required" });
  }

  const newFood = {
    id: foods.length + 1,
    name,
    price
  };

  foods.push(newFood);
  res.status(201).json(newFood);
});

// UPDATE a food by ID
app.put("/api/foods/:id", (req, res) => {
  const foodId = parseInt(req.params.id);
  const { name, price } = req.body;

  // find the food by ID
  const food = foods.find(f => f.id === foodId);

  if (food) {
    if (name) food.name = name;     // update name if provided
    if (price) food.price = price; // update price if provided

    res.json(food);
  } else {
    res.status(404).json({ message: "Food not found" });
  }
});

// DELETE a food by ID
app.delete("/api/foods/:id", (req, res) => {
  const foodId = parseInt(req.params.id);

  // find index of the food
  const index = foods.findIndex(f => f.id === foodId);

  if (index !== -1) {
    const deletedFood = foods.splice(index, 1); // remove the food
    res.json({ message: "Food deleted", food: deletedFood[0] });
  } else {
    res.status(404).json({ message: "Food not found" });
  }
});

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
