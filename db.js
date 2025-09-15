// db.js
const mysql = require('mysql2');

const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',       // your MySQL username
  password: '',       // leave empty since no password
  database: 'foodlink'
});

db.connect((err) => {
  if (err) {
    console.error('DB connection failed:', err);
  } else {
    console.log('Connected to MySQL database!');
  }
});

module.exports = db;
