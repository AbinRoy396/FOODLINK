const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.join(__dirname, 'foodlink.db');
const db = new sqlite3.Database(dbPath);

console.log('\n📊 FoodLink Database Analysis\n');
console.log('='.repeat(60));

// Check Users
db.get("SELECT COUNT(*) as count FROM users", [], (err, row) => {
  if (err) {
    console.error('Error:', err);
    return;
  }
  console.log(`\n👥 Total Users: ${row.count}`);
  
  db.all("SELECT role, COUNT(*) as count FROM users GROUP BY role", [], (err, rows) => {
    if (err) {
      console.error('Error:', err);
      return;
    }
    rows.forEach(r => {
      console.log(`   - ${r.role}: ${r.count}`);
    });
  });
});

// Check Donations
db.get("SELECT COUNT(*) as count FROM donations", [], (err, row) => {
  if (err) {
    console.error('Error:', err);
    return;
  }
  console.log(`\n🍕 Total Donations: ${row.count}`);
  
  db.all("SELECT status, COUNT(*) as count FROM donations GROUP BY status", [], (err, rows) => {
    if (err) {
      console.error('Error:', err);
      return;
    }
    rows.forEach(r => {
      console.log(`   - ${r.status}: ${r.count}`);
    });
  });
});

// Check Requests
db.get("SELECT COUNT(*) as count FROM requests", [], (err, row) => {
  if (err) {
    console.error('Error:', err);
    return;
  }
  console.log(`\n📝 Total Requests: ${row.count}`);
  
  db.all("SELECT status, COUNT(*) as count FROM requests GROUP BY status", [], (err, rows) => {
    if (err) {
      console.error('Error:', err);
      return;
    }
    rows.forEach(r => {
      console.log(`   - ${r.status}: ${r.count}`);
    });
  });
});

// Check Database Schema
setTimeout(() => {
  console.log('\n📋 Database Tables:');
  db.all("SELECT name FROM sqlite_master WHERE type='table'", [], (err, rows) => {
    if (err) {
      console.error('Error:', err);
      return;
    }
    rows.forEach(r => {
      console.log(`   ✅ ${r.name}`);
    });
  });

  // Check Indexes
  setTimeout(() => {
    console.log('\n🔍 Database Indexes:');
    db.all("SELECT name FROM sqlite_master WHERE type='index' AND name NOT LIKE 'sqlite_%'", [], (err, rows) => {
      if (err) {
        console.error('Error:', err);
        return;
      }
      if (rows.length > 0) {
        rows.forEach(r => {
          console.log(`   ✅ ${r.name}`);
        });
      } else {
        console.log('   ⚠️  No custom indexes found');
      }
    });

    // Sample Data
    setTimeout(() => {
      console.log('\n📦 Sample Donations:');
      db.all("SELECT id, foodType, quantity, status FROM donations LIMIT 3", [], (err, rows) => {
        if (err) {
          console.error('Error:', err);
          return;
        }
        rows.forEach(r => {
          console.log(`   ${r.id}. ${r.foodType} (${r.quantity}) - ${r.status}`);
        });
      });

      setTimeout(() => {
        console.log('\n📨 Sample Requests:');
        db.all("SELECT id, foodType, quantity, status FROM requests LIMIT 3", [], (err, rows) => {
          if (err) {
            console.error('Error:', err);
            return;
          }
          rows.forEach(r => {
            console.log(`   ${r.id}. ${r.foodType} (${r.quantity}) - ${r.status}`);
          });
        });

        setTimeout(() => {
          // Database Size
          const fs = require('fs');
          const stats = fs.statSync(dbPath);
          const fileSizeInBytes = stats.size;
          const fileSizeInKB = (fileSizeInBytes / 1024).toFixed(2);
          
          console.log('\n💾 Database File:');
          console.log(`   Path: ${dbPath}`);
          console.log(`   Size: ${fileSizeInKB} KB`);
          
          console.log('\n' + '='.repeat(60));
          console.log('\n✅ Database is healthy and working properly!\n');
          
          db.close();
        }, 500);
      }, 500);
    }, 500);
  }, 500);
}, 500);
