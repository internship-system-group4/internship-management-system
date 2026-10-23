(function () {
    'use strict';
    var root = document.querySelector('.company-applications');
    if (!root) return;
    var pane = root.querySelector('.review-detail-pane');
    var workspace = root.querySelector('.review-workspace');
    var content = pane.querySelector('.review-pane-content');
    var actions = pane.querySelector('.review-pane-actions');
    var title = pane.querySelector('#reviewPaneTitle');
    var placeholder = root.querySelector('.review-pane-placeholder');
    var search = root.querySelector('#applicationReviewSearch');
    var filters = root.querySelectorAll('[name="review-status-filter"]');
    var note = root.querySelector('.review-results-note');
    var noMatches = root.querySelector('.review-filter-empty');
    var selection = root.querySelector('[name="reviewSelection"]');
    var mobile = window.matchMedia('(max-width:1100px), (max-height:650px)');
    var active = null, visible = [], inertNodes = [], savedOverflow = null;
    var applied = { query: '', status: 'all' };
    function normalize(value) { return value.normalize('NFKD').replace(/[\u0300-\u036f\u064b-\u065f\u0670]/g, '').toLocaleLowerCase().trim(); }
    var records = Array.from(root.querySelectorAll('[data-application-id]')).map(function (card) {
        return { card: card, id: card.dataset.applicationId, status: card.dataset.applicationStatus,
            button: card.querySelector('.review-details-toggle'), details: card.querySelector('details'),
            decision: card.querySelector('.review-decision'), reject: card.querySelector('.review-reject-fields'), outcome: card.querySelector('.review-outcome'),
            reason: card.querySelector('textarea'), name: card.querySelector('.review-applicant h3').textContent,
            opportunity: card.querySelector('.review-applied-for strong').textContent,
            text: normalize(card.querySelector('.review-applicant').textContent) };
    });
    function mayLeave() { return !active || !active.reason || !active.reason.value.trim() || window.confirm(root.dataset.draftWarning); }
    function sizeDesk() {
        var top = Math.max(16, workspace.getBoundingClientRect().top);
        root.style.setProperty('--review-desk-height', Math.max(400, window.innerHeight - top - 24) + 'px');
    }
    function releaseDialog() {
        inertNodes.forEach(function (item) { item.node.inert = item.inert; });
        inertNodes = [];
        if (savedOverflow !== null) { document.body.style.overflow = savedOverflow; savedOverflow = null; }
        pane.setAttribute('role', 'region'); pane.removeAttribute('aria-modal');
    }
    function syncDialog() {
        releaseDialog();
        if (!active || !mobile.matches) return;
        pane.setAttribute('role', 'dialog'); pane.setAttribute('aria-modal', 'true');
        var branch = pane;
        while (branch.parentElement && branch !== document.body) {
            Array.from(branch.parentElement.children).forEach(function (node) {
                if (node !== branch && !/^(SCRIPT|STYLE|LINK)$/.test(node.tagName)) {
                    inertNodes.push({ node: node, inert: node.inert }); node.inert = true;
                }
            });
            branch = branch.parentElement;
        }
        savedOverflow = document.body.style.overflow;
        document.body.style.overflow = 'hidden';
        if (!pane.contains(document.activeElement)) title.focus({ preventScroll: true });
    }
    function updateNavigation() {
        var index = active ? visible.indexOf(active) : -1;
        pane.querySelector('.review-pane-position').textContent = index < 0 ? '' : root.dataset.positionTemplate.replace('{0}', index + 1).replace('{1}', visible.length);
        pane.querySelector('[data-review-step="-1"]').disabled = index <= 0;
        pane.querySelector('[data-review-step="1"]').disabled = index < 0 || index >= visible.length - 1;
    }
    function deselect() {
        if (active) {
            active.card.classList.remove('is-selected'); active.button.setAttribute('aria-expanded', 'false');
            active.details.hidden = true; active.details.open = false;
            if (active.decision) active.decision.hidden = true;
        }
        active = null; selection.value = ''; pane.hidden = true; actions.hidden = true;
        placeholder.hidden = records.length === 0; releaseDialog();
    }
    function select(record, focus) {
        if (!record || record.card.hidden) return false;
        if (active !== record) {
            if (!mayLeave()) return false;
            deselect(); active = record;
            active.card.classList.add('is-selected'); active.button.setAttribute('aria-expanded', 'true');
            active.details.open = true; active.details.hidden = false;
            if (active.decision) active.decision.hidden = false;
            selection.value = active.id; title.textContent = active.name; title.title = active.name;
            pane.querySelector('.review-pane-opportunity').textContent = active.opportunity;
            pane.hidden = false; placeholder.hidden = true; actions.hidden = !active.decision;
            content.scrollTop = 0;
        }
        sizeDesk(); updateNavigation(); syncDialog();
        if (focus && !mobile.matches) active.card.scrollIntoView({ block: 'nearest', inline: 'nearest' });
        if (focus) title.focus({ preventScroll: true });
        return true;
    }
    records.forEach(function (record) {
        // Move the actual controls, never cloned inputs or a second server form.
        record.details.querySelector('summary').hidden = true;
        record.details.hidden = true;
        if (record.outcome) record.details.insertBefore(record.outcome, record.details.firstChild);
        content.appendChild(record.details);
        if (record.reject) record.details.appendChild(record.reject);
        if (record.decision) { actions.appendChild(record.decision); record.decision.hidden = true; }
        record.button.hidden = false;
        record.button.addEventListener('click', function () { select(record, true); });
        var previewButton = record.details.querySelector('.review-preview-toggle');
        if (previewButton) {
            previewButton.hidden = false;
            previewButton.addEventListener('click', function () {
                var preview = record.details.querySelector('.review-cv-preview'), frame = preview.querySelector('iframe');
                preview.hidden = !preview.hidden;
                previewButton.setAttribute('aria-expanded', preview.hidden ? 'false' : 'true');
                previewButton.textContent = preview.hidden ? previewButton.dataset.showLabel : previewButton.dataset.hideLabel;
                if (!preview.hidden && !frame.hasAttribute('src')) frame.src = frame.dataset.src;
            });
        }
        if (record.reason) record.reason.maxLength = 2000;
        if (record.decision) {
            var toggle = record.decision.querySelector('.review-reject-toggle');
            function setReject(open) {
                var panel = document.getElementById(toggle.getAttribute('aria-controls'));
                panel.hidden = !open; toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
                toggle.classList.toggle('is-active', open);
                record.decision.querySelector('.review-accept-button').disabled = open;
                if (open) record.reason.focus();
            }
            toggle.addEventListener('click', function () { setReject(toggle.getAttribute('aria-expanded') !== 'true'); });
            record.reject.querySelector('[data-reject-cancel]').addEventListener('click', function () { setReject(false); toggle.focus(); });
        }
    });
    function applyFilters() {
        var selected = root.querySelector('[name="review-status-filter"]:checked');
        var status = selected ? selected.value : 'all';
        var terms = normalize(search.value).split(/\s+/).filter(Boolean);
        var next = records.filter(function (record) { return (status === 'all' || record.status === status) && terms.every(function (term) { return record.text.indexOf(term) !== -1; }); });
        if (active && next.indexOf(active) < 0 && !mayLeave()) {
            search.value = applied.query;
            root.querySelector('[name="review-status-filter"][value="' + applied.status + '"]').checked = true;
            return;
        }
        if (active && next.indexOf(active) < 0) deselect();
        visible = next;
        records.forEach(function (record) { record.card.hidden = visible.indexOf(record) < 0; });
        note.textContent = note.dataset.countTemplate.replace('{0}', visible.length).replace('{1}', records.length);
        note.hidden = records.length === 0 || (status === 'all' && terms.length === 0);
        noMatches.hidden = records.length === 0 || visible.length !== 0;
        applied = { query: search.value, status: status };
        updateNavigation(); sizeDesk();
    }
    root.classList.add('review-master-detail');
    placeholder.hidden = records.length === 0;
    root.querySelectorAll('[data-filter-count]').forEach(function (count) {
        count.textContent = count.dataset.filterCount === 'all' ? records.length : records.filter(function (r) { return r.status === count.dataset.filterCount; }).length;
    });
    root.querySelector('.review-toolbar').hidden = records.length === 0;
    search.value = root.dataset.initialSearch || '';
    var initialFilter = Array.from(filters).find(function (filter) { return filter.value === root.dataset.initialFilter; });
    if (initialFilter) initialFilter.checked = true;
    search.addEventListener('input', applyFilters);
    search.addEventListener('keydown', function (event) { if (event.key === 'Enter') event.preventDefault(); });
    filters.forEach(function (filter) { filter.addEventListener('change', applyFilters); });
    root.querySelector('[data-clear-review-filters]').addEventListener('click', function () { search.value = ''; filters[0].checked = true; applyFilters(); search.focus(); });
    pane.querySelector('.review-pane-close').addEventListener('click', function () {
        if (!mayLeave()) return;
        var opener = active && active.button; deselect();
        if (opener && opener.getClientRects().length) opener.focus(); else search.focus();
    });
    pane.querySelectorAll('[data-review-step]').forEach(function (button) {
        button.addEventListener('click', function () { select(visible[visible.indexOf(active) + Number(button.dataset.reviewStep)], true); });
    });
    pane.addEventListener('keydown', function (event) {
        if (event.key === 'Escape') { event.preventDefault(); event.stopPropagation(); pane.querySelector('.review-pane-close').click(); }
        if (event.key !== 'Tab' || !mobile.matches) return;
        var focusable = Array.from(pane.querySelectorAll('button:not(:disabled),a[href],input:not(:disabled),textarea:not(:disabled),iframe,[tabindex="0"]')).filter(function (el) { return el.getClientRects().length && !el.closest('[hidden]'); });
        var first = focusable[0], last = focusable[focusable.length - 1];
        if (event.shiftKey && (document.activeElement === first || document.activeElement === title)) { event.preventDefault(); last.focus(); }
        else if (!event.shiftKey && document.activeElement === last) { event.preventDefault(); first.focus(); }
    });
    window.addEventListener('resize', function () { sizeDesk(); syncDialog(); });
    window.addEventListener('pageshow', applyFilters);
    if (document.fonts) document.fonts.ready.then(sizeDesk);
    applyFilters();
    var invalid = records.find(function (record) { return record.reason && record.reason.hasAttribute('data-rejection-error'); });
    var initial = invalid || visible.find(function (record) { return record.id === root.dataset.initialSelection; });
    if (!initial && !mobile.matches) initial = visible[0];
    if (initial) select(initial, false);
    if (invalid) { invalid.decision.querySelector('.review-reject-toggle').click(); }
}());
