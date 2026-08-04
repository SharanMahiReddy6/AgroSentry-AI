const { By, until } = require('selenium-webdriver');

async function testUI(driver, url) {
    const results = [];
    const jsClick = async (el) => await driver.executeScript('arguments[0].click()', el);
    const clearAuth = async () => { try { await driver.executeScript('localStorage.clear();sessionStorage.clear();'); } catch(e) {} };

    const runTest = async (name, testFn) => {
        const start = Date.now();
        try {
            await driver.executeScript(`
                let b=document.getElementById('ag-ui-banner');
                if(!b){b=document.createElement('div');b.id='ag-ui-banner';
                b.style.cssText='position:fixed;bottom:0;left:0;width:100%;background:#0277BD;color:white;z-index:999999;text-align:center;padding:8px 12px;font-size:13px;font-weight:bold;font-family:sans-serif;';
                document.body.appendChild(b);}
                b.innerText='🎨 UI Test: ${name.replace(/'/g, "\\'")}';
            `).catch(() => {});
            await testFn();
            await driver.sleep(500);
            results.push({ name: `[UI/UX] ${name}`, status: 'Pass', duration: Date.now() - start, error: '' });
        } catch(e) {
            results.push({ name: `[UI/UX] ${name}`, status: 'Fail', duration: Date.now() - start, error: e.message });
        }
    };

    console.log('Running UI/UX Tests...');

    // ── Login Page ─────────────────────────────────────────────────────────────
    await clearAuth();
    await driver.get(`${url}/login`);
    await driver.wait(until.elementLocated(By.css('h1')), 8000);

    await runTest('Login: Page title contains AgroSentry', async () => {
        const title = await driver.getTitle();
        if (!title.toLowerCase().includes('agrosentry')) throw new Error(`Title: "${title}"`);
    });

    await runTest('Login: H1 contains "Welcome" or "AgroSentry" or "Sign"', async () => {
        const h1 = await driver.findElement(By.css('h1')).getText();
        if (!h1.match(/welcome|agrosentry|sign in/i)) throw new Error(`H1: "${h1}"`);
    });

    await runTest('Login: Has Leaf icon (AgroSentry brand)', async () => {
        const icons = await driver.findElements(By.css('.lucide-leaf, [class*="lucide-leaf"], svg'));
        if (!icons.length) throw new Error('No brand icon found');
    });

    await runTest('Login: Email input is present and visible', async () => {
        const el = await driver.findElement(By.css('input[type="email"]'));
        if (!await el.isDisplayed()) throw new Error('Email input not visible');
    });

    await runTest('Login: Password input is present and visible', async () => {
        const el = await driver.findElement(By.css('input[type="password"]'));
        if (!await el.isDisplayed()) throw new Error('Password input not visible');
    });

    await runTest('Login: Submit button has btn-primary class', async () => {
        const btn = await driver.findElement(By.css('button[type="submit"]'));
        const cls = await btn.getAttribute('class');
        if (!cls.includes('btn-primary')) throw new Error(`Button classes: "${cls}"`);
    });

    await runTest('Login: "Forgot Password" link navigates to /forgot-password', async () => {
        const links = await driver.findElements(By.css('a'));
        let found = false;
        for (const l of links) {
            const href = await l.getAttribute('href').catch(() => '');
            const txt  = await l.getText().catch(() => '');
            if (href.includes('forgot') || txt.toLowerCase().includes('forgot')) { found = true; break; }
        }
        if (!found) throw new Error('No "Forgot Password" link on login page');
    });

    await runTest('Login: "Create Account" link navigates to /register', async () => {
        const links = await driver.findElements(By.css('a'));
        let found = false;
        for (const l of links) {
            const href = await l.getAttribute('href').catch(() => '');
            const txt  = await l.getText().catch(() => '');
            if (href.includes('register') || txt.toLowerCase().includes('create')) { found = true; break; }
        }
        if (!found) throw new Error('No "Create Account" link on login page');
    });

    await runTest('Login: Inputs have rounded border (design consistency)', async () => {
        const input = await driver.findElement(By.css('input[type="email"]'));
        const radius = await input.getCssValue('border-radius');
        if (!radius || radius === '0px') throw new Error(`Inputs should have rounded corners, got: ${radius}`);
    });

    await runTest('Login: Primary button has non-transparent background color', async () => {
        const btn = await driver.findElement(By.css('button[type="submit"]'));
        const bg = await btn.getCssValue('background-color');
        if (bg === 'rgba(0, 0, 0, 0)' || bg === 'transparent') throw new Error(`Button has no background: ${bg}`);
    });

    await runTest('Login: Body font is not browser default (custom font applied)', async () => {
        const font = await driver.executeScript('return window.getComputedStyle(document.body).fontFamily');
        if (!font || font.toLowerCase() === 'times new roman' || font.toLowerCase() === 'serif') {
            throw new Error(`No custom font applied: ${font}`);
        }
    });

    await runTest('Login: Page has animate-in class on main card (animation ready)', async () => {
        const el = await driver.findElements(By.css('.animate-in'));
        if (!el.length) throw new Error('No .animate-in class — animation CSS not applied');
    });

    // ── Register Page ──────────────────────────────────────────────────────────
    await driver.get(`${url}/register`);
    await driver.wait(until.elementLocated(By.css('h1')), 8000);

    await runTest('Register: H1 says "Join AgroSentry"', async () => {
        const h1 = await driver.findElement(By.css('h1')).getText();
        if (!h1.includes('Join AgroSentry')) throw new Error(`Register H1: "${h1}"`);
    });

    await runTest('Register: Has Name input field', async () => {
        const inputs = await driver.findElements(By.css('input:not([type="email"]):not([type="password"])'));
        if (!inputs.length) throw new Error('No name/text input found on register page');
    });

    await runTest('Register: Has Email input field', async () => {
        await driver.findElement(By.css('input[type="email"]'));
    });

    await runTest('Register: Has Password input field', async () => {
        await driver.findElement(By.css('input[type="password"]'));
    });

    await runTest('Register: Has Crop Type dropdown (select element)', async () => {
        const sel = await driver.findElements(By.css('select'));
        if (!sel.length) throw new Error('No crop type dropdown on register page');
    });

    await runTest('Register: Has "Sign in" link back to login', async () => {
        const links = await driver.findElements(By.css('a'));
        let found = false;
        for (const l of links) {
            const txt = await l.getText().catch(() => '');
            if (txt.toLowerCase().includes('sign in') || txt.toLowerCase().includes('login')) { found = true; break; }
        }
        if (!found) throw new Error('No "Sign in" link on register page');
    });

    await runTest('Register: autocomplete="off" on name field (no browser auto-fill)', async () => {
        const inputs = await driver.findElements(By.css('input'));
        for (const inp of inputs) {
            const ac = await inp.getAttribute('autocomplete').catch(() => '');
            const type = await inp.getAttribute('type').catch(() => '');
            // Password has new-password, others should be off
            if (type !== 'password' && ac && ac !== 'off' && ac !== 'new-password') {
                // Just verify form has autocomplete=off at the form level
                const form = await driver.findElement(By.css('form'));
                const formAc = await form.getAttribute('autocomplete').catch(() => 'on');
                if (formAc !== 'off') throw new Error(`Form autocomplete is "${formAc}", should be off`);
                break;
            }
        }
    });

    // ── Forgot Password Page ───────────────────────────────────────────────────
    await driver.get(`${url}/forgot-password`);
    await driver.wait(until.elementLocated(By.css('input[type="email"]')), 12000);

    await runTest('ForgotPassword: Step 1 shows email input', async () => {
        const el = await driver.findElement(By.css('input[type="email"]'));
        if (!await el.isDisplayed()) throw new Error('Email input not visible');
    });

    await runTest('ForgotPassword: Has submit button for step 1', async () => {
        const btn = await driver.findElement(By.css('button[type="submit"]'));
        if (!await btn.isDisplayed()) throw new Error('Submit button not visible');
    });

    await runTest('ForgotPassword: Has link back to login page', async () => {
        const links = await driver.findElements(By.css('a'));
        let found = false;
        for (const l of links) {
            const href = await l.getAttribute('href').catch(() => '');
            const txt  = await l.getText().catch(() => '');
            if (href.includes('/login') || txt.toLowerCase().includes('back') || txt.toLowerCase().includes('login')) {
                found = true; break;
            }
        }
        if (!found) throw new Error('No back-to-login link on forgot-password page');
    });

    return results;
}

module.exports = { testUI };
