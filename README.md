# Circlo — front-end

Circlo is a community web system for sharing reusable items and organizing disaster donations (WS 101).
This repository holds the **front-end**: plain HTML, CSS and a little vanilla JavaScript. It has no frameworks and no build step.

- **Design rules:** [DESIGN.md](DESIGN.md) is the source of truth for pages, components, tokens and flows.
- **Rules for AI coding assistants:** [AGENT.md](AGENT.md)
- **Open questions:** [DESIGN.md §12.4](DESIGN.md#124-design-questions)

## Run it locally

The project sits in the XAMPP web root. Start Apache and open:

```
http://localhost/Circlo%20milestone-%20front-end/index.html
```

## Folder structure

```
index.html, browse.html, item.html,       Visitor pages (V1–V6)
disaster-help.html, login.html, signup.html
member/        Member pages (M1–M16)
admin/         Admin pages (A1–A9)
css/
  tokens.css       design tokens (variables only)
  base.css         reset, typography, focus
  layout.css       containers, grids, templates
  components.css   every shared component
  pages/           page-only layout tweaks (keep tiny)
js/            small scripts (filters, form validation, success messages)
assets/
  logo/        logo.png (128 px, for pages), logo-full.png (original)
  images/      photos
  icons/
```

Every page links the four CSS files in this order: `tokens.css`, `base.css`, `layout.css`, `components.css`.

## Build status

| Area | Pages | Status |
|---|---|---|
| Visitor | all 6 pages (V1–V6) | Done (front end, sample data) |
| Member | all 16 pages in `member/` (M1–M16) | Done (front end, sample data) |
| Admin | all 9 pages in `admin/` (A1–A9) | Done (front end, sample data) |

Forms and lists work as a **front-end demo**: validation, search and filters run in the browser, and a valid form moves to the next page with a success message. Nothing is saved. Each form has a `data-demo-next` attribute for the demo: remove it when the backend handles the POST. Look for `Backend:` comments in each page for the field names.

**Demo log in:** on `login.html`, the test email `admin@circlo.test` opens the admin pages, and any other email opens the member pages. Any password works. This is only for showing both roles. The real login must check the password and the user's `role` on the server, and every admin page must check `$_SESSION['role']` before it shows anything (members go to `member/no-access`).

Scripts in `js/`: `list-filter.js` (search and filters), `form-validate.js` (form errors and the demo redirect), `flash.js` (success message from `?done=…`), `dialog.js` (confirm and quick-edit dialogs on admin pages).

The full page list with IDs, templates and main actions is in [DESIGN.md §3.3](DESIGN.md#33-page-catalog).

---

## Notes for the backend

### Pages that send data (forms)

Each of these pages will have a `<form method="post">`. Every field gets a `name` attribute. Let's agree on the field names before the form is built.

| Page | File | Does | CRUD |
|---|---|---|---|
| V6 Sign up | `signup.html` | Create an account | Create |
| V5 Log in | `login.html` | Log in (and send the user to member or admin home) | — |
| M4 Request item | `member/request-item.html` | Request someone's item | Create |
| M5 Post item | `member/post-item.html` | Post a new item | Create |
| M7 Edit item | `member/edit-item.html` | Edit my item | Update |
| M8 Remove item | `member/remove-item.html` | Remove my item (**soft delete**: hide it, keep the record) | Delete |
| M9 Requests | `member/requests.html` | Accept or decline requests | Update |
| M10 Handover record | `member/handover.html` | Record a handover | Update |
| M12 Report incident | `member/report-incident.html` | Report a disaster incident | Create |
| M13 Ask for help | `member/ask-for-help.html` | Ask for help after a disaster | Create |
| M14 Offer donation | `member/offer-donation.html` | Offer a donation | Create |
| A2 Users | `admin/users.html` | Edit or deactivate a user | Update / Delete |
| A3 Categories | `admin/categories.html` | Add, edit or remove a category | Create / Update / Delete |
| A4 Item listings | `admin/listings.html` | Hide a listing | Update |
| A6 / A7 | `admin/assistance.html`, `admin/donations.html` | Update request and offer status | Update |
| A9 Review incident | `admin/review-incident.html` | Change incident status | Update |

The pages that only show data (browse, item details, disaster help, My activity tabs, admin lists, activity log) currently use **sample content**. Replace it with real data.

### Things to agree on

1. **Storage.** Probably PHP + MySQL (we're on XAMPP). Not decided yet: see DESIGN.md §12.4 #1.
2. **Login and roles.** Visitor, Member and Admin each see a different header. Members who open an admin page go to `member/no-access.html` (M16). See §12.4 #2.
3. **File type.** Pages are `.html` for now. If PHP renders them, rename them to `.php`, and update the links between pages to match.
4. **Shared header and footer.** These are identical on every page except for the role and the active link (DESIGN.md §7.1). They are good candidates for a PHP `include`.
5. **Link paths.** DESIGN.md's code samples use links from the site root (`/member/home.html`). Under XAMPP the site is in a subfolder, so pages use **relative** links instead (`browse.html` from the root, `../css/tokens.css` from `member/` and `admin/`).
6. **Status words.** Use the exact status words from DESIGN.md §9.3 (Available, Reserved, Pending, Verified…). The UI shows them as text.
