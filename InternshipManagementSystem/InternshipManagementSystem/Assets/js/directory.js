/* Coordinator directories (students, academic supervisors).
   - Instant search and filters over the rows already on the page.
   - "View details" fills one pop-up from the row data (no postback).
   Markup: [data-dir] root, [data-dir-row] rows with data-search and one
   data-* value per filter, [data-dir-search], [data-dir-filter="name"],
   [data-dir-count], [data-dir-empty], <script data-dir-data> JSON rows,
   [data-dir-view="index"] buttons and one [data-dir-view-modal] pop-up. */
(function () {
    'use strict';

    function remember(key, value) { try { sessionStorage.setItem(key, value); } catch (e) { } }
    function recall(key) { try { return sessionStorage.getItem(key); } catch (e) { return null; } }

    function setupFilters(root) {
        var rows = Array.prototype.slice.call(root.querySelectorAll('[data-dir-row]'));
        var search = root.querySelector('[data-dir-search]');
        var filters = Array.prototype.slice.call(root.querySelectorAll('[data-dir-filter]'));
        var count = root.querySelector('[data-dir-count]');
        var empty = root.querySelector('[data-dir-empty]');
        var storeKey = 'uims-dir:' + location.pathname;

        // Keep the search and filters after a postback (for example after "Manage").
        var saved = recall(storeKey);
        if (saved && !/[?&]major=/.test(location.search)) {
            try {
                var state = JSON.parse(saved);
                if (search && state.q) search.value = state.q;
                filters.forEach(function (f) { if (state[f.dataset.dirFilter]) f.value = state[f.dataset.dirFilter]; });
            } catch (e) { }
        }

        function apply() {
            var query = search ? search.value.trim().toLowerCase() : '';
            var shown = 0, state = { q: search ? search.value : '' };
            filters.forEach(function (f) { state[f.dataset.dirFilter] = f.value; });
            rows.forEach(function (row) {
                var match = !query || (row.dataset.search || '').indexOf(query) >= 0;
                filters.forEach(function (f) {
                    if (match && f.value && row.dataset[f.dataset.dirFilter] !== f.value) match = false;
                });
                row.hidden = !match;
                if (match) shown++;
            });
            if (count) count.textContent = shown === rows.length ? rows.length : shown + ' / ' + rows.length;
            if (empty) empty.hidden = rows.length === 0 || shown > 0;
            root.classList.toggle('is-filtered', shown !== rows.length);
            remember(storeKey, JSON.stringify(state));
        }

        if (search) search.addEventListener('input', apply);
        filters.forEach(function (f) { f.addEventListener('change', apply); });
        apply();
    }

    function setupDetails(root) {
        var source = root.querySelector('[data-dir-data]');
        var modal = document.querySelector('[data-dir-view-modal]');
        if (!source || !modal) return;
        var data = [];
        try { data = JSON.parse(source.textContent || '[]'); } catch (e) { return; }

        root.addEventListener('click', function (event) {
            var button = event.target.closest('[data-dir-view]');
            if (!button) return;
            var item = data[Number(button.dataset.dirView)];
            if (!item) return;

            modal.querySelectorAll('[data-field]').forEach(function (el) {
                var value = item[el.dataset.field];
                el.textContent = Array.isArray(value) ? value.join(', ') : (value === null || value === undefined ? '' : String(value));
            });
            modal.querySelectorAll('[data-status-field]').forEach(function (el) {
                var active = !!item[el.dataset.statusField];
                el.className = 'dir-status ' + (active ? 'is-active' : 'is-inactive');
            });
            modal.querySelectorAll('[data-field-href]').forEach(function (el) {
                el.href = item[el.dataset.fieldHref] || '#';
            });
            modal.querySelectorAll('[data-field-progress]').forEach(function (el) {
                el.style.setProperty('--dir-p', (Number(item[el.dataset.fieldProgress]) || 0) + '%');
                el.style.animation = 'none';
                void el.offsetWidth; // restart the fill animation each time
                el.style.animation = '';
            });
            modal.querySelectorAll('[data-field-list]').forEach(function (list) {
                var values = item[list.dataset.fieldList] || [];
                list.replaceChildren();
                values.forEach(function (text) { var li = document.createElement('li'); li.textContent = text; list.append(li); });
                list.hidden = values.length === 0;
                var fallback = list.nextElementSibling;
                if (fallback && fallback.hasAttribute('data-field-list-empty')) fallback.hidden = values.length > 0;
            });
            if (window.bootstrap) bootstrap.Modal.getOrCreateInstance(modal).show();
        });
    }

    function init() {
        document.querySelectorAll('[data-dir]').forEach(function (root) {
            if (root.dataset.dirReady) return;
            root.dataset.dirReady = 'true';
            setupFilters(root);
            setupDetails(root);
        });
    }

    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
    else init();
}());
