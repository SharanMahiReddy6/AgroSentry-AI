const { Builder } = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');
const ExcelJS = require('exceljs');
const fs = require('fs');
const path = require('path');

const { testAuth } = require('./tests/auth.test');
const { testNavigation } = require('./tests/navigation.test');
const { testUI } = require('./tests/ui.test');
const { testValidation } = require('./tests/validation.test');
const { testFunctional } = require('./tests/functional.test');
const { runApiUnitTests } = require('./tests/api-unit.test');
const { testExhaustive } = require('./tests/exhaustive.test');

const TARGET_URL = 'http://localhost:3000'; 

async function generateExcelReport(results) {
    const workbook = new ExcelJS.Workbook();
    
    // Sheet 1: Deployable Status Dashboard
    const summarySheet = workbook.addWorksheet('Deployable Status Summary');
    
    const totalTests = results.length;
    const passedTests = results.filter(r => r.status === 'Pass').length;
    const failedTests = totalTests - passedTests;
    const passPercentage = totalTests > 0 ? ((passedTests / totalTests) * 100).toFixed(1) : 0;
    
    summarySheet.columns = [
        { header: 'Metric', key: 'metric', width: 30 },
        { header: 'Value', key: 'value', width: 20 },
    ];
    
    summarySheet.addRow({ metric: 'Total Test Cases Executed', value: totalTests });
    summarySheet.addRow({ metric: 'Passed', value: passedTests }).font = { color: { argb: 'FF008000' } };
    summarySheet.addRow({ metric: 'Failed', value: failedTests }).font = { color: { argb: 'FFFF0000' } };
    summarySheet.addRow({ metric: 'Pass Rate', value: `${passPercentage}%` });
    summarySheet.addRow({ metric: 'Deployable Status', value: failedTests === 0 ? 'GO (Ready to Deploy)' : 'NO-GO (Fix Issues)' });
    
    // Style the summary
    summarySheet.getRow(1).font = { bold: true, size: 14 };
    summarySheet.getRow(6).font = { bold: true, size: 16, color: { argb: failedTests === 0 ? 'FF008000' : 'FFFF0000' } };

    // Sheet 2: Detailed Log
    const sheet = workbook.addWorksheet('Detailed Execution Log');
    sheet.columns = [
        { header: 'Test Name', key: 'name', width: 50 },
        { header: 'Status', key: 'status', width: 15 },
        { header: 'Duration (ms)', key: 'duration', width: 15 },
        { header: 'Error Details', key: 'error', width: 50 },
    ];

    sheet.getRow(1).font = { bold: true };

    results.forEach(res => {
        const row = sheet.addRow(res);
        if (res.status === 'Pass') {
            row.getCell('status').font = { color: { argb: 'FF008000' } }; 
        } else {
            row.getCell('status').font = { color: { argb: 'FFFF0000' } }; 
        }
    });

    const reportPath = path.join(__dirname, 'e2e-test-report.xlsx');
    await workbook.xlsx.writeFile(reportPath);
    console.log(`\n==============================================`);
    console.log(`✅ Excel report generated successfully at:`);
    console.log(`📂 ${reportPath}`);
    console.log(`==============================================\n`);
}

async function runTests() {
    let options = new chrome.Options();
    // options.addArguments('--headless=new'); // Commented out to show live testing in browser

    let driver = await new Builder()
        .forBrowser('chrome')
        .setChromeOptions(options)
        .build();

    let allResults = [];

    try {
        console.log('\n🚀 Starting AgroSentry Master Test Suite (100+ Cases)\n');
        
        // 1. API Unit Tests
        const apiResults = await runApiUnitTests();
        allResults = allResults.concat(apiResults);
        
        // 2. UI / UX Tests
        const uiResults = await testUI(driver, TARGET_URL);
        allResults = allResults.concat(uiResults);

        // 3. Validation Tests
        const valResults = await testValidation(driver, TARGET_URL);
        allResults = allResults.concat(valResults);

        // 4. Functional Tests
        const funcResults = await testFunctional(driver, TARGET_URL);
        allResults = allResults.concat(funcResults);

        // 5. Exhaustive Crawler (Visits every page, link, and button)
        const exhaustiveResults = await testExhaustive(driver, TARGET_URL);
        allResults = allResults.concat(exhaustiveResults);

        // 6. Original Legacy Tests
        const navResults = await testNavigation(driver, TARGET_URL);
        allResults = allResults.concat(navResults);
        
        const authResults = await testAuth(driver, TARGET_URL);
        allResults = allResults.concat(authResults);

        console.log(`\n🎉 All ${allResults.length} test cases completed.`);
    } catch (e) {
        console.error('An unexpected error occurred during testing:', e);
    } finally {
        await driver.quit();
        await generateExcelReport(allResults);
    }
}

runTests();
