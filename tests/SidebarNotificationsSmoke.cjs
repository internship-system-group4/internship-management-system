// Run against Run-GradesExportSmoke.ps1 -Serve. All accounts and activity are synthetic.
// NODE_PATH must point to a Playwright installation; no frontend dependency is added.
const { chromium } = require('playwright');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

(async function () {
    const base = 'http://localhost:19082';
    const browser = await chromium.launch({ channel: 'chrome', headless: true });
    const output = path.join(__dirname, 'artifacts', 'sidebar-notifications');
    fs.mkdirSync(output, { recursive: true });
    let checks = 0;
    function check(value, message) { assert.ok(value, message); checks++; }
    try {
        for (const role of ['coordinator1', 'company1', 'academic1', 's1']) {
            console.log('Checking sidebar notifications: ' + role);
            const context = await browser.newContext({ viewport: { width: 1440, height: 900 } });
            let items = Array.from({ length: 12 }, (_, i) => ({ Id: 'fixture-' + i, Title: 'Synthetic task update ' + i,
                Detail: 'Fixture activity for sidebar layout and read-state checks.', IsRead: i > 2,
                CreatedAt: Date.now() - i * 60000, Url: '/Pages/Notifications/Inbox.aspx' }));
            await context.route('**/Pages/Notifications/Feed.ashx', async route => {
                if (route.request().method() === 'POST') {
                    const id = new URLSearchParams(route.request().postData()).get('id');
                    check(!!route.request().headers()['x-uims-csrf'], 'Read action has CSRF token');
                    items.forEach(item => { if (id === 'all' || id === item.Id) item.IsRead = true; });
                }
                await route.fulfill({ json: { items, unread: items.filter(item => !item.IsRead).length } });
            });
            const page = await context.newPage();
            const errors = [];
            page.on('pageerror', error => errors.push(error.message));
            await page.goto(base + '/FixtureLogin.aspx?id=' + role);
            await page.goto(base + '/Pages/Notifications/Inbox.aspx');
            const sidebar = page.locator('[data-portal-sidebar]');
            const bell = sidebar.locator('.notice-bell');
            const summary = bell.locator('summary');
            const panel = bell.locator('.notice-panel');
            await bell.locator('[data-notice-count]').filter({ hasText: '3' }).waitFor().catch(async error => {
                console.error({ role, url: page.url(), errors, state: await bell.innerText(), scripts: await page.locator('script[src]').evaluateAll(els => els.map(el => el.src)) });
                throw error;
            });
            check(await page.locator('.notice-bell').count() === 1, 'Exactly one bell belongs to the sidebar: ' + role);
            check(await page.locator('.uims-topbar .notice-bell').count() === 0, 'No duplicate header bell: ' + role);
            check(await summary.getAttribute('aria-controls') === await panel.getAttribute('id'), 'Summary labels its panel: ' + role);
            let formPosts = 0;
            page.on('request', request => { if (request.method() === 'POST' && !request.url().includes('/Feed.ashx')) formPosts++; });
            for (const rtl of [false, true]) {
                if (rtl) { await sidebar.locator('[data-lang-switch]').click(); await page.waitForLoadState(); }
                check(await page.locator('html').getAttribute('dir') === (rtl ? 'rtl' : 'ltr'), 'Server language switching works');
                for (const dark of [false, true]) {
                    await page.evaluate(value => document.documentElement.setAttribute('data-theme', value ? 'dark' : 'light'), dark);
                    for (const size of [{ width: 1440, height: 900 }, { width: 390, height: 720 }, { width: 320, height: 600 }, { width: 1000, height: 420 }]) {
                        await page.setViewportSize(size);
                        if (size.width <= 900) {
                            await page.locator('.student-nav-toggle').click();
                            await sidebar.waitFor({ state: 'visible' });
                        }
                        await summary.click();
                        await panel.waitFor({ state: 'visible' });
                        check(await summary.getAttribute('aria-expanded') === 'true', 'Expanded state follows native details');
                        check(await panel.evaluate(el => { const r = el.getBoundingClientRect(); return r.left >= 0 && r.top >= 0 && r.right <= innerWidth && r.bottom <= innerHeight; }), 'Panel stays in viewport: ' + role + '/' + size.width + '/' + rtl + '/' + dark);
                        check(await panel.locator('.notice-list').evaluate(el => el.scrollHeight > el.clientHeight), 'Activity list scrolls within panel');
                        check(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), 'No horizontal page overflow');
                        if (role === 'coordinator1' && dark && size.width === 390) await page.screenshot({ path: path.join(output, rtl ? 'ar-dark-mobile.png' : 'en-dark-mobile.png') });
                        await page.keyboard.press('Escape');
                        check(!await bell.evaluate(el => el.open), 'Escape closes the bell');
                        check(await summary.evaluate(el => el === document.activeElement), 'Escape returns focus to bell');
                        if (size.width <= 900) {
                            check(await sidebar.getAttribute('role') === 'dialog', 'First Escape keeps drawer open');
                            await page.keyboard.press('Escape');
                            check(await page.locator('.student-nav-toggle').evaluate(el => el === document.activeElement), 'Second Escape closes drawer and restores focus');
                        }
                    }
                }
            }
            await page.setViewportSize({ width: 1440, height: 900 });
            await summary.click();
            await bell.locator('[data-notice-filter=unread]').click();
            check(await bell.locator('.notice-item').count() === 3, 'Unread filtering works');
            await bell.locator('[data-notice-mark]').click();
            await bell.locator('[data-notice-count]').waitFor({ state: 'hidden' });
            check(await bell.locator('.notice-item').count() === 0, 'Mark all read updates the sidebar');
            await bell.locator('.notice-footer a').click();
            await page.waitForLoadState();
            check(page.url().includes('/Pages/Notifications/Inbox.aspx'), 'View all opens the full inbox');
            await sidebar.locator('.uims-sidebar-pin').click();
            await page.mouse.move(800, 20);
            await page.evaluate(() => document.activeElement.blur());
            await page.waitForFunction(() => document.querySelector('[data-portal-sidebar]').dataset.expanded === 'false');
            check(await summary.isVisible(), 'Notification bell remains accessible in compact rail');
            await summary.focus();
            await page.keyboard.press('Enter');
            await panel.waitFor({ state: 'visible' });
            check(await summary.getAttribute('aria-expanded') === 'true', 'Keyboard opens compact sidebar notifications');
            check(formPosts === 0, 'Notification controls never submit the page form');
            check(errors.length === 0, 'No browser errors: ' + JSON.stringify(errors));
            await context.close();
        }
        console.log('PASS: ' + checks + ' sidebar notification checks across all four roles.');
    } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
