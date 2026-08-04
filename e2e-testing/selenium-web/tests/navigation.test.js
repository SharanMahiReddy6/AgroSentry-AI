const { By, until } = require('selenium-webdriver');

async function testNavigation(driver, url) {
    const results = [];
    
    // Scenario 1: Load Home Page
    let startTime = Date.now();
    try {
        await driver.get(`${url}/`);
        // Assuming there is a nav element or body is present
        await driver.wait(until.elementLocated(By.css('body')), 5000);
        results.push({
            name: 'Load Home Page',
            status: 'Pass',
            duration: Date.now() - startTime,
            error: ''
        });
    } catch (err) {
        results.push({
            name: 'Load Home Page',
            status: 'Fail',
            duration: Date.now() - startTime,
            error: err.message
        });
    }

    // Scenario 2: Load Library Page
    startTime = Date.now();
    try {
        await driver.get(`${url}/library`);
        // Wait for something on library page
        await driver.wait(until.elementLocated(By.css('body')), 5000);
        results.push({
            name: 'Load Library Page',
            status: 'Pass',
            duration: Date.now() - startTime,
            error: ''
        });
    } catch (err) {
        results.push({
            name: 'Load Library Page',
            status: 'Fail',
            duration: Date.now() - startTime,
            error: err.message
        });
    }

    // Scenario 3: Load Scan Page
    startTime = Date.now();
    try {
        await driver.get(`${url}/scan`);
        await driver.wait(until.elementLocated(By.css('body')), 5000);
        results.push({
            name: 'Load Scan Page',
            status: 'Pass',
            duration: Date.now() - startTime,
            error: ''
        });
    } catch (err) {
        results.push({
            name: 'Load Scan Page',
            status: 'Fail',
            duration: Date.now() - startTime,
            error: err.message
        });
    }

    return results;
}

module.exports = { testNavigation };
