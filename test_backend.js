const http = require('http');

const BASE_URL = 'http://localhost:3000';
let authToken = '';
let userId = '';
let donationId = '';
let requestId = '';

// Color codes for console output
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

function makeRequest(method, path, data = null, token = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, BASE_URL);
    const options = {
      method,
      headers: {
        'Content-Type': 'application/json',
      },
    };

    if (token) {
      options.headers['Authorization'] = `Bearer ${token}`;
    }

    const req = http.request(url, options, (res) => {
      let body = '';
      res.on('data', (chunk) => (body += chunk));
      res.on('end', () => {
        try {
          const response = body ? JSON.parse(body) : {};
          resolve({ status: res.statusCode, data: response });
        } catch (e) {
          resolve({ status: res.statusCode, data: body });
        }
      });
    });

    req.on('error', reject);

    if (data) {
      req.write(JSON.stringify(data));
    }

    req.end();
  });
}

async function runTests() {
  log('\n🧪 FoodLink Backend & Database Test Suite\n', 'cyan');
  log('='.repeat(60), 'blue');

  let passed = 0;
  let failed = 0;

  // Test 1: Server Health Check
  try {
    log('\n📡 Test 1: Server Health Check', 'yellow');
    const res = await makeRequest('GET', '/');
    if (res.status === 200) {
      log('✅ Server is running', 'green');
      passed++;
    } else {
      log('❌ Server not responding correctly', 'red');
      failed++;
    }
  } catch (error) {
    log(`❌ Server connection failed: ${error.message}`, 'red');
    failed++;
    return;
  }

  // Test 2: User Registration (Donor)
  const timestamp = Date.now();
  try {
    log('\n👤 Test 2: User Registration (Donor)', 'yellow');
    const res = await makeRequest('POST', '/api/register', {
      email: `donor${timestamp}@test.com`,
      password: 'password123',
      name: 'Test Donor',
      role: 'Donor',
      address: 'Thrissur, Kerala',
      phone: '9876543210',
      latitude: 10.5276,
      longitude: 76.2144,
    });

    if (res.status === 201 && res.data.token) {
      authToken = res.data.token;
      userId = res.data.user.id;
      log(`✅ Donor registered successfully (ID: ${userId})`, 'green');
      log(`   Token: ${authToken.substring(0, 20)}...`, 'cyan');
      passed++;
    } else {
      log(`❌ Registration failed: ${JSON.stringify(res.data)}`, 'red');
      failed++;
    }
  } catch (error) {
    log(`❌ Registration error: ${error.message}`, 'red');
    failed++;
  }

  // Test 3: User Login
  try {
    log('\n🔐 Test 3: User Login', 'yellow');
    const res = await makeRequest('POST', '/api/login', {
      email: `donor${timestamp}@test.com`,
      password: 'password123',
      role: 'Donor',
    });

    if (res.status === 200 && res.data.token) {
      log('✅ Login successful', 'green');
      passed++;
    } else {
      log(`❌ Login failed: ${JSON.stringify(res.data)}`, 'red');
      failed++;
    }
  } catch (error) {
    log(`❌ Login error: ${error.message}`, 'red');
    failed++;
  }

  // Test 4: Get User Profile
  try {
    log('\n👨 Test 4: Get User Profile', 'yellow');
    const res = await makeRequest('GET', `/api/profile/${userId}`, null, authToken);

    if (res.status === 200 && res.data.id === userId) {
      log(`✅ Profile retrieved: ${res.data.name} (${res.data.role})`, 'green');
      passed++;
    } else {
      log(`❌ Profile retrieval failed: ${JSON.stringify(res.data)}`, 'red');
      failed++;
    }
  } catch (error) {
    log(`❌ Profile error: ${error.message}`, 'red');
    failed++;
  }

  // Test 5: Create Donation
  try {
    log('\n🍕 Test 5: Create Donation', 'yellow');
    const res = await makeRequest('POST', '/api/donations', {
      foodType: 'Rice and Curry',
      quantity: '10 kg',
      pickupAddress: 'Thrissur Railway Station',
      latitude: 10.5276,
      longitude: 76.2144,
      expiryTime: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
    }, authToken);

    if (res.status === 201 && res.data.id) {
      donationId = res.data.id;
      log(`✅ Donation created (ID: ${donationId})`, 'green');
      log(`   Food: ${res.data.foodType}, Qty: ${res.data.quantity}`, 'cyan');
      passed++;
    } else {
      log(`❌ Donation creation failed: ${JSON.stringify(res.data)}`, 'red');
      failed++;
    }
  } catch (error) {
    log(`❌ Donation error: ${error.message}`, 'red');
    failed++;
  }

  // Test 6: Get All Donations
  try {
    log('\n📋 Test 6: Get All Donations', 'yellow');
    const res = await makeRequest('GET', '/api/donations', null, authToken);

    if (res.status === 200 && Array.isArray(res.data)) {
      log(`✅ Retrieved ${res.data.length} donation(s)`, 'green');
      passed++;
    } else {
      log(`❌ Failed to get donations: ${JSON.stringify(res.data)}`, 'red');
      failed++;
    }
  } catch (error) {
    log(`❌ Get donations error: ${error.message}`, 'red');
    failed++;
  }

  // Test 7: Get User Donations
  try {
    log('\n📦 Test 7: Get User Donations', 'yellow');
    const res = await makeRequest('GET', `/api/donations/${userId}`, null, authToken);

    if (res.status === 200 && Array.isArray(res.data)) {
      log(`✅ User has ${res.data.length} donation(s)`, 'green');
      passed++;
    } else {
      log(`❌ Failed to get user donations: ${JSON.stringify(res.data)}`, 'red');
      failed++;
    }
  } catch (error) {
    log(`❌ Get user donations error: ${error.message}`, 'red');
    failed++;
  }

  // Test 8: Register NGO
  let ngoToken = '';
  let ngoId = '';
  try {
    log('\n🏢 Test 8: Register NGO', 'yellow');
    const res = await makeRequest('POST', '/api/register', {
      email: `ngo${timestamp}@test.com`,
      password: 'password123',
      name: 'Test NGO',
      role: 'NGO',
      address: 'Thrissur, Kerala',
      phone: '9876543211',
      description: 'Food distribution NGO',
    });

    if (res.status === 201 && res.data.token) {
      ngoToken = res.data.token;
      ngoId = res.data.user.id;
      log(`✅ NGO registered (ID: ${ngoId})`, 'green');
      passed++;
    } else {
      log(`❌ NGO registration failed: ${JSON.stringify(res.data)}`, 'red');
      failed++;
    }
  } catch (error) {
    log(`❌ NGO registration error: ${error.message}`, 'red');
    failed++;
  }

  // Test 9: NGO Update Donation Status
  try {
    log('\n✏️ Test 9: NGO Update Donation Status', 'yellow');
    const res = await makeRequest('PUT', `/api/donations/${donationId}/status`, {
      status: 'Verified',
    }, ngoToken);

    if (res.status === 200 && res.data.status === 'Verified') {
      log('✅ Donation status updated to Verified', 'green');
      passed++;
    } else {
      log(`❌ Status update failed: ${JSON.stringify(res.data)}`, 'red');
      failed++;
    }
  } catch (error) {
    log(`❌ Status update error: ${error.message}`, 'red');
    failed++;
  }

  // Test 10: Register Receiver
  let receiverToken = '';
  let receiverId = '';
  try {
    log('\n🙋 Test 10: Register Receiver', 'yellow');
    const res = await makeRequest('POST', '/api/register', {
      email: `receiver${timestamp}@test.com`,
      password: 'password123',
      name: 'Test Receiver',
      role: 'Receiver',
      address: 'Thrissur, Kerala',
      phone: '9876543212',
      familySize: 4,
    });

    if (res.status === 201 && res.data.token) {
      receiverToken = res.data.token;
      receiverId = res.data.user.id;
      log(`✅ Receiver registered (ID: ${receiverId})`, 'green');
      passed++;
    } else {
      log(`❌ Receiver registration failed: ${JSON.stringify(res.data)}`, 'red');
      failed++;
    }
  } catch (error) {
    log(`❌ Receiver registration error: ${error.message}`, 'red');
    failed++;
  }

  // Test 11: Create Request
  try {
    log('\n📝 Test 11: Create Food Request', 'yellow');
    const res = await makeRequest('POST', '/api/requests', {
      foodType: 'Rice',
      quantity: '5 kg',
      address: 'Thrissur Town',
      latitude: 10.5276,
      longitude: 76.2144,
      notes: 'Urgent need for family',
    }, receiverToken);

    if (res.status === 201 && res.data.id) {
      requestId = res.data.id;
      log(`✅ Request created (ID: ${requestId})`, 'green');
      passed++;
    } else {
      log(`❌ Request creation failed: ${JSON.stringify(res.data)}`, 'red');
      failed++;
    }
  } catch (error) {
    log(`❌ Request error: ${error.message}`, 'red');
    failed++;
  }

  // Test 12: Get User Requests
  try {
    log('\n📨 Test 12: Get User Requests', 'yellow');
    const res = await makeRequest('GET', `/api/requests/${receiverId}`, null, receiverToken);

    if (res.status === 200 && Array.isArray(res.data)) {
      log(`✅ User has ${res.data.length} request(s)`, 'green');
      passed++;
    } else {
      log(`❌ Failed to get requests: ${JSON.stringify(res.data)}`, 'red');
      failed++;
    }
  } catch (error) {
    log(`❌ Get requests error: ${error.message}`, 'red');
    failed++;
  }

  // Test 13: NGO Update Request Status
  try {
    log('\n✅ Test 13: NGO Update Request Status', 'yellow');
    const res = await makeRequest('PUT', `/api/requests/${requestId}/status`, {
      status: 'Approved',
    }, ngoToken);

    if (res.status === 200 && res.data.status === 'Approved') {
      log('✅ Request status updated to Approved', 'green');
      passed++;
    } else {
      log(`❌ Request status update failed: ${JSON.stringify(res.data)}`, 'red');
      failed++;
    }
  } catch (error) {
    log(`❌ Request status update error: ${error.message}`, 'red');
    failed++;
  }

  // Test 14: Invalid Login
  try {
    log('\n🚫 Test 14: Invalid Login (Security)', 'yellow');
    const res = await makeRequest('POST', '/api/login', {
      email: 'invalid@test.com',
      password: 'wrongpassword',
      role: 'Donor',
    });

    if (res.status === 401) {
      log('✅ Invalid login properly rejected', 'green');
      passed++;
    } else {
      log('❌ Security issue: Invalid login not rejected', 'red');
      failed++;
    }
  } catch (error) {
    log(`❌ Invalid login test error: ${error.message}`, 'red');
    failed++;
  }

  // Test 15: Unauthorized Access
  try {
    log('\n🔒 Test 15: Unauthorized Access (Security)', 'yellow');
    const res = await makeRequest('GET', `/api/profile/${userId}`, null, 'invalid-token');

    if (res.status === 403) {
      log('✅ Unauthorized access properly blocked', 'green');
      passed++;
    } else {
      log('❌ Security issue: Unauthorized access not blocked', 'red');
      failed++;
    }
  } catch (error) {
    log(`❌ Unauthorized access test error: ${error.message}`, 'red');
    failed++;
  }

  // Summary
  log('\n' + '='.repeat(60), 'blue');
  log('\n📊 Test Results Summary\n', 'cyan');
  log(`✅ Passed: ${passed}`, 'green');
  log(`❌ Failed: ${failed}`, 'red');
  log(`📈 Success Rate: ${((passed / (passed + failed)) * 100).toFixed(1)}%\n`, 'yellow');

  if (failed === 0) {
    log('🎉 All tests passed! Backend and database are working perfectly!', 'green');
  } else {
    log('⚠️  Some tests failed. Please check the errors above.', 'red');
  }

  log('\n' + '='.repeat(60), 'blue');
}

// Run tests
runTests().catch((error) => {
  log(`\n❌ Test suite failed: ${error.message}`, 'red');
  process.exit(1);
});
