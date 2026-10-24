/* =============================================================================
   UIMS - notification bell (Layout/NotificationBell.ascx)
   - Refreshes the bell every 20 seconds from Pages/Account/NotificationFeed.ashx,
     so new notifications appear without reloading the page.
   - Shows a toast for each new unread notification (once per browser).
   - "Mark all as read" in the dropdown.
   - Pages opened from a notification with ?focus={id} scroll to and highlight
     the matching item (for example one application card).
   ============================================================================= */
(function () {
    'use strict';

    var POLL_MS = 20000;
    var FIRST_VISIT_WINDOW_MS = 3 * 24 * 60 * 60 * 1000;
    var t = typeof window.uimsT === 'function' ? window.uimsT : function (k) { return k; };

    // ---- highlight the item a notification points to -----------------------
    function focusTarget() {
        var params = new URLSearchParams(window.location.search);
        var id = params.get('focus');
        if (!id) return;
        var safe = window.CSS && CSS.escape ? CSS.escape(id) : id.replace(/["\\]/g, '');
        var target = document.querySelector('[data-focus-id="' + safe + '"], [data-application-id="' + safe + '"]');
        if (!target) return;
        var reduce = window.matchMedia && matchMedia('(prefers-reduced-motion: reduce)').matches;
        target.scrollIntoView({ behavior: reduce ? 'auto' : 'smooth', block: 'center' });
        target.classList.add('uims-focus-flash');
        setTimeout(function () { target.classList.remove('uims-focus-flash'); }, 3200);
    }

    var root = document.querySelector('.uims-notify[data-notify-feed]');
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', focusTarget); else focusTarget();
    if (!root) return;

    var feedUrl = root.getAttribute('data-notify-feed');
    var allUrl = root.getAttribute('data-notify-all');
    var emptyText = root.getAttribute('data-notify-empty') || '';
    var seenKey = 'uims-notify-seen:' + (root.getAttribute('data-notify-user') || '');
    var button = root.querySelector('.uims-notify-button');
    var badge = root.querySelector('.uims-notify-badge');
    var count = root.querySelector('.uims-notify-count');
    var readAll = root.querySelector('.uims-notify-readall');
    var warning = root.querySelector('.uims-notify-warning');
    var list = root.querySelector('.uims-notify-list');
    var stopped = false;

    function readSeen() {
        try {
            var value = +localStorage.getItem(seenKey);
            return value > 0 ? value : Date.now() - FIRST_VISIT_WINDOW_MS;
        } catch (e) { return Date.now() - FIRST_VISIT_WINDOW_MS; }
    }
    function writeSeen(value) {
        try { localStorage.setItem(seenKey, String(value)); } catch (e) { /* private window: toasts may repeat */ }
    }

    // ---- bell badge and list ------------------------------------------------
    function setUnread(n) {
        badge.textContent = n > 9 ? '9+' : String(n);
        badge.hidden = n <= 0;
        if (count) { count.textContent = t('NotifyUnread', n); count.hidden = n <= 0; }
        if (readAll) readAll.hidden = n <= 0;
        button.setAttribute('aria-label', n > 0 ? t('NotifyBellLabel', n) : (button.getAttribute('title') || ''));
    }

    function el(tag, className, text) {
        var node = document.createElement(tag);
        if (className) node.className = className;
        if (text !== undefined) node.textContent = text;
        return node;
    }

    function renderItem(item) {
        var link = el('a', 'uims-notify-item' + (item.read ? '' : ' is-unread'));
        link.href = item.url;
        link.setAttribute('data-created', item.createdAt);
        var icon = el('span', 'uims-notify-icon');
        icon.setAttribute('data-type', item.type);
        icon.innerHTML = item.icon; // fixed server markup, never user text
        var text = el('span', 'uims-notify-text');
        var meta = el('span', 'uims-notify-meta');
        var type = el('span', 'uims-notify-type', item.typeLabel);
        type.setAttribute('data-type', item.type);
        meta.append(type, el('small', '', item.time));
        text.append(meta, el('strong', '', item.title), el('span', 'uims-notify-msg', item.message));
        link.append(icon, text);
        return link;
    }

    function render(data) {
        if (!data.ok) {
            if (data.error) list.replaceChildren(el('p', 'uims-notify-empty', data.error));
            return;
        }
        setUnread(data.unread);
        if (warning) { warning.textContent = data.warning || ''; warning.hidden = !data.warning; }
        if (!data.items.length) list.replaceChildren(el('p', 'uims-notify-empty', emptyText));
        else list.replaceChildren.apply(list, data.items.map(renderItem));
    }

    // ---- toast ----------------------------------------------------------------
    var region;
    function toast(items) {
        if (!items.length) return;
        var item = items[0];
        if (!region) {
            region = el('div', 'uims-ntoast-region');
            region.setAttribute('role', 'status');
            region.setAttribute('aria-live', 'polite');
            document.body.append(region);
        }
        region.replaceChildren();

        var card = el('div', 'uims-ntoast');
        card.setAttribute('data-type', item.type);
        var icon = el('span', 'uims-notify-icon');
        icon.setAttribute('data-type', item.type);
        icon.innerHTML = item.icon;

        var body = el('div', 'uims-ntoast-body');
        var meta = el('span', 'uims-notify-meta');
        var type = el('span', 'uims-notify-type', item.typeLabel);
        type.setAttribute('data-type', item.type);
        meta.append(type, el('small', '', item.time));
        body.append(meta, el('strong', 'uims-ntoast-title', item.title), el('p', 'uims-ntoast-msg', item.message));
        if (items.length > 1) body.append(el('p', 'uims-ntoast-more', t('NotifyMany', items.length)));

        var actions = el('div', 'uims-ntoast-actions');
        var open = el('a', 'uims-ntoast-open', t('NotifyOpen'));
        open.href = item.url;
        actions.append(open);
        if (items.length > 1) {
            var all = el('a', 'uims-ntoast-all', t('NotifyViewAll'));
            all.href = allUrl;
            actions.append(all);
        }
        body.append(actions);

        var close = el('button', 'uims-ntoast-close');
        close.type = 'button';
        close.setAttribute('aria-label', t('NotifyDismiss'));
        close.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><path d="M6 6l12 12M18 6 6 18"/></svg>';

        card.append(icon, body, close);
        region.append(card);

        var timer;
        function hide() { clearTimeout(timer); card.classList.add('is-leaving'); setTimeout(function () { card.remove(); }, 220); }
        function arm() { clearTimeout(timer); timer = setTimeout(hide, 12000); }
        close.addEventListener('click', hide);
        card.addEventListener('mouseenter', function () { clearTimeout(timer); });
        card.addEventListener('mouseleave', arm);
        card.addEventListener('focusin', function () { clearTimeout(timer); });
        arm();

        button.classList.remove('is-ringing');
        void button.offsetWidth;
        button.classList.add('is-ringing');
    }

    function announceNew(items) {
        var seen = readSeen();
        var fresh = items.filter(function (i) { return !i.read && i.createdAt > seen; })
                         .sort(function (a, b) { return b.createdAt - a.createdAt; });
        if (!fresh.length) return;
        writeSeen(fresh[0].createdAt);
        toast(fresh);
    }

    // Items already on the page (no request needed for the first toast).
    function itemsFromPage() {
        return Array.prototype.map.call(list.querySelectorAll('.uims-notify-item'), function (a) {
            var icon = a.querySelector('.uims-notify-icon');
            var type = a.querySelector('.uims-notify-type');
            var small = a.querySelector('.uims-notify-meta small');
            return {
                url: a.getAttribute('href'),
                read: !a.classList.contains('is-unread'),
                createdAt: +a.getAttribute('data-created') || 0,
                type: icon ? icon.getAttribute('data-type') : '',
                icon: icon ? icon.innerHTML : '',
                typeLabel: type ? type.textContent : '',
                time: small ? small.textContent : '',
                title: (a.querySelector('strong') || {}).textContent || '',
                message: (a.querySelector('.uims-notify-msg') || {}).textContent || ''
            };
        });
    }

    // ---- talking to the server ----------------------------------------------
    function request(method, query) {
        return fetch(feedUrl + (query || ''), {
            method: method,
            credentials: 'same-origin',
            cache: 'no-store',
            headers: { 'X-UIMS-Request': '1', 'Accept': 'application/json' }
        }).then(function (response) {
            if (response.status === 401) { stopped = true; return null; }
            return response.json();
        });
    }

    var busy = false;
    function poll() {
        if (stopped || busy || document.hidden) return;
        busy = true;
        request('GET').then(function (data) {
            if (!data) return;
            render(data);
            if (data.ok) announceNew(data.items);
        }).catch(function () { /* offline for a moment: try again next time */ })
          .then(function () { busy = false; });
    }

    if (readAll) {
        readAll.addEventListener('click', function () {
            readAll.disabled = true;
            request('POST', '?action=readAll').then(function (data) { if (data) render(data); })
                .catch(function () { })
                .then(function () { readAll.disabled = false; });
        });
    }

    announceNew(itemsFromPage());
    setInterval(poll, POLL_MS);
    document.addEventListener('visibilitychange', function () { if (!document.hidden) poll(); });
}());
