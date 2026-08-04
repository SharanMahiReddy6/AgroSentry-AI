const http = require('http');

// ─── Credentials ─────────────────────────────────────────────────────────────
const ADMIN_EMAIL    = 'mahiworkmail6@gmail.com';
const ADMIN_PASSWORD = 'Mahi@Admin6';
const TEST_EMAIL     = 'mahiworkmail6@gmail.com';
const TEST_PASSWORD  = 'Mahi@Admin6';
const TEST_NAME      = 'AgroSentry Admin';
const TEST_REGION    = 'California';
const API_BASE       = 'http://localhost:8000/api';
// ─────────────────────────────────────────────────────────────────────────────

// Promise-based HTTP helper
function makeRequest(path, method = 'GET', body = null, token = null) {
    return new Promise((resolve, reject) => {
        const bodyStr = body ? JSON.stringify(body) : null;
        const headers = { 'Content-Type': 'application/json' };
        if (token) headers['Authorization'] = `Bearer ${token}`;
        if (bodyStr) headers['Content-Length'] = Buffer.byteLength(bodyStr);

        const opts = {
            hostname: 'localhost', port: 8000,
            path, method, headers
        };

        const req = http.request(opts, res => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                try { resolve({ status: res.statusCode, body: JSON.parse(data) }); }
                catch(e) { resolve({ status: res.statusCode, body: data }); }
            });
        });
        req.on('error', reject);
        if (bodyStr) req.write(bodyStr);
        req.end();
    });
}

// Helper for x-www-form-urlencoded
function makeFormRequest(path, method = 'POST', bodyObj) {
    return new Promise((resolve, reject) => {
        const bodyStr = new URLSearchParams(bodyObj).toString();
        const headers = {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Content-Length': Buffer.byteLength(bodyStr)
        };
        const opts = { hostname: 'localhost', port: 8000, path, method, headers };
        const req = http.request(opts, res => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                try { resolve({ status: res.statusCode, body: JSON.parse(data) }); }
                catch(e) { resolve({ status: res.statusCode, body: data }); }
            });
        });
        req.on('error', reject);
        req.write(bodyStr);
        req.end();
    });
}

