# Feature Specification: MoneyFollow Family Finance App (version 1)

**Feature Branch**: N/A (no branch hook configured; work happens on `main`)

**Created**: 2026-11-15

**Status**: Draft

**Input**: User description: "read docs/REQUIREMENTS.md and check the prototype inside prototype folder"

**Sources**: [`docs/REQUIREMENTS.md`](../../docs/REQUIREMENTS.md) (detailed requirements, calculations and screen specifications) and the HTML prototype [`prototype/index.html`](../../prototype/index.html) (visual and behavioural reference for every screen). This spec is the version 1 mobile app built from both. Where they give exact values (formulas, thresholds, lists), those values apply here unchanged.

## Clarifications

### Session 2026-11-15

- Q: Which Google account does each parent's phone use for sync? → A: Support both: one shared family account (default) or each parent's own account with a shared folder (FR-058).
- Q: In version 1, do children get the app on their own phones? → A: No. Children are tracked on the parents' phones only in version 1; their own app is planned for version 2 (FR-059).
- Q: Should version 1 support moving money between accounts? → A: Yes, add transfers, including between currencies (FR-060).
- Q: When the user edits an exchange rate, what should change? → A: Only new and future amounts: new transactions, forecasts, unpaid recurring items and current balances. Past transactions keep their recorded rate (FR-014, FR-016).
- Q: Should the first release include all 10 user stories, or ship a smaller first release? → A: Core first, sync later. Release 1.0 = everything except Google Drive sync (data on one phone); release 1.1 adds sync (User Story 5, FR-049–FR-056, FR-058).
- Q: Should release 1.0 include a backup the user can save and restore? → A: Yes, a backup file plus a weekly reminder (FR-061, FR-062).
- Q: What happens if the family forgets the sync passphrase? → A: A one-time recovery key is shown when encryption is set up; the passphrase or the key unlocks the data (FR-054).
- Q: What should a new user see the first time they open the app? → A: A short, skippable setup (language, currency and country, family members), then a choice to explore with sample data or start empty (FR-063, FR-064).

## User Scenarios & Testing *(mandatory)*

The primary user is a **parent** (father or mother) who manages the household's money. Other family members (children, other household members) are tracked as people money is spent on or by; they do not need their own login in version 1 unless Question 2 below decides otherwise.

### User Story 1 - Record and review the family's income and expenses (Priority: P1)

A parent opens the app, adds an expense (amount, category, date, account, note) or an income in a few taps, and sees this month's balance, income, expenses and most recent transactions on the home screen. They can browse any past month, search, filter and correct or delete entries. Everything works without internet and in Arabic (right-to-left) or English.

**Why this priority**: Recording money in and out is the foundation of every other feature; on its own it already replaces a paper notebook or spreadsheet.

**Independent Test**: Install the app on a phone with no internet, add 10 expenses and 2 incomes across two months, close and reopen the app, switch language, and verify totals, lists, search and filters.

**Acceptance Scenarios**:

1. **Given** the app is open, **When** the parent taps **+**, enters 250, picks Groceries and saves, **Then** the expense appears at the top of Recent and this month's expenses and net balance change by 250.
2. **Given** the add sheet, **When** the amount is empty or 0 or no category is chosen, **Then** saving is refused with "Enter an amount greater than 0" or "Choose a category".
3. **Given** a saved transaction, **When** the parent opens it and taps Delete twice, **Then** it disappears from every list and total.
4. **Given** 3 months of data, **When** the parent steps back with the month selector, **Then** Home, Activity, Budgets and Reports show that month; stepping past the current month is not possible.
5. **Given** the language is English, **When** the parent switches to Arabic, **Then** every screen is translated and mirrored right-to-left immediately, and amounts stay readable with Western digits.
6. **Given** no internet connection, **When** the parent uses any feature except updating occasion dates or syncing, **Then** it works normally.
7. **Given** data on phone A, **When** the parent creates a backup file, saves it, installs the app on phone B and restores the file, **Then** phone B shows exactly the same data.
8. **Given** the last backup was 8 days ago and data changed since, **When** the app opens, **Then** a backup reminder is shown.
9. **Given** a fresh install, **When** the user completes setup and picks "Explore with sample data", **Then** Home shows the sample family with a "Sample data" banner, and **When** they tap "Clear sample data and start", **Then** the app is empty except for the settings chosen in setup.

