const http = require('http');

function post(path, data, token) {
  return new Promise((resolve, reject) => {
    const payload = JSON.stringify(data);
    const options = {
      hostname: '127.0.0.1',
      port: 5000,
      path: '/api/v1' + path,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(payload)
      }
    };
    if (token) {
      options.headers['Authorization'] = 'Bearer ' + token;
    }

    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, data: JSON.parse(body) });
        } catch (_) {
          resolve({ status: res.statusCode, raw: body });
        }
      });
    });
    req.on('error', reject);
    req.write(payload);
    req.end();
  });
}

function patch(path, data, token) {
  return new Promise((resolve, reject) => {
    const payload = JSON.stringify(data);
    const options = {
      hostname: '127.0.0.1',
      port: 5000,
      path: '/api/v1' + path,
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(payload)
      }
    };
    if (token) {
      options.headers['Authorization'] = 'Bearer ' + token;
    }

    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, data: JSON.parse(body) });
        } catch (_) {
          resolve({ status: res.statusCode, raw: body });
        }
      });
    });
    req.on('error', reject);
    req.write(payload);
    req.end();
  });
}

async function run() {
  try {
    // 1. Log in
    console.log('Logging in...');
    const loginRes = await post('/auth/admin/login', {
      email: 'owner@voltspare.com',
      password: 'OwnerPassword123!'
    });
    console.log('Login Status:', loginRes.status);
    if (loginRes.status !== 200) {
      console.log('Login failed:', loginRes.data);
      return;
    }
    const token = loginRes.data.data.accessToken;
    console.log('Token obtained.');

    // 2. Test general patch
    console.log('Patching general settings...');
    const genRes = await patch('/settings/general', {
      appName: 'VoltSpare Headquarters',
      supportEmail: 'billing@voltspare.com',
      supportPhone: '+91 99000 88000'
    }, token);
    console.log('General PATCH Status:', genRes.status, genRes.data || genRes.raw);

    // 3. Test billing patch
    console.log('Patching billing settings...');
    const billRes = await patch('/settings/billing', {
      invoicePrefix: 'VS-POS-',
      taxPercentage: 18
    }, token);
    console.log('Billing PATCH Status:', billRes.status, billRes.data || billRes.raw);

    // 4. Test pos patch
    console.log('Patching pos settings...');
    const posRes = await patch('/settings/pos', {
      allowSplitPayment: true
    }, token);
    console.log('POS PATCH Status:', posRes.status, posRes.data || posRes.raw);

    // 5. Test inventory patch
    console.log('Patching inventory settings...');
    const invRes = await patch('/settings/inventory', {
      lowStockThreshold: 5
    }, token);
    console.log('Inventory PATCH Status:', invRes.status, invRes.data || invRes.raw);

  } catch (err) {
    console.error('Run Error:', err);
  }
}

run();
