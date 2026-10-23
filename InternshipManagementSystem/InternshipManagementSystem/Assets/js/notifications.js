(function () {
    'use strict';
    var arabic = document.documentElement.lang === 'ar';
    function label(en, ar) { return arabic ? ar : en; }
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
            root.querySelector('[data-notice-total]').textContent = unread ? unread + label(' new', ' جديدة') : '';
            root.querySelector('[data-notice-mark]').disabled = !unread;
            var selected = items.filter(function (n) { return filter === 'all' || !n.IsRead; });
            list.replaceChildren();
            if (!selected.length) {
                var empty = node('div', 'notice-empty');
                empty.append(node('span', 'notice-empty-icon', '✓'), node('strong', '', label('You’re all caught up', 'أنت على اطلاع بكل جديد')), node('p', '', label('New activity will appear here.', 'ستظهر النشاطات الجديدة هنا.')));
                list.append(empty);
            }
            selected.forEach(function (n) {
                var row = node('a', 'notice-item' + (n.IsRead ? '' : ' is-unread'));
                var url = new URL(n.Url, window.location.origin);
                if (url.origin !== window.location.origin) return;
                row.href = url.href;
                var title = n.Title.toLowerCase();
                var kind = /meeting/.test(title) ? 'meeting' : /task|submission/.test(title) ? 'task' : /assign|supervisor|placement/.test(title) ? 'people' : 'review';
                var paths = { meeting: '<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M7 3v4m10-4v4M3 11h18m-12 4h1m4 0h1"/>', task: '<rect x="5" y="3" width="14" height="18" rx="2"/><path d="M9 8h6m-6 4h6m-6 4h3"/>', people: '<circle cx="9" cy="8" r="3"/><path d="M3 21v-2a6 6 0 0 1 12 0v2m1-17a3 3 0 0 1 0 6m3 11v-2a6 6 0 0 0-2-4"/>', review: '<circle cx="12" cy="12" r="9"/><path d="m8 12 3 3 5-6"/>' };
                var icon = node('span', 'notice-icon notice-icon-' + kind);
                icon.innerHTML = '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">' + paths[kind] + '</svg>';
                row.append(icon);
                var content = node('div', 'notice-copy');
                content.append(node('strong', '', n.Title), node('p', '', n.Detail));
                var date = new Date(n.CreatedAt), minutes = Math.max(0, Math.floor((Date.now() - n.CreatedAt) / 60000));
                var time = node('time', '', minutes < 1 ? label('Just now', 'الآن') : minutes < 60 ? minutes + label(' min ago', ' دقيقة مضت') : minutes < 1440 ? Math.floor(minutes / 60) + label(' hr ago', ' ساعة مضت') : date.toLocaleDateString(undefined, { month: 'short', day: 'numeric' }));
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
                if (!response.ok) throw new Error(response.status === 401 ? label('Sign in again to see your notifications.', 'سجّل الدخول مجددًا لعرض الإشعارات.') : label('Unable to load notifications. Try again shortly.', 'تعذر تحميل الإشعارات. حاول مجددًا بعد قليل.'));
                var data = await response.json(); items = data.items; state.textContent = ''; render();
            } catch (error) {
                state.textContent = error.message;
                if (!items.length) list.replaceChildren(node('p', 'notice-empty', label('Your activity could not be loaded.', 'تعذر تحميل النشاطات.')));
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
