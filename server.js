const express = require("express");
const db = require("./db");
const app = express();
const PORT = 3000;

app.use(express.json());

// Root route
app.get("/", (req, res) => {
  res.send("Welcome to FoodLink API 🚀");
});

/////////////////////// USERS ///////////////////////

app.get("/api/users", (req, res) => {
  db.query("SELECT * FROM users", (err, results) => {
    if (err) return res.status(500).json({ error: err });
    res.json(results);
  });
});

app.post("/api/users", (req, res) => {
  const { name, email, password_hash, phone, address, role } = req.body;
  const sql = "INSERT INTO users (name,email,password_hash,phone,address,role) VALUES (?, ?, ?, ?, ?, ?)";
  db.query(sql, [name,email,password_hash,phone,address,role], (err,result) => {
    if (err) return res.status(500).json({ error: err });
    res.status(201).json({ message: "User added!", user_id: result.insertId });
  });
});

/////////////////////// NGOs ///////////////////////

app.get("/api/ngos", (req,res) => {
  db.query("SELECT * FROM ngos", (err, results) => {
    if(err) return res.status(500).json({ error: err });
    res.json(results);
  });
});

app.post("/api/ngos", (req,res) => {
  const { ngo_name, email, password_hash, phone, address, license_doc } = req.body;
  const sql = `INSERT INTO ngos (ngo_name,email,password_hash,phone,address,license_doc) VALUES (?, ?, ?, ?, ?, ?)`;
  db.query(sql,[ngo_name,email,password_hash,phone,address,license_doc], (err,result) => {
    if(err) return res.status(500).json({ error: err });
    res.status(201).json({ message: "NGO added!", ngo_id: result.insertId });
  });
});

/////////////////////// Food Donations ///////////////////////

app.get("/api/fooddonations", (req,res) => {
  db.query("SELECT * FROM fooddonations", (err, results) => {
    if(err) return res.status(500).json({ error: err });
    res.json(results);
  });
});

app.post("/api/fooddonations", (req,res) => {
  const { user_id, ngo_id, food_type, quantity, pickup_address, expiry_time } = req.body;
  const sql = `INSERT INTO fooddonations (user_id,ngo_id,food_type,quantity,pickup_address,expiry_time) VALUES (?, ?, ?, ?, ?, ?)`;
  db.query(sql,[user_id,ngo_id,food_type,quantity,pickup_address,expiry_time], (err,result) => {
    if(err) return res.status(500).json({ error: err });
    res.status(201).json({ message: "Donation added!", donation_id: result.insertId });
  });
});

app.put("/api/fooddonations/:id", (req,res) => {
  const foodId = req.params.id;
  const { food_type, quantity, pickup_address, expiry_time, status } = req.body;
  const sql = `UPDATE fooddonations SET food_type=?,quantity=?,pickup_address=?,expiry_time=?,status=? WHERE donation_id=?`;
  db.query(sql,[food_type,quantity,pickup_address,expiry_time,status,foodId],(err,result)=>{
    if(err) return res.status(500).json({ error: err });
    if(result.affectedRows===0) return res.status(404).json({message:"Food not found"});
    res.json({message:"Food donation updated!"});
  });
});

app.delete("/api/fooddonations/:id", (req,res) => {
  const foodId=req.params.id;
  const sql="DELETE FROM fooddonations WHERE donation_id=?";
  db.query(sql,[foodId],(err,result)=>{
    if(err) return res.status(500).json({error:err});
    if(result.affectedRows===0) return res.status(404).json({message:"Food not found"});
    res.json({message:"Food donation deleted!"});
  });
});

/////////////////////// Requests ///////////////////////

app.get("/api/requests", (req,res) => {
  db.query("SELECT * FROM requests",(err,results)=>{
    if(err) return res.status(500).json({error:err});
    res.json(results);
  });
});

app.post("/api/requests", (req,res)=>{
  const {user_id,food_type,quantity,delivery_address}=req.body;
  const sql="INSERT INTO requests (user_id,food_type,quantity,delivery_address) VALUES (?,?,?,?)";
  db.query(sql,[user_id,food_type,quantity,delivery_address],(err,result)=>{
    if(err) return res.status(500).json({error:err});
    res.status(201).json({message:"Request added!", request_id: result.insertId});
  });
});

/////////////////////// Transactions ///////////////////////

app.get("/api/transactions", (req,res)=>{
  db.query("SELECT * FROM transactions",(err,results)=>{
    if(err) return res.status(500).json({error:err});
    res.json(results);
  });
});

app.post("/api/transactions", (req,res)=>{
  const {donation_id,request_id,ngo_id,status}=req.body;
  const sql="INSERT INTO transactions (donation_id,request_id,ngo_id,status) VALUES (?,?,?,?)";
  db.query(sql,[donation_id,request_id,ngo_id,status],(err,result)=>{
    if(err) return res.status(500).json({error:err});
    res.status(201).json({message:"Transaction added!", transaction_id: result.insertId});
  });
});

/////////////////////// Feedback ///////////////////////

app.get("/api/feedback",(req,res)=>{
  db.query("SELECT * FROM feedback",(err,results)=>{
    if(err) return res.status(500).json({error:err});
    res.json(results);
  });
});

app.post("/api/feedback",(req,res)=>{
  const {user_id,ngo_id,rating,comments}=req.body;
  const sql="INSERT INTO feedback (user_id,ngo_id,rating,comments) VALUES (?,?,?,?)";
  db.query(sql,[user_id,ngo_id,rating,comments],(err,result)=>{
    if(err) return res.status(500).json({error:err});
    res.status(201).json({message:"Feedback added!", feedback_id:result.insertId});
  });
});

/////////////////////// Admins ///////////////////////

app.get("/api/admins",(req,res)=>{
  db.query("SELECT * FROM admins",(err,results)=>{
    if(err) return res.status(500).json({error:err});
    res.json(results);
  });
});

app.post("/api/admins",(req,res)=>{
  const {name,email,password_hash,phone}=req.body;
  const sql="INSERT INTO admins (name,email,password_hash,phone) VALUES (?,?,?,?)";
  db.query(sql,[name,email,password_hash,phone],(err,result)=>{
    if(err) return res.status(500).json({error:err});
    res.status(201).json({message:"Admin added!", admin_id: result.insertId});
  });
});

/////////////////////// Start Server ///////////////////////
app.listen(PORT,()=>console.log(`Server running at http://localhost:${PORT}`));
