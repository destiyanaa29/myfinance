# MyFinance 2.0 — Online Personal Finance

Dark-mode personal finance tracker using HTML, CSS, JavaScript, Supabase Auth + PostgreSQL.

## Included
- Email/password sign up and login
- Cloud-saved transactions with per-user Row Level Security
- Quick text transaction entry and manual entry
- Monthly budgets by expense category
- Savings goals and contribution updates
- Payables and receivables tracking
- Bill due dates and browser notification permission
- Annual income/expense chart and CSV export
- Responsive dark UI

## Requirements
- VS Code
- GitHub account
- Supabase account (Free plan is enough to start)
- Browser + internet

## A. Create Supabase project
1. Open https://supabase.com/dashboard and create a new project.
2. Save the database password securely. Do not put it in frontend code.
3. Wait until the project is ready.
4. Open SQL Editor -> New query.
5. Paste all content from `schema.sql` and click Run.
6. Open Project Settings -> API (or API Keys).
7. Copy the Project URL and the publishable key (or legacy anon key).
8. Open `config.js` and replace:
   - `ISI_PROJECT_URL_DI_SINI` with Project URL
   - `ISI_PUBLISHABLE_ATAU_ANON_KEY_DI_SINI` with publishable/anon key
9. Never use `service_role` or secret key in browser code. RLS policies in schema.sql protect user-owned rows.

## B. Authentication settings
1. In Supabase, open Authentication -> URL Configuration.
2. Set Site URL to your local development URL while testing, e.g. `http://127.0.0.1:5500`.
3. Add Redirect URLs for local and hosted addresses:
   - `http://127.0.0.1:5500/**`
   - `http://localhost:5500/**`
   - `https://YOUR-USERNAME.github.io/YOUR-REPOSITORY/**`
4. Email confirmation is enabled by default in many projects. Confirm the registration email before signing in. For a private prototype only, you can adjust email confirmation under Authentication settings, but keeping verification enabled is safer.
5. Configure an SMTP provider if you need reliable custom email delivery at scale; default email service has sending limits.

## C. Run locally in VS Code
1. Open this folder in VS Code.
2. Install Live Server extension if needed.
3. Right-click `index.html` -> Open with Live Server.
4. The URL is often `http://127.0.0.1:5500`.
5. Register using your email and password, verify email if requested, then log in.

Laragon is not required because there is no PHP/MySQL backend in this version. Supabase is the online database and auth provider.

## D. Publish with GitHub Pages
1. Create a GitHub repository (e.g. `myfinance`).
2. Upload all files: `index.html`, `style.css`, `app.js`, `config.js`, `schema.sql`, and `README.md`.
3. GitHub repo -> Settings -> Pages.
4. Under Build and deployment choose Deploy from a branch.
5. Choose `main` and `/(root)`, Save.
6. Wait for the published URL, usually `https://YOUR-USERNAME.github.io/myfinance/`.
7. Add that URL to Supabase Authentication -> URL Configuration -> Redirect URLs and set Site URL accordingly.
8. Test sign-up, email confirmation, login, create a transaction, then log out and log in again to verify cloud persistence.

GitHub Pages hosts the static frontend. Supabase stores the data online. The repository can be public, but do not commit private credentials. The publishable/anon key is designed to be used in a browser only when RLS is enabled and policies are correct. Never expose service-role keys.

## Important behavior and limitations
- Balances are calculated from transactions entered in this app. For an existing cash balance, create an opening-balance income transaction on the date you start tracking. Use a clear category/description such as "Saldo awal".
- Transactions are globally included in the running balance; the month selector only changes monthly summaries.
- Budget usage is calculated from expense transactions whose category name matches the budget category and month.
- Savings-goal contributions update the goal balance only; they do not automatically create a cash transaction. If you want full cash-flow reconciliation, record the saving transfer as an expense transaction too.
- Debt repayments update the debt record only. They do not automatically add income/expense transactions; record the cash movement separately if you want it included in balance totals.
- Bills are reminders and do not automatically create expense transactions when marked paid. Add a transaction separately to reflect the actual payment.
- Browser notifications require permission and the website to be open in a supported browser. This version does not send push notifications while the browser is closed. Repeat-monthly is a label/reminder preference; it does not auto-create future bill records.
- Export CSV regularly. Supabase Free projects may pause after a week of low activity, and free plans do not include automatic database backups. Keep your own CSV exports.
- This is a personal bookkeeping tool, not a bank connection or financial advice product.
