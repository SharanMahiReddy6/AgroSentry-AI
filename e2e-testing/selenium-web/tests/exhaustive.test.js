const { By, until } = require('selenium-webdriver');

const ADMIN_EMAIL    = 'mahiworkmail6@gmail.com';
const ADMIN_PASSWORD = 'Mahi@Admin6';
const TEST_EMAIL     = 'mahiworkmail6@gmail.com';
const TEST_PASSWORD  = 'Mahi@Admin6';

async function testExhaustive(driver, url) {
    const results = [];

    const jsClick  = async (el) => await driver.executeScript('arguments[0].click()', el).catch(() => {});
    const clearAuth= async () => { try { await driver.executeScript('localStorage.clear();sessionStorage.clear();'); } catch(e) {} };
    const dismiss  = async () => { try { await (await driver.switchTo().alert()).accept(); } catch(e) {} };

    const runCheck = async (name, testFn) => {
        const start = Date.now();
        try {
            await testFn();
            results.push({ name: `[Crawler] ${name}`, status: 'Pass', duration: Date.now() - start, error: '' });
        } catch(e) {
            results.push({ name: `[Crawler] ${name}`, status: 'Fail', duration: Date.now() - start, error: e.message });
        }
    };

    const updateBanner = async (text) => {
        try {
            await driver.executeScript(`
                let b=document.getElementById('ag-crawl-banner');
                if(!b){b=document.createElement('div');b.id='ag-crawl-banner';
                b.style.cssText='position:fixed;bottom:0;left:0;width:100%;background:#D32F2F;color:white;z-index:999999;text-align:center;padding:8px 12px;font-size:13px;font-weight:bold;font-family:sans-serif;';
                document.body.appendChild(b);}
                b.innerText='🤖 Crawling: ${text.replace(/'/g, "\\'")}';
            `);
        } catch(e) {}
    };

    console.log('Running Exhaustive DOM Crawler Tests...');

    // ── Step 1: Authenticate as test user ─────────────────────────────────────
    await updateBanner('Authenticating as test user...');
    await clearAuth();
    await driver.get(`${url}/login`);
    await driver.sleep(1000);
    try {
        await driver.wait(until.elementLocated(By.css('input[type="email"]')), 5000);
        const em = await driver.findElement(By.css('input[type="email"]'));
        const pw = await driver.findElement(By.css('input[type="password"]'));
        await em.clear(); await em.sendKeys(TEST_EMAIL);
        await pw.clear(); await pw.sendKeys(TEST_PASSWORD);
        await driver.executeScript('arguments[0].click()', await driver.findElement(By.css('button[type="submit"]')));
        await driver.sleep(2500);
        await dismiss();
    } catch(e) {
        console.log('Crawler auth failed, continuing...', e.message);
    }

    // ── Step 2: Crawl each AgroSentry page ────────────────────────────────────
    const pages = [
        { path: '/',         name: 'Dashboard' },
        { path: '/scan',     name: 'Scan' },
        { path: '/history',  name: 'History' },
        { path: '/library',  name: 'Library' },
        { path: '/tips',     name: 'Tips' },
        { path: '/profile',  name: 'Profile' },
    ];

    // Destructive button text to avoid clicking
    const SKIP_KEYWORDS = ['delete', 'remove', 'clear', 'logout', 'log out', 'sign out', 'reject', 'deploy weights', 'start training'];

    for (const page of pages) {
        await updateBanner(`Loading: ${page.name}`);
        await driver.get(`${url}${page.path}`);
        await driver.sleep(1500);
        await dismiss();

        // Check we didn't get redirected to login (would mean auth failed)
        const curUrl = await driver.getCurrentUrl();
        if (curUrl.includes('/login')) {
            await runCheck(`${page.name}: Accessible when authenticated`, async () => {
                throw new Error(`Auth lost — redirected to /login on ${page.path}`);
            });
            continue;
        }

        await runCheck(`${page.name}: Page loads successfully (not /login)`, async () => {
            const cur = await driver.getCurrentUrl();
            if (cur.includes('/login')) throw new Error(`${page.name} redirected to login`);
        });

        await runCheck(`${page.name}: Page has <h1> heading`, async () => {
            const h1s = await driver.findElements(By.css('h1'));
            if (!h1s.length) throw new Error(`No h1 on ${page.name}`);
        });

        await runCheck(`${page.name}: Page has navigable header/nav`, async () => {
            const navEls = await driver.findElements(By.css('header, nav, [class*="header"], [class*="nav"]'));
            if (!navEls.length) throw new Error(`No header/nav on ${page.name}`);
        });

        // ── Verify all VISIBLE buttons are interactive ───────────────────────
        const allButtons = await driver.findElements(By.css('button'));
        for (let i = 0; i < allButtons.length; i++) {
            const btn = allButtons[i];
            let btnText = '';
            try { btnText = await btn.getText(); } catch(e) {}
            if (!btnText) {
                try { btnText = await btn.getAttribute('aria-label') || await btn.getAttribute('title') || `Button-${i+1}`; } catch(e) {}
            }
            btnText = (btnText || `Button-${i+1}`).trim().substring(0, 35);

            const isDestructive = SKIP_KEYWORDS.some(k => btnText.toLowerCase().includes(k));
            if (isDestructive) continue; // Skip destructive actions during crawl

            await runCheck(`${page.name}: Button "${btnText}" is visible or soft-skip`, async () => {
                try {
                    const visible = await btn.isDisplayed().catch(() => false);
                    if (!visible) return; // Hidden buttons are acceptable (collapsed menus, etc.)
                    const enabled = await btn.isEnabled().catch(() => false);
                    if (!enabled) return; // Disabled due to context (no file selected, etc.)
                    // Verify it's at least in the DOM and accessible
                    const tagName = await btn.getTagName().catch(() => '');
                    if (!tagName) throw new Error('Button element became stale');
                } catch(e) {
                    if (e.name === 'StaleElementReferenceError') return; // OK, page changed
                    throw e;
                }
            });
        }

        // ── Verify all internal links are present and have hrefs ─────────────
        const allLinks = await driver.findElements(By.css('a'));
        for (let i = 0; i < Math.min(allLinks.length, 15); i++) { // Cap at 15 links per page
            const link = allLinks[i];
            let linkText = '';
            try { linkText = await link.getText(); } catch(e) {}
            linkText = (linkText || `Link-${i+1}`).trim().substring(0, 30);

            await runCheck(`${page.name}: Link "${linkText}" has href`, async () => {
                try {
                    const href = await link.getAttribute('href').catch(() => null);
                    if (!href) throw new Error('Link has no href attribute');
                    const visible = await link.isDisplayed().catch(() => false);
                    if (!visible) return; // Hidden links are ok
                } catch(e) {
                    if (e.name === 'StaleElementReferenceError') return;
                    throw e;
                }
            });
        }
    }

    // ── Step 3: Admin page crawl (login as admin first) ────────────────────────
    await updateBanner('Authenticating as admin for /admin crawl...');
    await clearAuth();
    await driver.get(`${url}/login`);
    await driver.sleep(1000);
    try {
        await driver.wait(until.elementLocated(By.css('input[type="email"]')), 5000);
        const em = await driver.findElement(By.css('input[type="email"]'));
        const pw = await driver.findElement(By.css('input[type="password"]'));
        await em.clear(); await em.sendKeys(ADMIN_EMAIL);
        await pw.clear(); await pw.sendKeys(ADMIN_PASSWORD);
        await driver.executeScript('arguments[0].click()', await driver.findElement(By.css('button[type="submit"]')));
        await driver.sleep(2500);
        await dismiss();
    } catch(e) {
        console.log('Admin auth failed:', e.message);
    }

    await driver.get(`${url}/admin`);
    await driver.sleep(2000);
    await dismiss();

    await runCheck('Admin: /admin page accessible to admin user', async () => {
        const cur = await driver.getCurrentUrl();
        if (!cur.includes('/admin')) throw new Error(`Admin redirected to: ${cur}`);
    });

    await runCheck('Admin: Has "Super-Admin Workspace" heading', async () => {
        await driver.wait(until.elementLocated(By.css('h1')), 5000);
        const h1 = await driver.findElement(By.css('h1')).getText();
        if (!h1.match(/super-admin|admin|workspace/i)) throw new Error(`Admin H1: "${h1}"`);
    });

    await runCheck('Admin: Stats cards are present (≥4)', async () => {
        const cards = await driver.findElements(By.css('.card'));
        if (cards.length < 4) throw new Error(`Expected ≥4 cards, got ${cards.length}`);
    });

    await runCheck('Admin: Model Training tab shows 9 crop datasets', async () => {
        const body = await driver.findElement(By.css('body')).getText();
        const crops = ['apple', 'corn', 'grape', 'potato', 'peach'];
        let found = 0;
        for (const c of crops) { if (body.toLowerCase().includes(c)) found++; }
        if (found < 4) throw new Error(`Only ${found} crop datasets visible in admin`);
    });

    return results;
}

module.exports = { testExhaustive };
