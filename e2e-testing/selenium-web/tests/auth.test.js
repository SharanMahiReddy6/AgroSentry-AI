const { By, until } = require('selenium-webdriver');

async function testAuth(driver, url) {
    const results = [];

    // Clear all auth state so protected pages don't redirect to dashboard
    const clearAuth = async () => {
        try {
            await driver.executeScript('localStorage.clear(); sessionStorage.clear();');
        } catch(e) {}
    };

    // Scenario 1: Load Login Page
    let startTime = Date.now();
    try {
        await clearAuth();
        await driver.get(`${url}/login`);
        await driver.wait(until.elementLocated(By.css('input[type="email"]')), 8000);
        results.push({ name: 'Load Login Page', status: 'Pass', duration: Date.now() - startTime, error: '' });
    } catch (err) {
        results.push({ name: 'Load Login Page', status: 'Fail', duration: Date.now() - startTime, error: err.message });
    }

    // Scenario 2: Load Register Page
    startTime = Date.now();
    try {
        await clearAuth();
        await driver.get(`${url}/register`);
        // Register page has email input
        await driver.wait(until.elementLocated(By.css('input[type="email"]')), 8000);
        results.push({ name: 'Load Register Page', status: 'Pass', duration: Date.now() - startTime, error: '' });
    } catch (err) {
        results.push({ name: 'Load Register Page', status: 'Fail', duration: Date.now() - startTime, error: err.message });
    }

    return results;
}

module.exports = { testAuth };
