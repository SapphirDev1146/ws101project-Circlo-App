/* ==========================================================================
   Circlo — confirm and quick-edit dialogs (DESIGN.md 9.2, 11.1)

   A row button opens a <dialog> and tells it which row it is about:

     <button type="button" class="link link--danger" aria-haspopup="dialog"
             data-dialog="deactivate-dialog" data-id="2" data-name="Ana Cruz"
             data-value="member">Deactivate</button>

     <dialog class="dialog" id="deactivate-dialog" aria-labelledby="…">
       … <span data-dialog-name></span> …            ← gets data-name
       <input type="hidden" name="id">              ← gets data-id
       <input data-dialog-value> / <select data-dialog-value>  ← gets data-value
       <button type="button" data-dialog-close>Cancel</button>
     </dialog>

   showModal() keeps focus inside the dialog and Esc closes it. When it closes,
   focus goes back to the button that opened it.
   ========================================================================== */
(function () {
  "use strict";

  Array.prototype.forEach.call(document.querySelectorAll("[data-dialog]"), function (button) {
    button.addEventListener("click", function () {
      var dialog = document.getElementById(button.getAttribute("data-dialog"));
      if (!dialog || typeof dialog.showModal !== "function") return;

      var name = button.getAttribute("data-name") || "";
      var value = button.getAttribute("data-value");

      Array.prototype.forEach.call(dialog.querySelectorAll("[data-dialog-name]"), function (el) {
        el.textContent = name;
      });
      Array.prototype.forEach.call(dialog.querySelectorAll('input[name="id"]'), function (input) {
        input.value = button.getAttribute("data-id") || "";
      });
      Array.prototype.forEach.call(dialog.querySelectorAll("[data-dialog-value]"), function (field) {
        field.value = value !== null ? value : name;
        // Clear an error left from the last time the dialog was open
        field.removeAttribute("aria-invalid");
        var wrapper = field.closest(".field");
        if (wrapper) wrapper.classList.remove("field--error");
        var error = field.id && document.getElementById(field.id + "-error");
        if (error) error.hidden = true;
      });

      dialog.openedBy = button;
      dialog.showModal();
    });
  });

  Array.prototype.forEach.call(document.querySelectorAll("dialog"), function (dialog) {
    Array.prototype.forEach.call(dialog.querySelectorAll("[data-dialog-close]"), function (close) {
      close.addEventListener("click", function () {
        dialog.close();
      });
    });
    dialog.addEventListener("close", function () {
      if (dialog.openedBy) dialog.openedBy.focus();
    });
  });
})();
