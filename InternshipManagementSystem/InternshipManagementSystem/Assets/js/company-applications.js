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
    var paneAvatar = pane.querySelector('.review-pane-avatar');
    var paneStatus = pane.querySelector('.review-pane-status');
    var reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    function initials(name) {
        var words = (name || '').trim().split(/\s+/).filter(Boolean);
        if (!words.length) return '?';
        var first = Array.from(words[0])[0], last = words.length > 1 ? Array.from(words[words.length - 1])[0] : '';
        return (first + last).toLocaleUpperCase();
    }
    // Turn "C#, SQL, Git" into separate chips so skills are easy to scan.
    function skillChips(scope) {
        scope.querySelectorAll('.candidate-skill-list').forEach(function (list) {
            if (list.dataset.chips) return;
            list.dataset.chips = '1';
            var parts = list.textContent.split(/[,،;\n•]+/).map(function (part) { return part.trim(); }).filter(Boolean);
            if (parts.length < 1 || list.textContent.trim() === '—') return;
            list.textContent = '';
            parts.forEach(function (part) { var chip = document.createElement('span'); chip.className = 'candidate-chip'; chip.textContent = part; list.appendChild(chip); });
        });
    }
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
    function wirePreview(record) {
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
    }
    function loadDetails(record) {
        var panel = record.details.querySelector('.candidate-panel');
        if (!panel || panel.dataset.detailsLoaded === 'true' || record.loading) return;
        var link = panel.querySelector('[data-load-candidate]');
        var status = panel.querySelector('[data-details-status]');
        if (!link) return;
        record.loading = true; panel.setAttribute('aria-busy', 'true');
        status.textContent = root.dataset.detailsLoading;
        // Same authenticated page and company-scoped repository; only the selected
        // candidate panel is imported. Decision controls and form state stay in place.
        var controller = new AbortController();
        var timeout = window.setTimeout(function () { controller.abort(); }, 15000);
        fetch(link.href, { credentials: 'same-origin', cache: 'no-store', signal: controller.signal })
            .then(function (response) { if (!response.ok || response.redirected) throw new Error('Details unavailable'); return response.text(); })
            .then(function (html) {
                var doc = new DOMParser().parseFromString(html, 'text/html');
                var source = doc.getElementById(record.details.id);
                var loaded = source && source.querySelector('.candidate-panel[data-details-loaded="true"]');
                if (!loaded) throw new Error('Details unavailable');
                panel.replaceChildren.apply(panel, Array.from(loaded.childNodes).map(function (node) { return document.importNode(node, true); }));
                panel.dataset.detailsLoaded = 'true'; wirePreview(record); skillChips(panel);
                if (window.UimsUI && window.UimsUI.refresh) window.UimsUI.refresh();
            })
            .catch(function () { status.textContent = root.dataset.detailsError; })
            .finally(function () { window.clearTimeout(timeout); record.loading = false; panel.removeAttribute('aria-busy'); });
    }
    // ---- decision confirm pop-up (accept / reject) ----------------------------
    // The first click on Accept or Confirm rejection opens the pop-up instead of
    // posting back. "Confirm" clicks the real server button again.
    var dialog = root.querySelector('[data-ar-confirm]');
    var dialogButton = null, dialogOverflow = '';
    if (dialog) document.body.appendChild(dialog);
    function format(template, record) { return template.replace('{0}', record.name.trim()).replace('{1}', record.opportunity.trim()); }
    function openConfirm(button, kind, record) {
        var data = dialog.dataset;
        dialogButton = button;
        dialog.setAttribute('data-kind', kind);
        dialog.querySelectorAll('[data-ar-icon]').forEach(function (icon) { icon.style.display = icon.getAttribute('data-ar-icon') === kind ? '' : 'none'; });
        var accept = kind === 'accept';
        dialog.querySelector('[data-ar-title]').textContent = accept ? data.acceptTitle : data.rejectTitle;
        dialog.querySelector('[data-ar-text]').textContent = format(accept ? data.acceptText : data.rejectText, record);
        dialog.querySelector('[data-ar-avatar]').textContent = initials(record.name);
        dialog.querySelector('[data-ar-name]').textContent = record.name.trim();
        dialog.querySelector('[data-ar-opportunity]').textContent = record.opportunity.trim();
        var points = dialog.querySelector('[data-ar-points]');
        points.textContent = '';
        (accept ? [data.acceptPoint1, data.acceptPoint2] : [data.rejectPoint1, data.rejectPoint2]).forEach(function (line) {
            var item = document.createElement('li'); item.textContent = line; points.appendChild(item);
        });
        var note = dialog.querySelector('[data-ar-note]');
        var typed = !accept && record.reason ? record.reason.value.trim() : '';
        note.hidden = !typed;
        dialog.querySelector('[data-ar-note-text]').textContent = typed;
        dialog.querySelector('[data-ar-go]').textContent = accept ? data.acceptGo : data.rejectGo;
        dialogOverflow = document.body.style.overflow;
        document.body.style.overflow = 'hidden';
        dialog.inert = false;
        dialog.classList.remove('is-leaving');
        dialog.hidden = false;
        document.addEventListener('keydown', onDialogKey, true);
        window.setTimeout(function () { dialog.querySelector('[data-ar-cancel]').focus({ preventScroll: true }); }, reduced ? 0 : 60);
    }
    function closeConfirm(confirmed) {
        var button = dialogButton;
        dialogButton = null;
        document.removeEventListener('keydown', onDialogKey, true);
        dialog.classList.add('is-leaving');
        window.setTimeout(function () {
            dialog.hidden = true;
            dialog.classList.remove('is-leaving');
            document.body.style.overflow = dialogOverflow;
            if (!button) return;
            if (confirmed) { button.dataset.confirmed = '1'; button.click(); }
            else button.focus({ preventScroll: true });
        }, reduced ? 0 : 200);
    }
    function onDialogKey(event) {
        if (event.key === 'Escape') { event.preventDefault(); event.stopPropagation(); closeConfirm(false); return; }
        if (event.key !== 'Tab') return;
        var first = dialog.querySelector('[data-ar-cancel]'), last = dialog.querySelector('[data-ar-go]');
        if (event.shiftKey && document.activeElement === first) { event.preventDefault(); last.focus(); }
        else if (!event.shiftKey && document.activeElement === last) { event.preventDefault(); first.focus(); }
        else if (!dialog.contains(document.activeElement)) { event.preventDefault(); first.focus(); }
    }
    if (dialog) {
        dialog.querySelector('[data-ar-go]').addEventListener('click', function () { closeConfirm(true); });
        dialog.querySelector('[data-ar-cancel]').addEventListener('click', function () { closeConfirm(false); });
        dialog.addEventListener('click', function (event) { if (event.target === dialog) closeConfirm(false); });
    }
    function wireConfirm(record) {
        if (!dialog || !record.decision) return;
        [[record.decision.querySelector('.review-accept-button'), 'accept'],
         [record.reject && record.reject.querySelector('.review-reject-button'), 'reject']].forEach(function (pair) {
            var button = pair[0], kind = pair[1];
            if (!button) return;
            button.addEventListener('click', function (event) {
                if (button.dataset.confirmed === '1') { delete button.dataset.confirmed; return; }
                event.preventDefault(); event.stopImmediatePropagation();
                if (kind === 'reject' && !record.reason.value.trim()) {
                    // A reason is required: point at the empty box instead of opening the pop-up.
                    record.reason.setAttribute('aria-invalid', 'true');
                    record.reason.classList.remove('is-shaking'); void record.reason.offsetWidth; record.reason.classList.add('is-shaking');
                    record.reason.focus();
                    return;
                }
                openConfirm(button, kind, record);
            }, true);
        });
        if (record.reason) record.reason.addEventListener('input', function () { record.reason.removeAttribute('aria-invalid'); });
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
            paneAvatar.textContent = initials(active.name);
            var badge = active.card.querySelector('.application-status');
            paneStatus.className = 'review-pane-status ' + (badge ? badge.className : '');
            paneStatus.textContent = badge ? badge.textContent : '';
            pane.classList.remove('is-entering'); void pane.offsetWidth; pane.classList.add('is-entering');
            pane.hidden = false; placeholder.hidden = true; actions.hidden = !active.decision;
            content.scrollTop = 0;
        }
        loadDetails(record);
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
        // The whole card opens the application, not only the small button.
        record.card.addEventListener('click', function (event) {
            if (event.target.closest('a,button,input,textarea,select,label')) return;
            select(record, true);
        });
        var avatar = record.card.querySelector('.review-avatar');
        if (avatar) avatar.textContent = initials(record.name);
        wirePreview(record); skillChips(record.details);
        wireConfirm(record);
        var loadLink = record.details.querySelector('[data-load-candidate]');
        if (loadLink) loadLink.addEventListener('click', function (event) { event.preventDefault(); loadDetails(record); });
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
    window.requestAnimationFrame(function () { root.classList.add('is-ready'); });
}());