---

### User Story 2 - Track recurring bills and income (Priority: P2)

The parent enters rent, school fees, utilities, subscriptions, salary and other repeating items once, with how often they repeat. The app lists what is due in the next 30 days, and one tap on **Mark paid** / **Received** records the transaction and moves the item to its next due date.

**Why this priority**: Fixed bills are most of a family's spending and the base of any forecast; reminders prevent missed payments.

**Independent Test**: Add a monthly rent due in 5 days and a weekly pocket money item; verify both appear under "Due in the next 30 days" and on Home; mark rent paid and check the transaction and the new due date.

**Acceptance Scenarios**:

1. **Given** a monthly item due on the 31st, **When** it is marked paid in a 30-day month, **Then** the next due date is the last day of the following month.
2. **Given** a new expense with Repeat = Monthly, **When** saved, **Then** the expense is recorded and a recurring item due one month later is created.
3. **Given** a recurring item past its due date, **When** the due list is shown, **Then** it appears first with "Overdue N d".
4. **Given** recurring items of different frequencies, **When** the Recurring tab opens, **Then** it shows fixed bills per month and recurring income per month, converting weekly, quarterly and yearly amounts to a monthly equivalent.

---

### User Story 3 - Follow each family member's spending (Priority: P2)

The parent adds family members (name, role: parent / child / other, avatar), assigns each expense or recurring item to a member or to "Whole family", and sees who spent what this month, each member's last 6 months, and each member's expected spending for the next 3 months.

**Why this priority**: Explicitly requested by the product owner; parents want to see and plan spending per child and per parent.

**Independent Test**: Add two children, assign several expenses and one recurring item to each, then check the Family and Member screens, the Activity member filter and the Reports "by member" card.

**Acceptance Scenarios**:

1. **Given** a member "Omar", **When** an expense is added from Omar's screen, **Then** the sheet has Omar preselected and the expense counts in Omar's totals.
2. **Given** Omar has 12 transactions, **When** Omar is removed (tap twice), **Then** the 12 transactions remain and now belong to "Whole family".
3. **Given** members with spending this month, **When** the Family screen opens, **Then** the share bar's amounts add up to the month's total expenses, and the next-3-months grid shows a total row and highlights months that include a quarterly/yearly bill or an occasion.

---

### User Story 4 - Use more than one currency (Priority: P2)

The family earns or spends in several currencies (for example EGP and USD). Each transaction keeps its own currency, and every total, budget, report and forecast is shown in one chosen main currency using editable exchange rates.

**Why this priority**: Many families in the target region hold dollar savings or pay foreign subscriptions; wrong totals would make the app untrustworthy.

**Independent Test**: With main currency EGP and 1 USD = 50 EGP, add a 5.99 USD subscription and a 100 USD expense; verify "≈" values, monthly totals, then change the rate and the main currency.

**Acceptance Scenarios**:

1. **Given** 1 USD = 50 EGP, **When** a 100 USD expense is entered, **Then** the sheet shows "≈ 5,000 EGP" and the month's expenses increase by 5,000 EGP.
2. **Given** a 100 USD expense recorded last month at 50, **When** the rate is changed to 52, **Then** last month's total still counts it as 5,000 EGP, a new 100 USD expense counts as 5,200 EGP, and the forecast and the Dollar account's "≈" value use 52.
3. **Given** the Dollar account holds USD, **When** Settings opens, **Then** its balance shows in USD with the main-currency equivalent, and the total of all accounts is in the main currency.
4. **Given** Bank holds 10,000 EGP, **When** the parent records a transfer of 2,000 from Bank to Cash, **Then** Bank shows 8,000 and Cash rises by 2,000, while the month's income and expenses do not change.
5. **Given** a transfer of 100 USD from the Dollar account to Bank with 5,050 EGP received, **When** saved, **Then** the Dollar account falls by 100 USD and Bank rises by 5,050 EGP.

---

### User Story 5 - Keep data on the phone and sync family devices through Google Drive (Priority: P2, release 1.1)