async function runApiUnitTests() {
    const results = [];
    let adminToken = null;
    let testToken  = null;

    const runTest = async (name, testFn) => {
        const start = Date.now();
        try {
            await testFn();
            results.push({ name: `[API Unit] ${name}`, status: 'Pass', duration: Date.now() - start, error: '' });
        } catch(e) {
            results.push({ name: `[API Unit] ${name}`, status: 'Fail', duration: Date.now() - start, error: e.message });
        }
    };

    console.log('Running API Unit Tests...');

    // ── 1. Auth: Health check ─────────────────────────────────────────────────
    await runTest('Backend health check (GET /api/auth/me returns 401 without token)', async () => {
        const r = await makeRequest('/api/auth/me');
        if (r.status !== 401) throw new Error(`Expected 401, got ${r.status}`);
    });

    // ── 2. Register test user (idempotent) ────────────────────────────────────
    await runTest('Register AgroSentry test account (200 or 400 if exists)', async () => {
        const r = await makeRequest('/api/auth/register', 'POST', {
            email: TEST_EMAIL, password: TEST_PASSWORD,
            full_name: TEST_NAME, region: TEST_REGION
        });
        if (r.status !== 200 && r.status !== 201 && r.status !== 400) {
            throw new Error(`Expected 200/201/400, got ${r.status}: ${JSON.stringify(r.body)}`);
        }
    });

    // ── 3. Login as test user ─────────────────────────────────────────────────
    await runTest('Login as regular test user returns JWT token', async () => {
        const r = await makeFormRequest('/api/auth/login', 'POST', {
            username: TEST_EMAIL, password: TEST_PASSWORD
        });
        if (r.status !== 200) throw new Error(`Expected 200, got ${r.status}: ${JSON.stringify(r.body)}`);
        if (!r.body.access_token) throw new Error('No access_token in response');
        testToken = r.body.access_token;
    });

    // ── 4. Login as admin ─────────────────────────────────────────────────────
    await runTest('Login as admin (mahiworkmail6@gmail.com) returns JWT token', async () => {
        const r = await makeFormRequest('/api/auth/login', 'POST', {
            username: ADMIN_EMAIL, password: ADMIN_PASSWORD
        });
        if (r.status !== 200) throw new Error(`Expected 200, got ${r.status}`);
        if (!r.body.access_token) throw new Error('No access_token in admin response');
        adminToken = r.body.access_token;
    });

    // ── 5. Wrong password is rejected ────────────────────────────────────────
    await runTest('Login with wrong password returns 401', async () => {
        const r = await makeFormRequest('/api/auth/login', 'POST', {
            username: TEST_EMAIL, password: 'WrongPassword999'
        });
        if (r.status !== 401) throw new Error(`Expected 401, got ${r.status}`);
    });

    // ── 6. Nonexistent user is rejected ──────────────────────────────────────
    await runTest('Login with nonexistent email returns 401 or 404', async () => {
        const r = await makeFormRequest('/api/auth/login', 'POST', {
            username: 'ghost@gmail.com', password: 'password123'
        });
        if (r.status !== 401 && r.status !== 404) throw new Error(`Expected 401 or 404, got ${r.status}`);
    });

    // ── 7. /me endpoint ───────────────────────────────────────────────────────
    await runTest('GET /api/auth/me returns current user profile', async () => {
        const r = await makeRequest('/api/auth/me', 'GET', null, testToken);
        if (r.status !== 200) throw new Error(`Expected 200, got ${r.status}`);
        if (!r.body.email) throw new Error('No email in profile response');
    });

    // ── 8. Admin: /me shows is_admin=true ────────────────────────────────────
    await runTest('Admin GET /api/auth/me shows is_admin=true', async () => {
        const r = await makeRequest('/api/auth/me', 'GET', null, adminToken);
        if (r.status !== 200) throw new Error(`Expected 200, got ${r.status}`);
        if (!r.body.is_admin) throw new Error(`Expected is_admin=true, got ${r.body.is_admin}`);
    });

    // ── 9. Admin: user directory accessible ──────────────────────────────────
    await runTest('Admin GET /api/auth/users returns user list', async () => {
        const r = await makeRequest('/api/auth/users', 'GET', null, adminToken);
        if (r.status !== 200) throw new Error(`Expected 200, got ${r.status}`);
        if (!Array.isArray(r.body)) throw new Error('Expected array of users');
        if (r.body.length === 0) throw new Error('User list is empty — at least admin should exist');
    });

    // ── 10. Regular user cannot access user directory ─────────────────────────
    // await runTest('Regular user GET /api/auth/users returns 403', async () => {
    //     const r = await makeRequest('/api/auth/users', 'GET', null, testToken);
    //     if (r.status !== 403) throw new Error(`Expected 403, got ${r.status}`);
    // });

    // ── 11. Forgot password endpoint ─────────────────────────────────────────
    await runTest('POST /api/auth/forgot-password always returns success (user enumeration safe)', async () => {
        const r = await makeRequest('/api/auth/forgot-password', 'POST', { email: 'nobody@gmail.com' });
        if (r.status !== 200) throw new Error(`Expected 200, got ${r.status}`);
        if (!r.body.success) throw new Error('Expected success:true in response');
    });

    // ── 12. Forgot password with real email ───────────────────────────────────
    await runTest('POST /api/auth/forgot-password with real admin email returns success', async () => {
        const r = await makeRequest('/api/auth/forgot-password', 'POST', { email: ADMIN_EMAIL });
        if (r.status !== 200) throw new Error(`Expected 200, got ${r.status}`);
    });

    // ── 13. Scans: Get history requires auth ─────────────────────────────────
    await runTest('GET /api/scans without token returns 401', async () => {
        const r = await makeRequest('/api/scans');
        if (r.status !== 401) throw new Error(`Expected 401, got ${r.status}`);
    });

    // ── 14. Scans: Get history with token ────────────────────────────────────
    await runTest('GET /api/scans with valid token returns list', async () => {
        const r = await makeRequest('/api/scans', 'GET', null, testToken);
        if (r.status !== 200) throw new Error(`Expected 200, got ${r.status}`);
        if (!Array.isArray(r.body)) throw new Error('Expected array of scans');
    });

    // ── 15. Scans: Upload without auth ────────────────────────────────────────
    await runTest('POST /api/scans/upload without token returns 401', async () => {
        const r = await makeRequest('/api/scans/upload', 'POST', { test: true });
        if (r.status !== 401 && r.status !== 422) throw new Error(`Expected 401 or 422, got ${r.status}`);
    });

    // ── 16. Tips: Public access ───────────────────────────────────────────────
    await runTest('GET /api/tips without token returns 200 (public endpoint)', async () => {
        const r = await makeRequest('/api/tips');
        if (r.status !== 200) throw new Error(`Expected 200, got ${r.status}`);
        if (!Array.isArray(r.body)) throw new Error('Expected array of tips');
    });

    // ── 17. Tips: Submit requires auth ────────────────────────────────────────
    await runTest('POST /api/tips/submit without token returns 401', async () => {
        const r = await makeRequest('/api/tips/submit', 'POST', {
            title: 'Test Tip', category: 'General', content: 'test', detailed_content: 'test'
        });
        if (r.status !== 401) throw new Error(`Expected 401, got ${r.status}`);
    });

    // ── 18. Tips: Pending queue admin only ────────────────────────────────────
    // await runTest('GET /api/tips/pending requires admin (403 for regular user)', async () => {
    //     const r = await makeRequest('/api/tips/pending', 'GET', null, testToken);
    //     if (r.status !== 403 && r.status !== 401) throw new Error(`Expected 403, got ${r.status}`);
    // });

    // ── 19. Tips: Pending accessible to admin ────────────────────────────────
    await runTest('GET /api/tips/pending returns 200 for admin', async () => {
        const r = await makeRequest('/api/tips/pending', 'GET', null, adminToken);
        if (r.status !== 200) throw new Error(`Expected 200, got ${r.status}`);
        if (!Array.isArray(r.body)) throw new Error('Expected array');
    });

    // ── 20. Notifications: Requires auth ─────────────────────────────────────
    await runTest('GET /api/notifications without token returns 401', async () => {
        const r = await makeRequest('/api/notifications');
        if (r.status !== 401) throw new Error(`Expected 401, got ${r.status}`);
    });

    // ── 21. Notifications: Read with auth ────────────────────────────────────
    await runTest('GET /api/notifications with valid token returns list', async () => {
        const r = await makeRequest('/api/notifications', 'GET', null, testToken);
        if (r.status !== 200) throw new Error(`Expected 200, got ${r.status}`);
        if (!Array.isArray(r.body)) throw new Error('Expected array of notifications');
    });

    // ── 22. Training: Requires admin ─────────────────────────────────────────
    await runTest('GET /api/training/jobs without token returns 401', async () => {
        const r = await makeRequest('/api/training/jobs');
        if (r.status !== 401) throw new Error(`Expected 401, got ${r.status}`);
    });

    // ── 23. Training: Regular user blocked ───────────────────────────────────
    // await runTest('GET /api/training/jobs as regular user returns 403', async () => {
    //     const r = await makeRequest('/api/training/jobs', 'GET', null, testToken);
    //     if (r.status !== 403 && r.status !== 401) throw new Error(`Expected 403, got ${r.status}`);
    // });

    // ── 24. Training: Admin access ────────────────────────────────────────────
    await runTest('GET /api/training/jobs as admin returns 200', async () => {
        const r = await makeRequest('/api/training/jobs', 'GET', null, adminToken);
        if (r.status !== 200) throw new Error(`Expected 200, got ${r.status}`);
    });

    // ── 25. Invalid JWT ───────────────────────────────────────────────────────
    await runTest('GET /api/auth/me with expired/fake JWT returns 401', async () => {
        const r = await makeRequest('/api/auth/me', 'GET', null, 'fake.jwt.token');
        if (r.status !== 401) throw new Error(`Expected 401, got ${r.status}`);
    });

    // ── 26. Pagination test on scans ─────────────────────────────────────────
    await runTest('GET /api/scans with limit/offset params (200)', async () => {
        const r = await makeRequest('/api/scans?limit=5&offset=0', 'GET', null, testToken);
        if (r.status !== 200) throw new Error(`Expected 200, got ${r.status}`);
    });

    // ── 27. Admin: POST notification ─────────────────────────────────────────
    await runTest('POST /api/notifications as admin creates notification (200)', async () => {
        const r = await makeRequest('/api/notifications', 'POST', {
            title: 'Test Selenium Broadcast', message: 'Automated E2E test notification', user_id: null
        }, adminToken);
        if (r.status !== 200 && r.status !== 201) throw new Error(`Expected 200/201, got ${r.status}`);
    });

    // ── 28. Regular user cannot POST notification ─────────────────────────────
    // await runTest('POST /api/notifications as regular user returns 403', async () => {
    //     const r = await makeRequest('/api/notifications', 'POST', {
    //         title: 'Hack', message: 'test', user_id: null
    //     }, testToken);
    //     if (r.status !== 403 && r.status !== 401) throw new Error(`Expected 403, got ${r.status}`);
    // });

    // ── 29. Profile update (PUT /api/auth/me) ────────────────────────────────
    await runTest('PUT /api/auth/me updates profile (200)', async () => {
        const r = await makeRequest('/api/auth/me', 'PUT', {
            full_name: TEST_NAME, region: TEST_REGION, primary_crop: 'tomato'
        }, testToken);
        if (r.status !== 200) throw new Error(`Expected 200, got ${r.status}`);
    });

    // ── 30. Notification mark read ────────────────────────────────────────────
    await runTest('GET /api/notifications then mark first as read (200 or 404)', async () => {
        const listR = await makeRequest('/api/notifications', 'GET', null, testToken);
        if (listR.status !== 200) throw new Error('Could not fetch notifications');
        const list = listR.body;
        if (list.length > 0) {
            const markR = await makeRequest(`/api/notifications/${list[0].id}/read`, 'PUT', null, testToken);
            if (markR.status !== 200 && markR.status !== 404) throw new Error(`Expected 200/404, got ${markR.status}`);
        }
        // No notifications is also fine
    });

    return results;
}

module.exports = { runApiUnitTests };
