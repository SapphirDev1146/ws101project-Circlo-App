/* ==========================================================================
   Circlo — success message after an action (DESIGN.md 9.2)

   A page that finishes an action sends the user to a list with ?done=WORD,
   for example my-items.html?done=posted. This script shows the alert with
   data-flash="WORD", then removes ?done from the address so a refresh
   doesn't show it again.

     <div class="alert alert--success" role="status" data-flash="posted" hidden>…</div>

   FRONT-END DEMO: the backend can show the same alerts itself (remove "hidden")
   and drop this script.
   ========================================================================== */
(function () {
  "use strict";

  var params = new URLSearchParams(window.location.search);
  var done = params.get("done");
  if (!done) return;

  var alert = document.querySelector('[data-flash="' + CSS.escape(done) + '"]');
  if (alert) alert.hidden = false;

  params.delete("done");
  var rest = params.toString();
  window.history.replaceState(null, "", window.location.pathname + (rest ? "?" + rest : "") + window.location.hash);
})();