*Release 1.0 includes keeping all data on the phone (FR-048). Syncing between phones and restoring from Drive ship in release 1.1.*

All data lives on the phone and the app needs no account to work. Optionally, the parent connects Google Drive; then the family's phones exchange changes through it, so both parents see and enter the same data, and a new or reinstalled phone gets everything back.

**Why this priority**: Confirmed by the product owner; without sharing between parents' phones, the family view is incomplete, and without backup a lost phone loses all history.

**Independent Test**: On two phones connected to the same Drive, add, edit and delete records on each (including while offline), sync both, and compare; then reinstall the app on one phone and restore.

**Acceptance Scenarios**:

1. **Given** no Google account is connected, **When** the app is used, **Then** every feature works and data survives restarts.
2. **Given** phones A and B are connected, **When** A adds an expense and both sync, **Then** the expense appears on B.
3. **Given** both phones are offline, **When** A edits transaction X and B edits transaction Y and both later sync, **Then** both edits appear on both phones.
4. **Given** both phones edit the same transaction offline, **When** both sync, **Then** both phones end up showing the most recent edit.
5. **Given** A deletes a transaction, **When** B syncs, **Then** the transaction is gone on B.
6. **Given** a sync is interrupted (airplane mode), **When** the connection returns, **Then** the next sync completes and nothing is lost or duplicated.
7. **Given** the app is reinstalled, **When** the same Drive is connected, **Then** all data is restored.
8. **Given** both parents sign in with the same family Google account, **When** they connect sync, **Then** their phones share data with no folder sharing needed.
9. **Given** each parent uses their own Google account, **When** parent A creates the family folder and shares it with parent B, and B selects it in the app, **Then** both phones sync the same data.
10. **Given** a new phone and a forgotten passphrase, **When** the user enters the recovery key, **Then** the family data is unlocked and restored.

---

### User Story 6 - Set and watch monthly budgets (Priority: P2)

The parent sets a monthly limit per expense category and sees, for the selected month, how much of each budget is used, with warnings near and over the limit.

**Why this priority**: Budgets turn tracking into control; the three most-used budgets appear on Home.

**Independent Test**: Set Groceries = 7,000 and Shopping = 2,500, add expenses to reach 85 % and 110 %, and check colours and texts on Home and in Budgets.

**Acceptance Scenarios**:

1. **Given** a budget used 85 %, **When** viewed, **Then** its bar is the warning colour; at 110 % it is the over colour with "X over".
2. **Given** Budgets › Edit, **When** limits are typed and Done is tapped, **Then** they are saved; an empty field means "No limit".

---

### User Story 7 - See the next months before they happen (Priority: P3)

The parent opens the Forecast and sees, for the next 3 or 6 months, expected fixed bills, occasion spending, day-to-day spending, income and savings, with heavier months flagged and explained.

**Why this priority**: The main differentiator of the product ("see what is coming"), but it depends on recurring items and history existing first.

**Independent Test**: With known recurring items and 3 months of history, compare each month's figures with the formula in REQUIREMENTS.md §6.2.

**Acceptance Scenarios**:

1. **Given** a yearly car insurance due in March, **When** the 6-month forecast is shown, **Then** March is flagged "Higher than usual" and lists the insurance.
2. **Given** expenses tagged with an occasion, **When** the day-to-day average is calculated, **Then** those expenses are excluded from it so they are not counted twice.

---

### User Story 8 - Plan for yearly occasions (Priority: P3)

The app knows the family's yearly occasions (Ramadan, Eid al-Fitr, Eid al-Adha, Christmas, New Year's Eve, Sham El-Nessim, Mother's Day, Back to school), with correct dates for the chosen country. The parent tags expenses with an occasion; the app predicts the next occurrence's cost from previous years and suggests how much to put aside each month.

**Why this priority**: Occasions cause the biggest spending peaks in the target region; requested explicitly by the product owner.

**Independent Test**: With tagged spending for Ramadan in three past years, open the Ramadan screen and check the expected amount against REQUIREMENTS.md §6.3; change the country to United States and check that dates and available occasions change.

**Acceptance Scenarios**:

