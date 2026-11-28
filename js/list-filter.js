/* ==========================================================================
   Circlo — list filter (List template, DESIGN.md 6.2 and 7.12)

   Filters a list of cards with the toolbar's search and selects, using the
   same GET parameters the form sends (?q=&type=&urgency=&location=), so a
   filtered page can be bookmarked and the back button works.
   Without JavaScript the form still submits and the full list is shown.

   Markup it expects:
     <form class="toolbar" data-filter-form="ID"> … </form>
     <ul id="ID" data-filter-list>
       <li data-type="flood" data-urgency="high" data-location="zone-1">…</li>
     </ul>
     <div class="empty-state" data-filter-empty="ID" hidden>…</div>
     <p class="visually-hidden" role="status" data-filter-status="ID"></p>

   - The search input (name="q") matches the text of each card, or only the
     parts marked data-filter-text when a card has them (for example the item
     name in a table row, so the words in a status select don't match).
   - Every select matches the <li> data attribute with the same name.
   - Pagination is hidden while filters are on: the sample data fits one page.
     Once data storage is decided (DESIGN.md 12.4 #1), the server filters and
     pages the results instead.
   ========================================================================== */
(function () {
  "use strict";

  function normalize(text) {
    return (text || "").toLowerCase().replace(/\s+/g, " ").trim();
  }

  function setUp(form) {
    var listId = form.getAttribute("data-filter-form");
    var list = document.getElementById(listId);
    if (!list) return;

    var items = Array.prototype.slice.call(list.children);
    var empty = document.querySelector('[data-filter-empty="' + listId + '"]');
    var status = document.querySelector('[data-filter-status="' + listId + '"]');
    var pagination = document.querySelector(".pagination");
    var search = form.querySelector('input[name="q"]');
    var selects = Array.prototype.slice.call(form.querySelectorAll("select[name]"));
    var noun = list.getAttribute("data-filter-noun") || "result";

    // Put the values from the URL back in the form, so users keep what they chose.
    function readUrl() {
      var params = new URLSearchParams(window.location.search);
      if (search) search.value = params.get("q") || "";
      selects.forEach(function (select) {
        var value = params.get(select.name) || "";
        var exists = Array.prototype.some.call(select.options, function (option) {
          return option.value === value;
        });
        select.value = exists ? value : "";
      });
    }

    function apply(announce) {
      var query = search ? normalize(search.value) : "";
      var active = query !== "";
      var shown = 0;

      selects.forEach(function (select) {
        if (select.value) active = true;
      });

      items.forEach(function (item) {
        var marked = item.querySelectorAll("[data-filter-text]");
        var text = marked.length
          ? Array.prototype.map.call(marked, function (el) { return el.textContent; }).join(" ")
          : item.textContent;
        var match = query === "" || normalize(text).indexOf(query) !== -1;
        selects.forEach(function (select) {
          if (select.value && item.getAttribute("data-" + select.name) !== select.value) {
            match = false;
          }
        });
        item.hidden = !match;
        if (match) shown += 1;
      });

      list.hidden = shown === 0;
      if (empty) empty.hidden = shown !== 0;
      if (pagination) pagination.hidden = active;

      if (status && announce) {
        status.textContent = shown === 0
          ? "No " + noun + "s match your search."
          : "Showing " + shown + " " + noun + (shown === 1 ? "" : "s") + ".";
      }
    }

    form.addEventListener("submit", function (event) {
      event.preventDefault();
      var params = new URLSearchParams();
      if (search && search.value.trim()) params.set("q", search.value.trim());
      selects.forEach(function (select) {
        if (select.value) params.set(select.name, select.value);
      });
      var queryString = params.toString();
      var url = window.location.pathname + (queryString ? "?" + queryString : "");
      window.history.pushState(null, "", url);
      apply(true);
    });

    window.addEventListener("popstate", function () {
      readUrl();
      apply(true);
    });

    readUrl();
    apply(false);
  }

  Array.prototype.forEach.call(document.querySelectorAll("[data-filter-form]"), setUp);
})();
