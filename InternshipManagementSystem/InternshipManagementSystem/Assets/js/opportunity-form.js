/* Add / Edit Opportunity: the same rules as Services/OpportunityFormRules.cs,
   checked while the supervisor types. Every problem is shown under its own field. */
(function () {
    'use strict';

    function init(box) {
        var form = box.closest('form');
        if (!form) return;
        var prefix = box.getAttribute('data-prefix');
        var messages = JSON.parse(box.getAttribute('data-messages') || '{}');
        var today = box.getAttribute('data-today');
        var filled = Number(box.getAttribute('data-filled') || 0);
        var pastRule = box.getAttribute('data-past-rule'); // "always" (new) or "changed" (edit)
        var touched = {};
        var showAll = false;

        function field(name) { return form.querySelector('[name="' + prefix + name + '"]'); }
        function value(name) { var el = field(name); return el ? el.value.trim() : ''; }
        function majors() { return form.querySelectorAll('input[name="' + prefix + 'Majors"]:checked').length; }
        function fill(text, a, b) { return String(text || '').replace('{0}', a).replace('{1}', b); }
        // Training always lasts 3 months: the end date is start + 3 months.
        function endFor(iso) {
            var p = iso.split('-'), d = new Date(Number(p[0]), Number(p[1]) - 1 + 3, Number(p[2]));
            if (d.getDate() !== Number(p[2])) d.setDate(0); // 30 Nov + 3 months = 28/29 Feb, like .NET AddMonths
            var m = d.getMonth() + 1, day = d.getDate();
            return d.getFullYear() + '-' + (m < 10 ? '0' : '') + m + '-' + (day < 10 ? '0' : '') + day;
        }

        function errors(complete) {
            var e = {};
            var title = value('Title');
            if (title.length < 3) e.Title = messages.TitleRequired;
            if (complete) {
                if (!value('Department')) e.Department = messages.DepartmentRequired;
                if (value('Location').length < 2) e.Location = messages.LocationRequired;
                if (!majors()) e.Majors = messages.MajorsRequired;
                if (value('Description').length < 20) e.Description = messages.DescriptionRequired;
                if (value('Requirements').length < 2) e.Requirements = messages.RequirementsRequired;
            }
            var seats = value('Seats');
            if (complete || seats) {
                var n = Number(seats);
                if (!/^\d+$/.test(seats) || n < 1 || n > 500) e.Seats = messages.SeatsInvalid;
                else if (n < filled) e.Seats = fill(messages.SeatsBelowFilled, filled);
            }
            var deadline = value('Deadline'), start = value('Start');
            var deadlineField = field('Deadline');
            var checkPast = pastRule === 'always' || (deadlineField && deadline !== deadlineField.defaultValue);
            if (complete && !deadline) e.Deadline = messages.DeadlineRequired;
            else if (deadline && checkPast && deadline < today) e.Deadline = messages.DeadlinePast;
            if (complete && !start) e.Start = messages.StartRequired;
            else if (start && deadline && start < deadline) e.Start = fill(messages.StartBeforeDeadline, deadline);
            return e;
        }

        function show(list) {
            var summary = box.querySelector('[data-summary]');
            if (summary && Object.keys(list).length === 0) summary.hidden = true;
            box.querySelectorAll('[data-error-for]').forEach(function (slot) {
                var name = slot.getAttribute('data-error-for');
                var message = (showAll || touched[name]) ? list[name] : '';
                slot.textContent = message || '';
                slot.hidden = !message;
                var wrap = slot.closest('[data-field]');
                if (wrap) wrap.classList.toggle('is-invalid', !!message);
                var input = field(name);
                if (input && input.setAttribute) input.setAttribute('aria-invalid', message ? 'true' : 'false');
            });
        }

        function refreshDates() {
            var deadline = value('Deadline'), start = value('Start');
            var d = field('Deadline'), s = field('Start');
            if (d && pastRule === 'always') d.min = today;
            if (s) s.min = deadline || (pastRule === 'always' ? today : '');
            var end = start ? endFor(start) : '';
            var endBox = box.querySelector('[data-end-date]');
            if (endBox) endBox.textContent = end || '—';
            var out = box.querySelector('[data-duration]');
            if (out) out.textContent = end ? fill(messages.Duration, start, end) : out.getAttribute('data-empty');
        }

        function nameOf(target) {
            var n = target.name || '';
            return n.indexOf(prefix) === 0 ? n.substring(prefix.length) : '';
        }

        form.addEventListener('input', function (event) {
            var name = nameOf(event.target);
            if (!name) return;
            if (name === 'Deadline' || name === 'Start') refreshDates();
            if (touched[name] || showAll) show(errors(showAll));
        });
        form.addEventListener('change', function (event) {
            var name = nameOf(event.target);
            if (!name) return;
            touched[name] = true;
            // A date change can fix or break the next date, so re-check the chain.
            if (name === 'Deadline' && value('Start')) touched.Start = true;
            refreshDates();
            show(errors(showAll));
        });
        form.addEventListener('focusout', function (event) {
            var name = nameOf(event.target);
            if (!name || !event.target.value) return;
            touched[name] = true;
            show(errors(showAll));
        });

        // Runs before the shared loading-button script, so a blocked submit never shows "Saving...".
        form.addEventListener('submit', function (event) {
            var button = event.submitter;
            if (!button || !box.contains(button) || button.getAttribute('data-opp-submit') === null) return;
            var complete = button.getAttribute('data-opp-submit') === 'complete';
            var list = errors(complete);
            var summary = box.querySelector('[data-summary]');
            if (Object.keys(list).length === 0) { if (summary) summary.hidden = true; return; }
            event.preventDefault();
            event.stopImmediatePropagation();
            showAll = true;
            show(list);
            if (summary) {
                summary.textContent = messages.FixErrors;
                summary.hidden = false;
            }
            var first = box.querySelector('[data-field].is-invalid');
            if (first) {
                first.scrollIntoView({ behavior: 'smooth', block: 'center' });
                var input = first.querySelector('input:not([type=checkbox]),textarea,select') || first.querySelector('input');
                if (input) setTimeout(function () { input.focus({ preventScroll: true }); }, 250);
            }
        }, true);

        refreshDates();
        // Errors returned by the server are already on the page; keep them visible.
        if (box.querySelector('[data-field].is-invalid')) { showAll = true; }
    }

    function start() { document.querySelectorAll('[data-opp-form]').forEach(init); }
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start);
    else start();
})();