1. **Given** Ramadan cost 6,900 two years ago and 7,800 last year, **When** the Ramadan screen opens, **Then** expected = 7,800 × (7,800 ÷ 6,900) ≈ 8,817, within the allowed change limits.
2. **Given** a new expense dated 10 days before Ramadan, **When** the add sheet opens, **Then** Ramadan is suggested as the occasion.
3. **Given** the country is Egypt, **When** it is changed to United States and dates update, **Then** Christmas moves to 25 December and Sham El-Nessim and Mother's Day are no longer offered.
4. **Given** no internet, **When** Update is tapped, **Then** a message says the date services can't be reached and the saved dates stay in use.
5. **Given** an occasion is switched off, **When** Home, the occasion list and the forecast are viewed, **Then** it does not appear in any of them.

---

### User Story 9 - Add own categories (Priority: P3)

Besides the built-in categories, which cannot be changed or deleted, the parent adds categories of their own (type, name, icon, colour) from Settings, edits them, and deletes them without losing history.

**Why this priority**: Requested by the product owner; families have spending the built-in list doesn't cover (pets, charity, toys).

**Independent Test**: Add "Pets", use it in an expense and a budget, rename it, then delete it and check its transactions moved to "Other".

**Acceptance Scenarios**:

1. **Given** the Categories screen, **When** a built-in category is tapped, **Then** nothing can be edited; it shows as locked.
2. **Given** a new category named "groceries" or "البقالة", **When** saved as an expense category, **Then** it is refused as a duplicate.
3. **Given** "Pets" has transactions and a budget, **When** it is deleted (tap twice), **Then** its transactions and recurring items move to "Other" and its budget is removed.

---

### User Story 10 - Understand spending and export it (Priority: P3)

The parent opens Reports to see the month's income, expenses, average daily spend, change vs last month, spending by category, the last 6 months and spending by member, and can export all transactions to a spreadsheet file.

**Why this priority**: Insight and portability; valuable but not needed to start tracking.

**Independent Test**: With known data, compare every report figure with manual totals, export, and open the file in a spreadsheet app in Arabic.

**Acceptance Scenarios**:

1. **Given** the current month is 13 days in, **When** Reports opens, **Then** average daily spend = expenses ÷ 13.
2. **Given** an export, **When** opened in a spreadsheet app, **Then** Arabic text displays correctly and each row includes the amount in its own currency and in the main currency, member and occasion.

---

### Edge Cases

- A recurring item due on the 29th–31st in a shorter month uses the last day of that month.
- Deleting a member, a user category or a recurring item never deletes past transactions.
- A transaction in a currency whose rate is later changed keeps its original rate (see FR-016).
- A month with no data shows clear empty states ("No transactions this month", "No budgets set", "Nothing due in the next 30 days").
- An occasion with no history shows "No history yet…" and is not added to forecasts; with one year of history, expected = last time.
- An expense dated between two occurrences of an occasion is grouped with the nearest one.
- The date services return nothing for a country (e.g. no public holidays): Islamic occasion dates still update and the user is told.
- Two phones create records at the same moment while offline: both records are kept with no duplicate or overwritten ids.
- Sync storage is full, the Google account access is revoked, or the sync passphrase is wrong: sync stops with a clear message; local data is untouched.
- A backup file that is damaged, from a newer app version, or protected with a wrong password is refused with a clear message, and the phone's data is left unchanged.
- Very large or very small amounts and amounts with decimals display without layout breaking in both languages.
- An account can still go negative if spending is recorded from it without matching income or transfers in; the balance is then shown in the over colour.
- A transfer from the Dollar account to Bank where the amount received differs from the current rate keeps the amounts the user entered.
- A transfer from an account to the same account is refused.
- Phones set up with different sync modes (shared account vs. own accounts) cannot join the same family; the app explains how to switch.

## Requirements *(mandatory)*

Detailed rules, exact lists and screen layouts are in `docs/REQUIREMENTS.md` (§5 requirements, §6 calculations, §7 screens). The requirements below are the version 1 commitments.

### Functional Requirements

**Transactions and navigation**

