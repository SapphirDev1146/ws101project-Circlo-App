/* ==========================================================================
   Circlo — form validation (DESIGN.md 7.5 and 9.2)

   Front-end checks only. The backend must check everything again.

   Markup it expects:
     <form data-validate> … </form>
     <div class="field">
       <label class="field__label" for="email">Email (required)</label>
       <input class="field__input" id="email" name="email" type="email" required
              aria-describedby="email-error"
              data-error-required="Enter your email."
              data-error-email="Enter an email like name@example.com.">
       <p class="field__error" id="email-error" hidden>
         <svg class="field__error-icon" …></svg><span class="field__error-text"></span>
       </p>
     </div>

   Checks, read from the input:
     required        → data-error-required
     type="email"    → data-error-email
     minlength="8"   → data-error-minlength
     type="number" with min / max → data-error-range
     data-match="id" → data-error-match   (must equal the field with that id)
     radio group with required on the first radio → data-error-required on it;
       the group is a <fieldset class="field field--group"> and its message is NAME-error

   After a failed submit:
     - each wrong field gets aria-invalid="true", .field--error and its message
     - what the user typed is kept
     - focus moves to the first wrong field
     - with 3 or more errors, [data-error-summary] lists them at the top
     - fields are checked again as the user fixes them

   FRONT-END DEMO ONLY: when the form is valid and has data-demo-next="url",
   the button shows its loading label (data-loading-label), then the browser
   goes to that page. Remove data-demo-next once the backend handles the POST.
   On the login form, data-demo-admin-email="…" and data-demo-admin-next="url"
   send that one test email to the admin pages instead, to show both roles.
   This is NOT security: the backend must check the role on the server.
   ========================================================================== */
