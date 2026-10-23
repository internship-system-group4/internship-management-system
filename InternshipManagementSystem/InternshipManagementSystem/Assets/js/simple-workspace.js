/* Filters already-authorized server records. No requests, cloned data, or persisted input. */
(function () {
    'use strict';
    document.querySelectorAll('[data-simple-workspace]').forEach(function (root) {
        var box = root.querySelector('[data-workspace-search]');
        var input = box.querySelector('input');
        var clear = box.querySelector('button');
        var output = box.querySelector('[data-search-count]');
        var groups = Array.from(root.querySelectorAll('[data-search-group]'));
        function normalize(value) { return value.normalize('NFKD').replace(/[\u0300-\u036f\u064b-\u065f\u0670]/g, '').toLocaleLowerCase().trim(); }
        function filter() {
            var query = normalize(input.value), total = 0, shown = 0;
            groups.forEach(function (group) {
                var items = Array.from(group.querySelectorAll('[data-search-item]')), matched = 0;
                items.forEach(function (item) {
                    item.hidden = !!query && normalize(item.textContent).indexOf(query) === -1;
                    if (!item.hidden) matched++;
                });
                group.querySelector('[data-search-empty]').hidden = !query || items.length === 0 || matched > 0;
                total += items.length; shown += matched;
            });
            clear.hidden = !input.value; output.hidden = !query;
            output.textContent = output.dataset.template.replace('{0}', shown).replace('{1}', total);
        }
        box.hidden = false;
        input.addEventListener('input', filter);
        input.addEventListener('keydown', function (event) { if (event.key === 'Enter') event.preventDefault(); });
        clear.addEventListener('click', function () { input.value = ''; filter(); input.focus(); });
        window.addEventListener('pageshow', filter);
        filter();
    });
}());