- **FR-001**: Users MUST be able to add, edit and delete income and expense transactions with: amount (> 0), currency, category, family member or "Whole family", optional occasion (expenses only), date, account and note.
- **FR-002**: Deleting a transaction, recurring item, member or user category MUST require a second confirming tap.
- **FR-003**: The app MUST provide five main areas reachable from a bottom bar: Home, Activity, Add (+), Planner, Reports; Settings is reachable from Home.
- **FR-004**: Home MUST show for the selected month: net balance, income, expenses, savings rate message, family spending strip, "Coming up" (due in 30 days, expected next month, next occasion, next bills), top 3 budgets and the 5 most recent transactions.
- **FR-005**: Activity MUST list the selected month's transactions grouped by day with each day's net, filterable by type and by member and searchable by note or category.
- **FR-006**: A month selector MUST let users view any past month but not future months.

**Categories and accounts**

- **FR-007**: The app MUST include 11 built-in expense categories and 5 built-in income categories (listed in REQUIREMENTS.md FR-CAT-01/02), each with an icon, colour, Arabic and English name; built-in categories MUST NOT be editable or deletable.
- **FR-008**: Users MUST be able to add their own categories (type, name up to 20 characters, one of 24 icons, one of 12 colours), edit name/icon/colour, and delete them; names MUST be unique within a type, including against built-in names in both languages.
- **FR-009**: Deleting a user category MUST move its transactions and recurring items to the built-in "Other" of the same type and remove its budget.
- **FR-010**: User categories MUST appear everywhere built-in categories do (add sheet, budgets, reports, breakdowns, search, export).
- **FR-011**: The app MUST provide accounts Cash, Bank, Card (main currency) and Dollar account (USD), each keeping its balance in its own currency, plus a total in the main currency.

**Multi-currency**

- **FR-012**: The app MUST support EGP, USD, EUR, SAR, AED, GBP and KWD; each transaction and recurring item stores its own currency.
- **FR-013**: Users MUST be able to choose a main currency; all totals, budgets, reports and forecasts MUST be shown in it.
- **FR-014**: Users MUST be able to edit exchange rates (shown as "1 USD = 50 EGP"). A new rate applies immediately to new transactions, forecasts, recurring items not yet paid and current account balances in other currencies. It MUST NOT change past transactions (see FR-016).
- **FR-015**: Amounts in a foreign currency MUST show the original amount plus the "≈" main-currency value.
- **FR-016**: Each transaction and transfer MUST keep the exchange rates valid when it was recorded. Past totals, reports and budgets for past months MUST use those stored rates, so later rate changes do not alter them. This also applies when the main currency is changed: past amounts are converted with the rates stored at recording time.

**Recurring items**

