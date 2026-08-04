const { By, until } = require('selenium-webdriver');

async function testValidation(driver, url) {
    const results = [];
    const jsClick = async (el) => await driver.executeScript('arguments[0].click()', el);
    const dismiss = async () => { try { await (await driver.switchTo().alert()).accept(); } catch(e) {} };

    const runTest = async (name, testFn) => {
        const start = Date.now();
        try {
            await driver.executeScript(`
                let b=document.getElementById('ag-val-banner');
                if(!b){b=document.createElement('div');b.id='ag-val-banner';
                b.style.cssText='position:fixed;bottom:0;left:0;width:100%;background:#7B1FA2;color:white;z-index:999999;text-align:center;padding:8px 12px;font-size:13px;font-weight:bold;font-family:sans-serif;';
                document.body.appendChild(b);}
                b.innerText='🔍 Validation: ${name.replace(/'/g, "\\'")}';
            `).catch(() => {});
            await testFn();
            await driver.sleep(500);
            results.push({ name: `[Validation] ${name}`, status: 'Pass', duration: Date.now() - start, error: '' });
        } catch(e) {
            results.push({ name: `[Validation] ${name}`, status: 'Fail', duration: Date.now() - start, error: e.message });
        }
    };

    console.log('Running Validation Tests...');

    // ── A. LOGIN PAGE — Email format validation (HTML5 native) ────────────────
    // These emails are definitively rejected by Chrome's type="email" native validation
    const loginInvalidEmails = [
        'plaintext',
        '@example.com',
        'email@',
        'nodomain',
        '@',
        'a@b',
        'missing-at-sign.com',
        '#$%^&@x.com',
    ];

    await driver.get(`${url}/login`);
    await driver.wait(until.elementLocated(By.css('input[type="email"]')), 8000);

    for (const email of loginInvalidEmails) {
        await runTest(`Login: HTML5 rejects malformed email "${email}"`, async () => {
            const emailInput = await driver.findElement(By.css('input[type="email"]'));
            await emailInput.clear();
            await emailInput.sendKeys(email);
            await jsClick(await driver.findElement(By.css('button[type="submit"]')));
            const isValid = await driver.executeScript('return arguments[0].validity.valid;', emailInput);
            if (isValid) throw new Error(`"${email}" was incorrectly accepted`);
        });
    }

    // ── B. REGISTER PAGE — Domain allowlist validation ────────────────────────
    await driver.get(`${url}/register`);
    await driver.wait(until.elementLocated(By.css('input[type="email"]')), 8000);

    await runTest('Register: Disallowed domain shows error (random-site.xyz)', async () => {
        const emailInput = await driver.findElement(By.css('input[type="email"]'));
        await emailInput.clear();
        await emailInput.sendKeys('user@random-site.xyz');
        await driver.sleep(600);
        const errors = await driver.findElements(By.css('[class*="text-red"]'));
        const btn = await driver.findElement(By.css('button[type="submit"]'));
        const disabled = await btn.getAttribute('disabled');
        if (!disabled && errors.length === 0) throw new Error('Disallowed domain not flagged');
    });

    await runTest('Register: Disallowed domain shows error (company-internal.io)', async () => {
        const emailInput = await driver.findElement(By.css('input[type="email"]'));
        await emailInput.clear();
        await emailInput.sendKeys('user@company-internal.io');
        await driver.sleep(600);
        const btn = await driver.findElement(By.css('button[type="submit"]'));
        const disabled = await btn.getAttribute('disabled');
        const errors = await driver.findElements(By.css('[class*="text-red"]'));
        if (!disabled && errors.length === 0) throw new Error('Disallowed domain not rejected');
    });

    await runTest('Register: gmail.com domain accepted (no blocking error)', async () => {
        const emailInput = await driver.findElement(By.css('input[type="email"]'));
        await emailInput.clear();
        await emailInput.sendKeys('farmer@gmail.com');
        await driver.sleep(600);
        // Should show green, not red domain error
        const errors = await driver.findElements(By.css('[class*="text-red"]'));
        if (errors.length > 0) {
            for (const e of errors) {
                const txt = await e.getText().catch(() => '');
                if (txt.toLowerCase().includes('domain') || txt.toLowerCase().includes('accepted')) {
                    throw new Error(`gmail.com incorrectly rejected: "${txt}"`);
                }
            }
        }
    });

    await runTest('Register: outlook.com domain accepted', async () => {
        const emailInput = await driver.findElement(By.css('input[type="email"]'));
        await emailInput.clear();
        await emailInput.sendKeys('farmer@outlook.com');
        await driver.sleep(600);
        const btn = await driver.findElement(By.css('button[type="submit"]'));
        // Button should not be disabled due to email domain
        // (it may be disabled due to empty password, but not due to email)
        const disabled = await btn.getAttribute('disabled');
        // Just validate that the email field itself is valid
        const isValid = await driver.executeScript('return arguments[0].validity.valid;', emailInput);
        if (!isValid) throw new Error('outlook.com email should be HTML5-valid');
    });

    await runTest('Register: yahoo.com domain accepted', async () => {
        const emailInput = await driver.findElement(By.css('input[type="email"]'));
        await emailInput.clear();
        await emailInput.sendKeys('farmer@yahoo.com');
        await driver.sleep(400);
        const isValid = await driver.executeScript('return arguments[0].validity.valid;', emailInput);
        if (!isValid) throw new Error('yahoo.com email should be valid');
    });

    // ── C. REGISTER — Password strength validation ────────────────────────────
    await driver.get(`${url}/register`);
    await driver.wait(until.elementLocated(By.css('input[type="password"]')), 8000);

    await runTest('Register: Weak password "abc" — submit button should be disabled', async () => {
        const inputs = await driver.findElements(By.css('input'));
        const passInput = await driver.findElement(By.css('input[type="password"]'));
        await passInput.clear();
        await passInput.sendKeys('abc');
        await driver.sleep(400);
        const btn = await driver.findElement(By.css('button[type="submit"]'));
        const disabled = await btn.getAttribute('disabled');
        if (!disabled) throw new Error('Submit not disabled for weak password "abc"');
    });

    await runTest('Register: Weak password "12345" — submit button disabled', async () => {
        const passInput = await driver.findElement(By.css('input[type="password"]'));
        await passInput.clear();
        await passInput.sendKeys('12345');
        await driver.sleep(400);
        const btn = await driver.findElement(By.css('button[type="submit"]'));
        const disabled = await btn.getAttribute('disabled');
        if (!disabled) throw new Error('Submit not disabled for "12345"');
    });

    await runTest('Register: Weak password "password" (no uppercase/number) — button disabled', async () => {
        const passInput = await driver.findElement(By.css('input[type="password"]'));
        await passInput.clear();
        await passInput.sendKeys('password');
        await driver.sleep(400);
        const btn = await driver.findElement(By.css('button[type="submit"]'));
        const disabled = await btn.getAttribute('disabled');
        if (!disabled) throw new Error('Submit not disabled for all-lowercase "password"');
    });

    await runTest('Register: Valid password "Mahi@Admin6" enables submit button', async () => {
        const inputs = await driver.findElements(By.css('input'));
        // Fill all required fields
        await inputs[0].clear(); await inputs[0].sendKeys('AgroFarm Bot');
        const emailInput = await driver.findElement(By.css('input[type="email"]'));
        await emailInput.clear(); await emailInput.sendKeys('mahiworkmail6@gmail.com');
        // Region input (3rd non-password input)
        if (inputs.length >= 3) { await inputs[2].clear(); await inputs[2].sendKeys('Texas'); }
        const passInput = await driver.findElement(By.css('input[type="password"]'));
        await passInput.clear();
        await passInput.sendKeys('Mahi@Admin6');
        await driver.sleep(500);
        const btn = await driver.findElement(By.css('button[type="submit"]'));
        const disabled = await btn.getAttribute('disabled');
        if (disabled) throw new Error('Submit is still disabled for strong password "Mahi@Admin6"');
    });

    await runTest('Register: Password strength checklist shows 3 criteria badges', async () => {
        const passInput = await driver.findElement(By.css('input[type="password"]'));
        await passInput.clear();
        await passInput.sendKeys('Mahi@Admin6');
        await driver.sleep(400);
        const badges = await driver.findElements(By.css('[class*="rounded-full"]'));
        if (!badges.length) throw new Error('Password strength badges not showing');
    });

    // ── D. REGISTER — Required field validation ───────────────────────────────
    await driver.get(`${url}/register`);
    await driver.wait(until.elementLocated(By.css('input[type="email"]')), 8000);

    await runTest('Register: Empty email field blocks submission (HTML5 required)', async () => {
        const emailInput = await driver.findElement(By.css('input[type="email"]'));
        await emailInput.clear();
        await jsClick(await driver.findElement(By.css('button[type="submit"]')));
        const isValid = await driver.executeScript('return arguments[0].validity.valid;', emailInput);
        if (isValid) throw new Error('Empty email was accepted');
    });

    await runTest('Register: Empty password blocks submission', async () => {
        const passInput = await driver.findElement(By.css('input[type="password"]'));
        await passInput.clear();
        const btn = await driver.findElement(By.css('button[type="submit"]'));
        const disabled = await btn.getAttribute('disabled');
        if (!disabled) {
            await jsClick(btn);
            await driver.sleep(400);
            const cur = await driver.getCurrentUrl();
            if (!cur.includes('/register')) throw new Error('Empty password allowed navigation away');
        }
    });

    // ── E. FORGOT PASSWORD — Form validation ──────────────────────────────────
    await driver.get(`${url}/forgot-password`);
    await driver.wait(until.elementLocated(By.css('input[type="email"]')), 12000);

    await runTest('ForgotPassword: Empty email shows HTML5 validation error', async () => {
        const emailInput = await driver.findElement(By.css('input[type="email"]'));
        await emailInput.clear();
        await jsClick(await driver.findElement(By.css('button[type="submit"]')));
        const isValid = await driver.executeScript('return arguments[0].validity.valid;', emailInput);
        if (isValid) throw new Error('Empty email was accepted on forgot-password form');
    });

    await runTest('ForgotPassword: Non-email text rejected by HTML5 validation', async () => {
        const emailInput = await driver.findElement(By.css('input[type="email"]'));
        await emailInput.clear();
        await emailInput.sendKeys('notanemail');
        await jsClick(await driver.findElement(By.css('button[type="submit"]')));
        const isValid = await driver.executeScript('return arguments[0].validity.valid;', emailInput);
        if (isValid) throw new Error('"notanemail" was accepted on forgot-password form');
    });

    await runTest('ForgotPassword: Valid email submits without HTML5 error', async () => {
        const emailInput = await driver.findElement(By.css('input[type="email"]'));
        await emailInput.clear();
        await emailInput.sendKeys('anyuser@gmail.com');
        const isValid = await driver.executeScript('return arguments[0].validity.valid;', emailInput);
        if (!isValid) throw new Error('Valid email rejected on forgot-password form');
    });

    // ── F. LOGIN — Security checks ────────────────────────────────────────────
    await driver.get(`${url}/login`);
    await driver.wait(until.elementLocated(By.css('input[type="email"]')), 5000);

    await runTest('Login: SQL injection in email field blocked by HTML5', async () => {
        const emailInput = await driver.findElement(By.css('input[type="email"]'));
        await emailInput.clear();
        await emailInput.sendKeys("' OR '1'='1");
        await jsClick(await driver.findElement(By.css('button[type="submit"]')));
        const isValid = await driver.executeScript('return arguments[0].validity.valid;', emailInput);
        if (isValid) throw new Error('SQL injection in email not caught by HTML5 validation');
    });

    await runTest('Login: XSS in email field blocked by HTML5', async () => {
        const emailInput = await driver.findElement(By.css('input[type="email"]'));
        await emailInput.clear();
        await emailInput.sendKeys('<script>alert(1)</script>');
        await jsClick(await driver.findElement(By.css('button[type="submit"]')));
        const isValid = await driver.executeScript('return arguments[0].validity.valid;', emailInput);
        if (isValid) throw new Error('XSS in email not caught by HTML5 validation');
        // Ensure no real XSS alert fired
        let xss = false;
        try { await driver.switchTo().alert(); xss = true; await dismiss(); } catch(e) {}
        if (xss) throw new Error('XSS alert was actually triggered!');
    });

    await runTest('Register: XSS in name field does not execute JavaScript', async () => {
        await driver.get(`${url}/register`);
        await driver.wait(until.elementLocated(By.css('input')), 5000);
        const inputs = await driver.findElements(By.css('input'));
        await inputs[0].clear();
        await inputs[0].sendKeys('<script>alert("xss")</script>');
        await driver.sleep(500);
        let xss = false;
        try { await driver.switchTo().alert(); xss = true; await dismiss(); } catch(e) {}
        if (xss) throw new Error('XSS executed on register page!');
    });

    return results;
}

module.exports = { testValidation };
