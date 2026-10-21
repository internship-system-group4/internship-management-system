/* ===========================================================================
   UIMS - Group 4   |   shared helpers
   Keep page-specific scripts in that page's own "scripts" content block.
   =========================================================================== */
(function () {
    "use strict";

    /* Show/hide password toggle - card A01 asks for this on the login page.
       Usage:  <button type="button" data-uims-toggle="#txtPassword">Show</button> */
    document.addEventListener("click", function (event) {
        var trigger = event.target.closest("[data-uims-toggle]");
        if (!trigger) return;

        var field = document.querySelector(trigger.getAttribute("data-uims-toggle"));
        if (!field) return;

        var hidden = field.getAttribute("type") === "password";
        field.setAttribute("type", hidden ? "text" : "password");
        trigger.textContent = hidden ? "Hide" : "Show";
    });

    /* Ask before an irreversible action:
       <asp:Button ... data-uims-confirm="Delete this opportunity?" /> */
    document.addEventListener("click", function (event) {
        var trigger = event.target.closest("[data-uims-confirm]");
        if (!trigger) return;
        if (!window.confirm(trigger.getAttribute("data-uims-confirm"))) {
            event.preventDefault();
        }
    });
})();