- **FR-017**: Users MUST be able to create, edit and stop recurring items (type, amount, currency, category, member, name, frequency weekly / monthly / every 3 months / yearly, next due date, account).
- **FR-018**: When adding a transaction, users MUST be able to choose Repeat; a chosen frequency creates a recurring item due one period after the transaction date.
- **FR-019**: The app MUST list items due in the next 30 days, including overdue ones, with due labels (Overdue N d, Due today, Tomorrow, In N days).
- **FR-020**: Mark paid / Received MUST record a transaction dated today linked to the item and move the due date forward one period, keeping the day of the month (last day when it doesn't exist).
- **FR-021**: The app MUST show fixed bills per month and recurring income per month using monthly equivalents (weekly × 52/12, quarterly ÷ 3, yearly ÷ 12).
- **FR-022**: The app MUST notify the user before a bill is due, when a budget reaches 80 % and 100 %, and 30 days before an occasion; users MUST be able to turn each notification type off.

**Budgets**

- **FR-023**: Users MUST be able to set or clear a monthly limit per expense category (built-in or user).
- **FR-024**: Budgets MUST show for the selected month the total and each category's used %, spent, left or over, in normal colour below 80 %, warning colour from 80 % to 100 % and over colour above 100 %.

**Family members**

- **FR-025**: Users MUST be able to add, edit and remove family members (name required up to 30 characters, role parent / child / other, one of 9 avatars); each member gets a distinct colour automatically. "Whole family" always exists and cannot be removed.
- **FR-026**: Removing a member MUST keep their transactions and recurring items and move them to "Whole family".
- **FR-027**: The Family screen MUST show who spent this month (amount and share), each member with this month's spending and next month's expected spending, a 6-month chart split by member, and a members × next-3-months expected-spending table with totals.
- **FR-028**: The Member screen MUST show the member's spending this month, share of family, change vs last month, expected next month, 6-month history, next-3-months forecast with included bills and occasions, spending by category, recurring items and transactions, with add actions that preselect the member.

**Forecast**

- **FR-029**: The Forecast MUST show the next 3 or 6 months with, per month: fixed bills, occasions, day-to-day estimate, total spending, expected income and expected savings, plus the period's average monthly spending and a chart.
- **FR-030**: Forecast figures MUST follow REQUIREMENTS.md §6.2: day-to-day = average of the last 3 full months' expenses that are neither recurring nor occasion-tagged; income counts recurring income only.
- **FR-031**: A month MUST be flagged "Higher than usual" when its spending exceeds the period average by more than 5 % and it includes a quarterly/yearly bill or an occasion, listing what it includes.
- **FR-032**: Forecasts MUST also be available per member and for "Whole family" items only.

**Occasions**

- **FR-033**: The app MUST support the 8 occasions in REQUIREMENTS.md Appendix A, with their durations and the countries where each applies, and a country choice among Egypt, Saudi Arabia, UAE, Kuwait, United States and United Kingdom.
- **FR-034**: Islamic occasion dates MUST be obtained from a public Hijri calendar source for any country; public-holiday dates from a public holidays source for the chosen country; fixed-date occasions use the same day each year.
- **FR-035**: The app MUST ship with built-in occasion dates (Egypt, 2024–2027) for offline use, MUST offer an Update action that fetches 3 years back to 1 year ahead, MUST update automatically when the country changes, and MUST show when dates were last updated; failures MUST leave saved dates in use with a message.
- **FR-036**: Users MUST be able to switch each occasion on or off; switched-off occasions disappear from lists, Home and forecasts.
- **FR-037**: Users MUST be able to tag an expense with an occasion; the app MUST suggest the occasion when the date falls from 14 days before it to its last day, without overriding a choice the user made.
- **FR-038**: The app MUST predict each occasion's cost per REQUIREMENTS.md §6.3 (last occurrence × average year-over-year change of the last 3 occurrences, limited to 0.85–1.5) and show it per category and per member.
- **FR-039**: The occasion screen MUST show expected amount, Gregorian date (and Hijri date for Islamic occasions), days left, "put aside X a month", previous years vs expected, expected by category, who spent last time and last time's transactions.
- **FR-040**: Users MUST be able to move an occasion's date by ±1 day for a given year (official moon-sighting differences).
- **FR-041**: Users MUST be able to add custom yearly occasions (name, icon, date, duration).

**Reports and export**

- **FR-042**: Reports MUST show for the selected month: income, expenses, average daily spend, change vs last month, spending by category (top 7 with %), income vs expenses for the last 6 months, and spending by member.
- **FR-043**: Users MUST be able to export all transactions to a spreadsheet file with columns date, type, category, amount, currency, amount in main currency, account, member, occasion, note, recurring, readable with Arabic text in common spreadsheet apps.

**Language, appearance and settings**

- **FR-044**: All text MUST be available in Arabic and English, switchable at any time without restarting; Arabic MUST use a full right-to-left layout.
- **FR-045**: Numbers MUST use Western digits in both languages; dates and month names follow the language; Hijri dates use the Umm al-Qura calendar.
- **FR-046**: Users MUST be able to choose light, dark or system theme.
- **FR-047**: Settings MUST contain accounts and balances, family members, categories, language, main currency, theme, exchange rates, backup and restore, sync (release 1.1), notifications and export.

**Local storage, sync and protection**

- **FR-048**: All data MUST be stored on the phone and saved automatically after every change; the app MUST be fully usable without internet and without any account.
- **FR-049**: Users MUST be able to connect, optionally, a Google account so the family's phones sync through Google Drive; the app MUST request access only to its own files, never to the user's other Drive files.
- **FR-050**: Sync MUST exchange changes per record so that edits made on different phones to different records are all kept; for the same record, the most recent edit wins; deletions MUST sync.
- **FR-051**: Sync MUST never overwrite another phone's unsynced work, MUST queue changes while offline, and MUST resume safely after interruption without loss or duplicates.
- **FR-052**: Sync MUST run when the app opens, shortly after a change, on pull-to-refresh, on "Sync now", and periodically in the background where the phone allows; an optional "Wi-Fi only" setting MUST be respected.
- **FR-053**: Settings › Sync MUST show the connected account, status (synced time / waiting / failed with retry), connected devices with last sync time, Wi-Fi only, and Disconnect (stops syncing, keeps local data).
- **FR-054**: Synced data in Google Drive MUST be encrypted on the phone with a family passphrase so it cannot be read in Drive without it. When encryption is set up, the app MUST show a one-time **recovery key** for the user to print or save, and MUST ask the user to confirm they have saved it. Either the passphrase or the recovery key MUST unlock the data. The passphrase can be changed from any connected phone. If both are lost, the Drive copy is unreadable, but each phone's local data is untouched and can start a new sync.
- **FR-055**: Connecting the same Drive on a new or reinstalled phone MUST restore all family data.
- **FR-056**: Only family data MUST sync; device preferences (language, theme, Wi-Fi only, notifications) stay per phone.
- **FR-057**: Users MUST be able to protect the app with a PIN or the phone's biometrics.
- **FR-058**: Sync MUST support two set-ups, chosen when connecting:
  - **(a) Shared family account (default):** every phone signs in with the same family Google account, and the sync data is kept in the app's private, hidden storage in that account's Drive.
  - **(b) Each parent's own account:** the first parent creates a "MoneyFollow" folder in their Drive and shares it with the other parent's Google account. The other parent selects that shared folder once in the app.

  In both set-ups the app may access only its own sync data. The Sync settings MUST show which set-up is in use.
- **FR-059**: In version 1, children and other members MUST be tracked only on the parents' phones (no child login or child app). Giving children their own app with access limited to their own data is planned for version 2 and MUST NOT be blocked by version 1 design choices.
- **FR-060**: Users MUST be able to record a **transfer** between two accounts (e.g. Bank → Cash, Dollar account → Bank) with amount, date, note and, when the accounts' currencies differ, the amount received or the rate. Transfers MUST change both account balances, MUST NOT count as income or expenses in totals, budgets, reports or forecasts, MUST appear in Activity with their own look and filter, and MUST be editable and deletable like transactions.
- **FR-061** (release 1.0): Users MUST be able to create a **backup file** of all family data from Settings › Backup and save or share it anywhere the phone allows (files, cloud storage, messaging, email). They MUST be able to restore it on the same or another phone. The user may protect the file with an optional password. Restoring MUST show the backup's date and size and ask for confirmation before it replaces the data on the phone.
- **FR-062** (release 1.0): If no backup has been made in the last 7 days and data has changed since the last backup, the app MUST remind the user to back up. The reminder can be snoozed or turned off in Settings, and Settings MUST show the date of the last backup.
- **FR-063**: On first launch the app MUST show a short setup:
  1. Language. This step also offers "Restore from backup".
  2. Main currency and country, defaulted from the phone's settings.
  3. Family members (optional).

  Every step can be skipped, and skipped steps use defaults that can be changed later in Settings.
- **FR-064**: At the end of setup, the user MUST be able to choose **Explore with sample data** (a realistic family with 3 years of history, as in the prototype) or **Start with my own data**. While sample data is shown, the app MUST display a visible "Sample data" banner with a one-tap **Clear sample data and start**. Clearing MUST remove all sample records and anything added while exploring, after a warning. Sample data MUST never be synced, never trigger backup reminders, and never be mixed with the user's real data.

### Key Entities *(include if feature involves data)*

- **Family**: the household whose data is shared; has a main currency, country, exchange rates, enabled occasions and budgets.
- **Family member**: a person in the household; name, role (parent / child / other), avatar, colour. "Whole family" is a fixed pseudo-member for shared spending.
- **Transaction**: one income or expense; amount, currency, rate at recording time, category, account, member, optional occasion, date, note, optional link to the recurring item that produced it.
- **Recurring item**: a repeating bill or income; amount, currency, category, account, member, name, frequency, next due date, day of month.
- **Category**: built-in (fixed, bilingual names) or user-defined (type, name, icon, colour).
- **Account**: Cash, Bank, Card, Dollar account; each with its own currency.
- **Transfer**: money moved between two accounts; from-account, to-account, amount sent, amount received (differs when currencies differ), date, note. Not income or expense.
- **Sync set-up**: shared family account or own accounts with a shared folder; the family's sync location.
- **Budget**: monthly limit for one expense category.
- **Exchange rate**: value of one unit of a currency in the reference currency. The current rates are kept in settings, and a copy of the rates in use is stored with each transaction and transfer.
- **Occasion**: a yearly event (built-in or custom); source of its dates (Hijri, public holiday, fixed), duration, countries, icon, colour, enabled flag.
- **Occasion date**: the start date of one year's occurrence, fetched, built-in or adjusted by the user.
- **Device**: a phone connected to the family's sync; name and last sync time.
- **Device preferences**: language, theme, Wi-Fi-only sync, notification switches, app lock (not synced).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A first-time user can record an expense in under 15 seconds and in no more than 5 taps after typing the amount.
- **SC-002**: Every screen opens in under 1 second on a mid-range phone with 3 years of data (about 2,000 transactions).
- **SC-003**: 100 % of the acceptance checklist in REQUIREMENTS.md §13 passes in both Arabic and English.
- **SC-004**: All features except occasion-date updates and sync work with the phone in airplane mode.
- **SC-005** (release 1.1): With two phones syncing, a change made on one appears on the other within 1 minute of both being online with the app open.
- **SC-006** (release 1.1): In a test of 500 random offline edits across two phones followed by sync, 0 records are lost or duplicated and both phones end with identical data.
- **SC-007** (release 1.1): Restoring on a reinstalled phone recovers 100 % of transactions, members, categories, recurring items and budgets.
- **SC-008**: Forecast and occasion predictions match the formulas in REQUIREMENTS.md §6 exactly for a reference data set (prototype sample data).
- **SC-009**: In usability testing with 5 parents, at least 4 can, without help, add a family member, assign an expense to them, and find that member's expected spending next month.
- **SC-010**: No screen has clipped, overlapping or wrongly mirrored content in Arabic at 360 px width and at the largest system font size.
- **SC-011**: Restoring a backup file on another phone recovers 100 % of the data, and a full backup of 3 years of data takes under 10 seconds.

## Assumptions

- **Release plan:**
  - **Release 1.0:** all user stories and requirements except Google Drive sync. Data lives on one phone.
  - **Release 1.1:** adds sync and restore from Drive (User Story 5; FR-049–FR-056 and FR-058).
  - Release 1.0 must store data so that 1.1 can sync it without migration loss: unique record ids, change times and soft deletes from day one.
  - SC-005, SC-006 and SC-007 apply from release 1.1.
- The HTML prototype is the reference for layout and behaviour; where it and REQUIREMENTS.md differ, REQUIREMENTS.md wins.
- Version 1 targets Android and iOS phones; tablets, web and desktop are out of scope.
- The primary user is a parent; the app is used by one family per installation; there is no MoneyFollow server.
- Setup defaults come from the phone's settings. When the phone's language or region isn't supported, the defaults are Arabic, EGP and Egypt. All of them can be changed later.
- Exchange rates are entered manually in version 1; automatic live rates are a later enhancement.
- Occasion dates come from free public calendar services (Hijri calendar and public holidays); if they are unavailable, built-in or saved dates are used.
- Islamic dates are astronomical calculations and may differ by one day from official announcements; FR-040 covers this.
- Notifications are local to the phone (no push server).
- Bank syncing, bill payment, receipt scanning, investments, loans and tax reports are out of scope (REQUIREMENTS.md §1.3).
- The released app offers sample data only through first-launch setup (FR-064). The prototype's "Reset demo data" button is not in the released app.
- Items that REQUIREMENTS.md lists as "should have" or as production proposals (§11) are treated as version 1 commitments here: rate kept per transaction (FR-016), notifications (FR-022), occasion date adjustment and custom occasions (FR-040, FR-041), sync encryption (FR-054) and app lock (FR-057). `/speckit-clarify` or planning may move any of them to a later version.
- Development and build tooling live on drive D of the development PC; building Android packages requires resolving the Smart App Control decision (REQUIREMENTS.md D-1), which does not affect this specification.
