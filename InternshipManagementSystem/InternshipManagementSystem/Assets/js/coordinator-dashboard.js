/* Coordinator dashboard: record counts and drill-downs share the same read model. */
(function () {
    'use strict';
    const root = document.querySelector('[data-coordination-desk]');
    const payload = root && root.querySelector('[data-coordination-model]');
    if (!payload) return;
    const data = JSON.parse(payload.textContent), model = data.Model;
    const t = function () { return window.uimsT.apply(null, arguments); };
    const number = new Intl.NumberFormat(window.uimsLang === 'ar' ? 'ar-JO-u-nu-latn' : 'en');
    const modal = root.querySelector('#deskRecords');
    let selectedRecords = [], recordPage = 0, opener = null;
    const recordSearch = modal.querySelector('[data-desk-record-search]');
    const pageSize = 8;
    function safeUrl(value) {
        if (!value) return '#';
        const raw = value.startsWith('~/') ? data.AppRoot + value.slice(2) : value;
        try { const url = new URL(raw, location.href); return url.origin === location.origin && /^https?:$/.test(url.protocol) ? url.href : '#'; }
        catch (_) { return '#'; }
    }
    function pageRecords() {
        const list = modal.querySelector('.desk-record-list');
        const query = recordSearch.value.trim().toLocaleLowerCase();
        const records = query ? selectedRecords.filter(record =>
            ((record.Title || '') + ' ' + (record.Detail || '')).toLocaleLowerCase().includes(query)) : selectedRecords;
        const pageCount = Math.max(1, Math.ceil(records.length / pageSize));
        recordPage = Math.min(recordPage, pageCount - 1);
        list.replaceChildren();
        records.slice(recordPage * pageSize, (recordPage + 1) * pageSize).forEach((record, index) => {
            const item = document.createElement('li'), numberBadge = document.createElement('span'), text = document.createElement('div'), title = document.createElement('strong'), detail = document.createElement('small'), link = document.createElement('a'), icon = document.createElement('i');
            numberBadge.className = 'desk-record-number';
            numberBadge.textContent = number.format(recordPage * pageSize + index + 1);
            numberBadge.setAttribute('aria-hidden', 'true');
            text.className = 'desk-record-item-text';
            title.textContent = record.Title; detail.textContent = record.Detail || '';
            link.textContent = t('ChartOpenRecord'); link.href = safeUrl(record.Url);
            link.setAttribute('aria-label', t('ChartOpenRecord') + ': ' + record.Title);
            icon.className = 'bi bi-arrow-up-right'; icon.setAttribute('aria-hidden', 'true');
            link.append(icon);
            text.append(title, detail); item.append(numberBadge, text, link);
            item.style.setProperty('--record-index', index);
            list.append(item);
        });
        modal.querySelector('[data-desk-no-records]').hidden = selectedRecords.length > 0;
        modal.querySelector('[data-desk-no-search-results]').hidden = !selectedRecords.length || records.length > 0;
        modal.querySelector('.desk-record-toolbar').hidden = selectedRecords.length === 0;
        modal.querySelector('[data-desk-record-count]').textContent = number.format(records.length) + ' ' + modal.dataset.recordCountLabel;
        modal.querySelector('[data-desk-page="-1"]').disabled = recordPage === 0;
        modal.querySelector('[data-desk-page="1"]').disabled = recordPage >= pageCount - 1;
        modal.querySelector('[data-desk-page-label]').textContent = records.length
            ? t('ChartRecordRange', recordPage * pageSize + 1, Math.min((recordPage + 1) * pageSize, records.length), records.length) : t('ChartZeroRecords');
        modal.querySelector('.desk-record-pagination').hidden = records.length <= pageSize;
    }
    function showRecords(title, records, trigger, context) {
        opener = trigger; selectedRecords = records || []; recordPage = 0;
        recordSearch.value = '';
        modal.querySelector('.modal-title').textContent = title;
        modal.querySelector('#desk-record-context').textContent = context || '';
        pageRecords();
        bootstrap.Modal.getOrCreateInstance(modal).show(opener);
    }
    modal.addEventListener('hidden.bs.modal', () => {
        if (opener && opener.isConnected) opener.focus({ preventScroll: true });
    });
    recordSearch.addEventListener('input', () => { recordPage = 0; pageRecords(); });
    function monthRecords(index) {
        const now = new Date(model.Now), from = Date.UTC(now.getUTCFullYear(), now.getUTCMonth() - 11 + index, 1), until = Date.UTC(now.getUTCFullYear(), now.getUTCMonth() - 10 + index, 1);
        return model.Events.filter(event => event.Date >= from && event.Date < until && event.Date <= model.Now).map(event => event.Record);
    }
    // Bootstrap/shared UI may move the modal outside the dashboard container.
    modal.addEventListener('click', event => {
        const button = event.target.closest('[data-desk-page]');
        if (!button || button.disabled) return;
        recordPage += Number(button.dataset.deskPage);
        pageRecords();
    });
    root.addEventListener('click', event => {
        const button = event.target.closest('button');
        if (!button || button.disabled) return;
        if (button.hasAttribute('data-desk-kpi')) {
            const kpi = model.Kpis[Number(button.dataset.deskKpi)];
            const records = kpi.Flow ? data.Months.flatMap((_, index) => monthRecords(index)) : kpi.Records;
            showRecords(kpi.Label, records, button, kpi.Context);
        } else if (button.hasAttribute('data-desk-major')) {
            const category = model.Bars[Number(button.dataset.deskMajor)]; showRecords(category.Label, category.Records, button);
        } else if (button.hasAttribute('data-desk-followup')) {
            const item = data.FollowUps[Number(button.dataset.deskFollowup)]; showRecords(item.Label, item.Records, button, item.Context);
        } else if (button.hasAttribute('data-desk-stage')) {
            const category = model.Breakdown[Number(button.dataset.deskStage)]; showRecords(category.Label, category.Records, button);
        } else if (button.hasAttribute('data-desk-month')) {
            const index = Number(button.dataset.deskMonth); showRecords(data.Months[index].Label, monthRecords(index), button);
        }
    });
    const canvas = root.querySelector('[data-desk-chart="approvals"]');
    if (window.Chart && canvas) {
        const reduced = matchMedia('(prefers-reduced-motion: reduce)');
        function colors() {
            const style = getComputedStyle(root);
            return { muted: style.getPropertyValue('--desk-muted').trim(), line: style.getPropertyValue('--desk-line').trim(), blue: style.getPropertyValue('--desk-action').trim() };
        }
        const c = colors();
        const chart = new Chart(canvas, {
            type: 'bar',
            data: { labels: data.Months.map(month => month.ChartLabel), datasets: [{ label: model.TrendUnit, data: data.Months.map(month => month.Value), backgroundColor: c.blue, borderRadius: 4, maxBarThickness: 36 }] },
            options: {
                responsive: true, maintainAspectRatio: false, animation: reduced.matches ? false : { duration: 250 },
                plugins: { legend: { display: false }, tooltip: { displayColors: false, rtl: window.uimsLang === 'ar' } },
                scales: {
                    y: { beginAtZero: true, suggestedMax: 4, border: { display: false }, grid: { color: c.line }, ticks: { color: c.muted, precision: 0, maxTicksLimit: 5 } },
                    x: { border: { color: c.line }, grid: { display: false }, ticks: { color: c.muted, maxRotation: 0, minRotation: 0, autoSkip: false,
                        callback: function (value, index) { return canvas.clientWidth < 500 && index % 3 !== 0 && index !== 11 ? '' : this.getLabelForValue(value); } } }
                },
                onHover(event, bars) { canvas.style.cursor = bars.length ? 'pointer' : 'default'; },
                onClick(event, bars) {
                    if (!bars.length) return;
                    const index = bars[0].index;
                    showRecords(data.Months[index].Label, monthRecords(index), root.querySelector('.desk-history-details summary'));
                }
            }
        });
        new MutationObserver(() => {
            const next = colors();
            chart.options.scales.x.ticks.color = next.muted; chart.options.scales.y.ticks.color = next.muted;
            chart.options.scales.y.grid.color = next.line; chart.options.scales.x.border.color = next.line;
            chart.data.datasets[0].backgroundColor = next.blue; chart.update('none');
        }).observe(document.documentElement, { attributes: true, attributeFilter: ['data-theme'] });
    } else if (canvas) {
        canvas.parentElement.hidden = true;
        root.querySelector('.desk-history-details').open = true;
    }
    root.dataset.dashboardReady = 'true';
}());