(function () {
  "use strict";

  var EMAIL = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

  function radioGroup(input) {
    return input.form.querySelectorAll('input[type="radio"][name="' + input.name + '"]');
  }

  function messageFor(input) {
    if (input.type === "radio") {
      var group = radioGroup(input);
      var checked = Array.prototype.some.call(group, function (radio) { return radio.checked; });
      if (group[0].required && !checked) {
        return group[0].getAttribute("data-error-required") || "Choose one option.";
      }
      return "";
    }

    var value = input.value.trim();
    if (input.required && value === "") {
      return input.getAttribute("data-error-required") || "Fill in this field.";
    }
    if (value === "") return "";
    if (input.type === "email" && !EMAIL.test(value)) {
      return input.getAttribute("data-error-email") || "Enter a valid email address.";
    }
    if (input.type === "number") {
      var number = Number(value);
      var minValue = input.getAttribute("min");
      var maxValue = input.getAttribute("max");
      if (isNaN(number) || (minValue !== null && number < Number(minValue)) ||
          (maxValue !== null && number > Number(maxValue))) {
        return input.getAttribute("data-error-range") || "Enter a number in the allowed range.";
      }
    }
    var min = parseInt(input.getAttribute("minlength"), 10);
    if (min && input.value.length < min) {
      return input.getAttribute("data-error-minlength") || "Use at least " + min + " characters.";
    }
    var matchId = input.getAttribute("data-match");
    if (matchId) {
      var other = document.getElementById(matchId);
      if (other && other.value !== input.value) {
        return input.getAttribute("data-error-match") || "The two values don't match.";
      }
    }
    return "";
  }

  function show(input, message) {
    var field = input.closest(".field");
    // A radio group has one error message, named after the group: NAME-error
    var isRadio = input.type === "radio";
    var error = document.getElementById((isRadio ? input.name : input.id) + "-error");
    var text = error && error.querySelector(".field__error-text");
    var targets = isRadio ? Array.prototype.slice.call(radioGroup(input)) : [input];

    if (message) {
      targets.forEach(function (el) { el.setAttribute("aria-invalid", "true"); });
      if (field) field.classList.add("field--error");
      if (text) text.textContent = message;
      if (error) error.hidden = false;
    } else {
      targets.forEach(function (el) { el.removeAttribute("aria-invalid"); });
      if (field) field.classList.remove("field--error");
      if (text) text.textContent = "";
      if (error) error.hidden = true;
    }
  }

  function labelText(input) {
    var label = input.type === "radio"
      ? input.closest("fieldset") && input.closest("fieldset").querySelector("legend")
      : document.querySelector('label[for="' + input.id + '"]');
    return label ? label.textContent.trim().replace(/\s*\(required\)\s*$/, "") : input.name;
  }

  function showSummary(form, errors) {
    var summary = form.parentNode.querySelector("[data-error-summary]");
    if (!summary) return;
    var list = summary.querySelector(".alert__list");
    var title = summary.querySelector(".alert__title");

    if (errors.length < 3) {
      summary.hidden = true;
      return;
    }
    title.textContent = "Fix these " + errors.length + " things to continue:";
    list.innerHTML = "";
    errors.forEach(function (item) {
      var li = document.createElement("li");
      var a = document.createElement("a");
      a.href = "#" + item.input.id;
      a.textContent = labelText(item.input) + ": " + item.message;
      a.addEventListener("click", function (event) {
        event.preventDefault();
        item.input.focus();
      });
      li.appendChild(a);
      list.appendChild(li);
    });
    summary.hidden = false;
  }

  function setUp(form) {
    // One entry per field: a radio group is checked once, through its first radio.
    var seenGroups = {};
    var inputs = Array.prototype.slice.call(
      form.querySelectorAll("input[id], select[id], textarea[id]")
    ).filter(function (input) {
      if (input.type !== "radio") return true;
      if (seenGroups[input.name]) return false;
      seenGroups[input.name] = true;
      return true;
    });
    var submitted = false;

    // JavaScript takes over from the browser's own bubbles.
    form.setAttribute("novalidate", "");

    form.addEventListener("submit", function (event) {
      submitted = true;
      var errors = [];
      inputs.forEach(function (input) {
        var message = messageFor(input);
        show(input, message);
        if (message) errors.push({ input: input, message: message });
      });
      showSummary(form, errors);

      if (errors.length) {
        event.preventDefault();
        errors[0].input.focus();
        return;
      }

      var next = form.getAttribute("data-demo-next");

      // Demo roles (login only): one test email opens the admin pages instead.
      var adminEmail = form.getAttribute("data-demo-admin-email");
      var emailInput = form.querySelector('input[type="email"]');
      if (adminEmail && emailInput &&
          emailInput.value.trim().toLowerCase() === adminEmail.toLowerCase()) {
        next = form.getAttribute("data-demo-admin-next") || next;
      }

      if (next) {
        event.preventDefault();
        var button = form.querySelector('button[type="submit"]');
        if (button) {
          button.disabled = true;
          button.textContent = button.getAttribute("data-loading-label") || "Saving…";
        }
        window.setTimeout(function () {
          window.location.href = next;
        }, 800);
      }
    });

    // Re-check a field as the user fixes it, but only after the first submit.
    function recheck(input) {
      if (!submitted) return;
      show(input, messageFor(input));
    }

    // Radios and selects fire "change"; text fields fire "input".
    form.addEventListener("change", function (event) {
      var target = event.target;
      if (target.type === "radio") {
        recheck(radioGroup(target)[0]);
      } else if (inputs.indexOf(target) !== -1) {
        recheck(target);
      }
    });

    inputs.forEach(function (input) {
      if (input.type === "radio") return;
      input.addEventListener("input", function () {
        if (!submitted) return;
        show(input, messageFor(input));
        // A changed password can fix or break the confirm field.
        inputs.forEach(function (other) {
          if (other.getAttribute("data-match") === input.id && other.value) {
            show(other, messageFor(other));
          }
        });
      });
    });
  }

  Array.prototype.forEach.call(document.querySelectorAll("form[data-validate]"), setUp);
})();
