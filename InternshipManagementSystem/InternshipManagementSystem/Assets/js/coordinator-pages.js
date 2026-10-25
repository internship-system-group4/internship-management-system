/* Coordinator pages (see Assets/css/coordinator-pages.css).
   1. Status toggles: a row's switch opens its page's confirm pop-up, filled with
      the person's name and the right action. The pop-up's button posts back.
      Markup: <button data-status-toggle="modalId" data-id=".." data-name=".." data-active="true|false">
              <div id="modalId" data-hidden-id="clientId of the HiddenField"
                   data-title-on/off data-text-on/off data-btn-on/off> ... [data-confirm-go] button
   2. Tabs on the placement progress page (role="tablist" with [data-pdx-tab]). */
(function () {
    'use strict';

    function showModal(modal) {
        if (window.bootstrap && window.bootstrap.Modal) window.bootstrap.Modal.getOrCreateInstance(modal).show();
    }

    document.addEventListener('click', function (event) {
        var button = event.target.closest ? event.target.closest('[data-status-toggle]') : null;
        if (!button) return;
        event.preventDefault();
        var modal = document.getElementById(button.getAttribute('data-status-toggle'));
        if (!modal) return;
        var isOn = button.getAttribute('data-active') === 'true';   // on now, so this turns it off
        var name = button.getAttribute('data-name') || '';
        var hidden = document.getElementById(modal.getAttribute('data-hidden-id'));
        if (hidden) hidden.value = button.getAttribute('data-id') || '';
        var pick = function (key) { return modal.getAttribute('data-' + key + (isOn ? '-off' : '-on')) || ''; };
        var title = modal.querySelector('[data-confirm-title]');
        var text = modal.querySelector('[data-confirm-text]');
        var icon = modal.querySelector('[data-confirm-icon]');
        var go = modal.querySelector('[data-confirm-go]');
        if (title) title.textContent = pick('title').replace('{0}', name);
        if (text) text.textContent = pick('text');
        if (icon) icon.className = 'dir-result-icon ' + (isOn ? 'is-danger' : 'is-success');
        if (go) {
            go.value = pick('btn');
            go.classList.remove('btn-danger', 'btn-success');
            go.classList.add(isOn ? 'btn-danger' : 'btn-success');
        }
        showModal(modal);
    });

    // ---- tabs
    function initTabs() {
        document.querySelectorAll('[data-pdx-tabs]').forEach(function (list) {
            var tabs = Array.prototype.slice.call(list.querySelectorAll('[data-pdx-tab]'));
            function select(tab, focus, keepUrl) {
                tabs.forEach(function (t) {
                    var on = t === tab;
                    t.setAttribute('aria-selected', on ? 'true' : 'false');
                    t.tabIndex = on ? 0 : -1;
                    var panel = document.getElementById(t.getAttribute('aria-controls'));
                    if (panel) panel.hidden = !on;
                });
                if (focus) tab.focus();
                if (!keepUrl) try { history.replaceState(null, '', '#' + tab.getAttribute('data-pdx-tab')); } catch (e) { }
            }
            list.addEventListener('click', function (event) {
                var tab = event.target.closest('[data-pdx-tab]');
                if (tab) select(tab, false);
            });
            list.addEventListener('keydown', function (event) {
                var i = tabs.indexOf(document.activeElement);
                if (i < 0) return;
                var rtl = document.documentElement.dir === 'rtl';
                var next = { ArrowRight: rtl ? -1 : 1, ArrowLeft: rtl ? 1 : -1, Home: -i, End: tabs.length - 1 - i }[event.key];
                if (next === undefined) return;
                event.preventDefault();
                select(tabs[(i + next + tabs.length) % tabs.length], true);
            });
            var wanted = (location.hash || '').slice(1);
            var start = tabs.filter(function (t) { return t.getAttribute('data-pdx-tab') === wanted; })[0] || tabs[0];
            if (start) select(start, false, true);
        });
    }
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', initTabs);
    else initTabs();
}());
