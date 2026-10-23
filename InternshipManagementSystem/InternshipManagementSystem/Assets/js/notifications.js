(function () {
    'use strict';
    document.querySelectorAll('[data-notifications]').forEach(function (root) {
        var items = [], filter = 'all', busy = false;
        var list = root.querySelector('[data-notice-list]');
        var state = root.querySelector('[data-notice-state]');
        function node(tag, cls, value) {
            var el = document.createElement(tag); el.className = cls;
            if (value) el.textContent = value;
            return el;
        }
        function render() {
            var unread = items.filter(function (n) { return !n.IsRead; }).length;
            var count = root.querySelector('[data-notice-count]');
            if (count) { count.hidden = !unread; count.textContent = unread > 99 ? '99+' : unread; }
            root.querySelector('[data-notice-total]').textContent = unread ? unread + ' new' : '';
            root.querySelector('[data-notice-mark]').disabled = !unread;
            var selected = items.filter(function (n) { return filter === 'all' || !n.IsRead; });
            list.replaceChildren();
            if (!selected.length) {
                var empty = node('div', 'notice-empty');
                empty.append(node('span', 'notice-empty-icon', '✓'), node('strong', '', 'You’re all caught up'), node('p', '', 'New activity will appear here.'));
                list.append(empty);
            }
            selected.forEach(function (n) {
                var row = node('a', 'notice-item' + (n.IsRead ? '' : ' is-unread'));
                var url = new URL(n.Url, window.location.origin);
                if (url.origin !== window.location.origin) return;
                row.href = url.href;
                var title = n.Title.toLowerCase();
                var kind = /meeting/.test(title) ? 'meeting' : /task|submission/.test(title) ? 'task' : /assign|supervisor|placement/.test(title) ? 'people' : 'review';
                var symbol = { meeting: '◷', task: '▤', people: '♧', review: '✓' }[kind];
                row.append(node('span', 'notice-icon notice-icon-' + kind, symbol));
                var content = node('div', 'notice-copy');
                content.append(node('strong', '', n.Title), node('p', '', n.Detail));
                var date = new Date(n.CreatedAt), minutes = Math.max(0, Math.floor((Date.now() - n.CreatedAt) / 60000));
                var time = node('time', '', minutes < 1 ? 'Just now' : minutes < 60 ? minutes + ' min ago' : minutes < 1440 ? Math.floor(minutes / 60) + ' hr ago' : date.toLocaleDateString(undefined, { month: 'short', day: 'numeric' }));
                time.dateTime = date.toISOString(); time.title = date.toLocaleString(); content.append(time);
                row.append(content);
                if (!n.IsRead) row.append(node('span', 'notice-dot'));
                row.addEventListener('click', function (event) {
                    if (n.IsRead || event.ctrlKey || event.metaKey || event.shiftKey || event.button !== 0) return;
                    event.preventDefault();
                    request(n.Id).finally(function () { window.location.assign(url.href); });
                });
                list.append(row);
            });
        }
        async function request(id) {
            try {
                var response = await fetch(root.dataset.endpoint, id ? {
                    method: 'POST', credentials: 'same-origin', headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'X-UIMS-CSRF': root.dataset.token },
                    body: 'id=' + encodeURIComponent(id)
                } : { credentials: 'same-origin', cache: 'no-store' });
                if (!response.ok) throw new Error(response.status === 401 ? 'Sign in again to see your notifications.' : 'Unable to load notifications. Try again shortly.');
                var data = await response.json(); items = data.items; state.textContent = ''; render();
            } catch (error) {
                state.textContent = error.message;
                if (!items.length) list.replaceChildren(node('p', 'notice-empty', 'Your activity could not be loaded.'));
            }
        }
        root.querySelectorAll('[data-notice-filter]').forEach(function (button) {
            button.addEventListener('click', function () {
                filter = button.dataset.noticeFilter;
                root.querySelectorAll('[data-notice-filter]').forEach(function (b) { b.setAttribute('aria-pressed', String(b === button)); });
                render();
            });
        });
        root.querySelector('[data-notice-mark]').addEventListener('click', function () { request('all'); });
        root.addEventListener('toggle', function () { if (root.open) request(); });
        root.addEventListener('keydown', function (event) { if (event.key === 'Escape' && root.open) { root.open = false; root.querySelector('summary').focus(); } });
        document.addEventListener('click', function (event) { if (root.open && !root.contains(event.target)) root.open = false; });
        async function refresh() { if (busy || document.hidden) return; busy = true; await request(); busy = false; }
        refresh(); setInterval(refresh, 30000);
        document.addEventListener('visibilitychange', function () { if (!document.hidden) refresh(); });
    });
}());
