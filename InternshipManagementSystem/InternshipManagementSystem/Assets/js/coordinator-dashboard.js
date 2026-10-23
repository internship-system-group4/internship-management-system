/* Real deferred data loading through the existing, role-protected Web Forms page.
   No fake waiting, data cache, alternate login, postback interception, or libraries. */
(function () {
    'use strict';
    var data = document.getElementById('dashboard-data');
    if (!data) return;
    var status = document.querySelector('[data-dashboard-status]');
    var announcement = document.getElementById('dashboard-announcement');
    var refresh = document.querySelector('[data-dashboard-refresh]');
    var motion = window.UimsMotion;
    var loading = false, disposed = false, controller, slowTimer, requestSequence = 0;
    function state(value, text) {
        data.dataset.loadState = value;
        data.setAttribute('aria-busy', value === 'loading' ? 'true' : 'false');
        announcement.dataset.state = value;
        status.textContent = text;
        if (refresh) refresh.disabled = value === 'loading';
    }
    function errorPanel() {
        var box = document.createElement('div');
        box.className = 'theme-alert dashboard-load-error';
        box.setAttribute('role', 'alert');
        var title = document.createElement('strong');
        title.textContent = 'Your overview could not be loaded.';
        var text = document.createElement('p');
        text.textContent = 'Check your connection and try again. Your records have not changed.';
        var retry = document.createElement('button');
        retry.type = 'button'; retry.className = 'btn btn-brand btn-sm';
        retry.dataset.dashboardRetry = 'true'; retry.textContent = 'Try again';
        var full = document.createElement('a');
        full.className = 'theme-link'; full.href = 'Dashboard.aspx?dashboardView=full';
        full.textContent = 'Open full dashboard';
        var actions = document.createElement('div');
        actions.className = 'dashboard-error-actions'; actions.append(retry, full);
        box.append(title, text, actions);
        return box;
    }
    async function load(restoreFocus) {
        if (loading || disposed) return;
        loading = true;
        var requestId = ++requestSequence;
        var restoreRefreshFocus = document.activeElement === refresh;
        var hadContent = !!data.querySelector('.dashboard-stat[data-metric]');
        var token = motion ? motion.begin(hadContent ? 'Refreshing program overview' : 'Loading program overview') : null;
        state('loading', hadContent ? 'Refreshing your overview' : 'Loading your program overview');
        var requestController = new AbortController();
        controller = requestController;
        var timeout = setTimeout(function () { requestController.abort(); }, 25000);
        slowTimer = setTimeout(function () { status.textContent = 'Still loading. Your connection is taking a little longer.'; }, 8000);
        try {
            var url = new URL(location.href);
            url.hash = ''; url.searchParams.set('dashboardView', 'content');
            var response = await fetch(url.href, {
                method: 'GET', credentials: 'same-origin', cache: 'no-store',
                headers: { 'X-Uims-Dashboard': 'content' }, signal: requestController.signal
            });
            if (!response.ok) throw new Error('Dashboard request failed.');
            var finalUrl = new URL(response.url);
            if (response.redirected && finalUrl.origin === location.origin &&
                /\/Pages\/(Account\/(Login|ChangePassword)|Public\/AccessDenied)\.aspx$/i.test(finalUrl.pathname)) {
                location.assign(finalUrl.href); return;
            }
            var documentCopy = new DOMParser().parseFromString(await response.text(), 'text/html');
            var content = documentCopy.getElementById('dashboard-data');
            if (!content || content.dataset.loadState === 'loading') throw new Error('Dashboard content unavailable.');
            var incomingState = content.dataset.loadState;
            // Only encoded, server-rendered dashboard content is replaced.
            // Keep the shell, form, view state, notification bell and focus intact.
            data.replaceChildren.apply(data, Array.from(content.childNodes).map(function (node) {
                return document.importNode(node, true);
            }));
            state(incomingState === 'ready' ? 'ready' : 'error',
                incomingState === 'ready' ? 'Overview up to date' : 'Overview unavailable');
            if (motion && incomingState === 'ready') motion.animateDashboard(data);
            if (restoreFocus) {
                var heading = data.querySelector('#overview-title') || data.querySelector('[role="alert"]');
                if (heading) { heading.tabIndex = -1; heading.focus({ preventScroll: true }); }
            }
        } catch (error) {
            if (disposed) return;
            if (!hadContent) data.replaceChildren(errorPanel());
            else {
                data.querySelectorAll('.dashboard-load-error').forEach(function (node) { node.remove(); });
                data.prepend(errorPanel());
            }
            state('error', hadContent ? 'Refresh failed. Previous overview retained.' : 'Overview unavailable');
            if (restoreFocus) data.querySelector('[data-dashboard-retry]').focus({ preventScroll: true });
        } finally {
            clearTimeout(timeout); clearTimeout(slowTimer);
            if (requestId === requestSequence) {
                loading = false;
                if (refresh) {
                    refresh.disabled = false;
                    if (!disposed && restoreRefreshFocus && document.activeElement === document.body)
                        refresh.focus({ preventScroll: true });
                }
            }
            if (motion) motion.end(token);
        }
    }
    if (refresh) refresh.addEventListener('click', function () { load(false); });
    data.addEventListener('click', function (event) {
        var retry = event.target.closest('[data-dashboard-retry]');
        if (retry) load(true);
    });
    window.addEventListener('pagehide', function () {
        disposed = true; ++requestSequence; clearTimeout(slowTimer);
        if (controller) controller.abort();
    });
    window.addEventListener('pageshow', function (event) {
        if (!event.persisted) return;
        disposed = false; loading = false;
        if (data.dataset.loadState === 'loading') load(false);
    });
    if (data.dataset.loadState === 'loading') load(false);
    else if (motion) motion.animateDashboard(data);
}());
