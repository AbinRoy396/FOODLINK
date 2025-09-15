// db.js
const mysql = require('mysql2');

// create connection
const db = mysql.createConnection({
  host: 'localhost',    // or your DB host
  user: 'root',         // your MySQL user
  password: '', // your MySQL password
  database: 'foodlink', // your database name
});

// connect to DB
db.connect((err) => {
  if (err) {
    console.error('DB connection failed:', err);
  } else {
    console.log('Connected to MySQL database!');
  }
});

module.exports = db;
