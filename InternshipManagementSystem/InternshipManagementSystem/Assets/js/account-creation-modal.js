(function () {
    function initialize() {
        document.querySelectorAll('.creation-modal').forEach(function (modal) {
            if (modal.dataset.initialized || !window.bootstrap) return;
            modal.dataset.initialized = 'true';
            modal.addEventListener('shown.bs.modal', function () {
                var field = modal.querySelector('input:not([type="hidden"]):not([type="submit"]), select');
                if (field) field.focus();
            });
            modal.addEventListener('hidden.bs.modal', function () {
                modal.querySelectorAll('input:not([type="hidden"]):not([type="submit"]):not([type="button"])').forEach(function (field) {
                    field.value = field.getAttribute('data-reset-value') || '';
                });
                modal.querySelectorAll('select').forEach(function (field) { field.selectedIndex = 0; });
                modal.querySelectorAll('[role="alert"]').forEach(function (message) {
                    message.classList.remove('d-block');
                    message.hidden = true;
                });
            });
            if (modal.dataset.openOnLoad === 'true') bootstrap.Modal.getOrCreateInstance(modal).show();
        });
    }
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', initialize);
    else initialize();
}());
