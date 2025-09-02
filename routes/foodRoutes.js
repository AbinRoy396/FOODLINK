const express = require("express");
const router = express.Router();

// Temporary "database"
let foods = [
  { id: 1, name: "Pizza", price: 250 },
  { id: 2, name: "Burger", price: 120 },
  { id: 3, name: "Pasta", price: 180 }
];

// Get all foods
router.get("/foods", (req, res) => {
  res.json(foods);
});

// Add a new food
router.post("/foods", (req, res) => {
  const newFood = { id: foods.length + 1, ...req.body };
  foods.push(newFood);
  res.status(201).json(newFood);
});

module.exports = router;
