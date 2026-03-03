# Tori — Frontend Screens Implementation Plan

> **Goal:** Close the gap between current Flutter implementation and the Figma design.
> The Figma MCP reached its call limit, so this plan is based on deep code analysis +
> the design tokens already established (`#ede6e3` beige bg, `#4d4730` olive text,
> `#f18f01` amber accent). The Figma design description indicates a warm, modern
> appointment-booking app with a sidebar drawer + bottom nav.
> figma design available at: https://www.figma.com/design/cctLbGZuL0swgAA7w4PrVw/Tori?node-id=0-1&t=4tqxob6V0vfmHuHN-1

---

## Design System Reference

| Token | Value | Usage |
|---|---|---|
| Background | `#ede6e3` (beige) | Screen backgrounds |
| Surface | `#ffffff` | Cards, sheets |
| SurfaceVariant | `#f5f1ee` | Secondary areas, chips |
| Text Primary | `#4d4730` (olive) | Headlines, body |
| Text Secondary | `rgba(77,71,48,0.50)` | Subtitles, hints |
| Accent / CTA | `#f18f01` (amber) | Buttons, FAB, selected states |
| Border | `rgba(77,71,48,0.10)` | Card borders, dividers |
| Card radius | 16–24 px | All cards |
| Button radius | 16 px | ElevatedButton, OutlinedButton |

---

## Onboarding & Registration Screens

> These screens handle the entire pre-home flow. Several of them have **critical routing
> bugs** (routes missing from `app.dart`) and **compilation errors** (`AppColors.slate*`
> tokens don't exist in `app_colors.dart`).

---

### O-0. Splash Screen (`_SplashScreen` in `app.dart`) — REDESIGN NEEDED (NEW)
**Current:** An anonymous `_SplashScreen` widget inside `app.dart` that renders a plain
`Center(child: CircularProgressIndicator())` with no branding.
**Issues:**
- Zero branding — just a spinner on a white background.
- No Tori logo, no colour theme, no animation.
- The warm beige/amber palette is completely absent on first launch.

**Planned changes:**
- [ ] Extract into `lib/presentation/features/splash/splash_screen.dart`.
- [ ] Amber gradient background (`amber500 → amber700`) OR warm beige with a centred
  amber circle logo.
- [ ] Animate the Tori "T" circle logo with a scale-bounce in, then fade into the
  wordmark "תורי" below it.
- [ ] Check `SharedPreferences → hasLaunched` here (instead of in `OnboardingScreen`)
  to decide whether to route to `/onboarding` or to let the auth redirect handle it.
- [ ] Keep existing `checkAuth()` call in `initState`.

**Route:** `/splash` — already registered in `app.dart`, just needs the widget replaced.

---

### O-1. Onboarding Screen (`onboarding_screen.dart`)
**Current:** 3-slide `PageView` with animated icon, title, body, dot indicators, CTA button.
**Issues:**
- **Dark backgrounds** (`#1E293B`, `#0F172A`, `#064E3B`) clash with the app's warm
  beige/amber palette. The onboarding feels like a different app.
- All text is hardcoded Hebrew; `_SlideData.titleEn` exists but is **never used** — the
  localization switch was never wired up.
- `'דלג'`, `'הבא'`, `'בוא נתחיל!'` should come from `context.l10n.*`.
- After completing all slides → `context.go('/welcome')` but **`/welcome` has no route
  in `app.dart`** — this causes a GoRouter crash at runtime!
- `OnboardingScreen` itself has no route in `app.dart` (missing `GoRoute(path: '/onboarding')`).

**Planned changes:**
- [ ] **Add `/onboarding` route** to `app.dart`; add redirect logic: if `!hasLaunched`
  and user is unauthenticated → go to `/onboarding` before `/auth/login`.
- [ ] **Retheme slides** to use the warm palette:
  - Slide 1: beige background, amber calendar icon, olive text.
  - Slide 2: olive-dark background, white icon, beige text (keep the contrast).
  - Slide 3: amber background, white icon, white text.
- [ ] **Wire up l10n**: use `_SlideData.titleEn` / `_SlideData.bodyEn` for English locale.
  Add `bodyEn` field. Use `context.l10n.*` for button labels.
- [ ] Dot indicators: change active dot from per-slide `accentColor` to a consistent
  amber `AppColors.primary`.

---

### O-2. Welcome Screen (`welcome_screen.dart`)
**Current:** Dark header (gradient olive/dark), beige lower card, 3 role cards
(Client / BO / SP) + "already have account" link.
**Issues:**
- **Compilation error:** uses `AppColors.slate900` as `backgroundColor` and
  `AppColors.slate200` in `_JoinConfirmSheet` — these colours **do not exist** in
  `app_colors.dart`. App will not compile.
- **Route missing**: `/welcome` is not registered in `app.dart`.
- `_Header` uses hardcoded dark background instead of `AppColors.olive900` /
  `AppColors.splashGradient`.
- All strings are hardcoded Hebrew (no l10n):
  `'שם העסק שלך'`, `'אני לקוח חדש'`, `'רוצה לפתוח עסק'`, `'אני ספק שירות'`, etc.
- **"Already have account"** button calls `_loginAs('client')` which creates a new
  client account — it should just trigger Google sign-in and let the backend resolve
  the existing role.
- `_showBusinessNameDialog` pops an `AlertDialog` mid-flow — should be a dedicated
  bottom sheet or its own route screen.

**Planned changes:**
- [ ] **Fix compilation**: define `AppColors.slate900 = olive900` and
  `AppColors.slate200 = olive200` aliases in `app_colors.dart`, OR replace usages with
  existing tokens (`AppColors.olive900`, `AppColors.border`).
- [ ] **Add `/welcome` route** to `app.dart`.
- [ ] Replace all hardcoded Hebrew strings with `context.l10n.*` keys
  (add keys: `iAmNewClient`, `iAmBusinessOwner`, `iAmServiceProvider`, `alreadyHaveAccount`,
  `whatIsYourBusinessName`).
- [ ] Fix "already have account" → call `_loginAs` with no role; backend resolves the
  existing user's role automatically.
- [ ] Replace `_showBusinessNameDialog` with a modal bottom sheet `_BusinessNameSheet`
  (consistent with the rest of the app's sheet pattern).
- [ ] Replace `AppColors.slate900` background with `AppColors.olive900` for the header
  (already exists and is the intended Figma dark tone).

---

### O-3. OTP Screen (`otp_screen.dart`)
**Current:** White background, phone input with `+972` prefix badge, 6-box OTP grid,
resend timer. Good visual quality.
**Issues:**
- All text hardcoded Hebrew: `'מה מספר הטלפון שלך?'`, `'נשלח לך קוד SMS לאימות'`,
  `'הכנס את הקוד'`, `'שלח קוד'`, `'אמת קוד'`, `'שלח קוד שוב'`, etc.
- After successful OTP verification → `authProvider.notifier.verifyOtp()` navigates
  to `/home` directly, **skipping `/auth/notification-permission`**.
- The `_OtpBox` `isFilled` styling (amber fill) works but the box size (46×58) is
  smaller than typical Israeli app OTP boxes.
- Error message `'אימות נכשל, נסה שוב'` is hardcoded.

**Planned changes:**
- [ ] Add all OTP strings to `app_he.arb` / `app_en.arb` and use `context.l10n.*`.
- [ ] After successful verification: navigate to `/auth/notification-permission`
  **instead of `/home`**. Let `NotificationPermissionScreen` navigate to `/home`.
- [ ] Slightly enlarge OTP boxes to 52×64 for better tappability.

---

### O-4. Notification Permission Screen (`notification_permission_screen.dart`)
**Current:** Centred icon + title + body text + single "Allow Notifications" button.
**Issues:**
- `'Allow Notifications'` button label is **hardcoded English** — not using l10n.
- If permission is **denied**, the screen shows an error snackbar but stays on this
  screen — user is stuck. Should navigate to `/home` either way (permission is optional).
- Plain white `Scaffold` background — should use `AppColors.background` (beige) to
  match the design system.
- Icon is `notifications_active_rounded` at 96px — could use the branded Tori style
  (amber circle with white icon inside, same as the login "T" logo treatment).
- No "Skip" or "Maybe Later" option visible — the only way to leave is to accept.

**Planned changes:**
- [ ] Localize button label (`context.l10n.allowNotifications`).
- [ ] Add a `'Skip'` `TextButton` below the main button → `context.go('/home')`.
- [ ] On denial → show snackbar AND navigate to `/home` (don't leave user stuck).
- [ ] Change background to `AppColors.background`.
- [ ] Wrap icon in an amber circle container (56px icon inside 88px amber circle).

---

### O-5. Business Search Screen (`business_search_screen.dart`)
**Current:** Search bar + business list cards with "הצטרף" button; confirmation bottom
sheet before submitting join request.
**Issues:**
- **Route missing**: `/business-search` is not registered in `app.dart`.
- All text hardcoded Hebrew:
  `'עם איזה עסק'`, `'תרצה לקבוע תורים?'`, `'חפש שם עסק...'`, `'לדלג'`,
  `'הצטרף'`, `'שלח בקשה'`, `'ביטול'`, etc.
- Uses `AppColors.slate200` in `_JoinConfirmSheet` — **compilation error** (same as
  `WelcomeScreen`).
- Posts to `POST /businesses/:id/registrations` — need to verify this endpoint exists
  in backend `businesses/router.js`.
- After successful join → immediately `context.go('/home')` with a brief snackbar.
  User has no context about what to expect next (waiting for approval).
- **Near-duplicate code** with `SpJoinScreen` — both have identical structure, different
  endpoint + wording. Should be merged into one screen.

**Planned changes:**
- [ ] **Add `/business-search` route** to `app.dart`.
- [ ] Fix `AppColors.slate200` → `AppColors.border` or `AppColors.olive200`.
- [ ] Localize all strings.
- [ ] Verify `POST /businesses/:id/registrations` endpoint exists.
- [ ] After successful join → navigate to `/registration-success` screen instead of `/home`.
- [ ] **Merge** `BusinessSearchScreen` and `SpJoinScreen` into a single
  `BusinessSearchScreen(mode: SearchMode)` with `client` and `sp` modes.

---

### O-6. SP Join Screen (`sp_join_screen.dart`)
**Current:** Identical structure to `BusinessSearchScreen` but with different endpoint
(`/businesses/:id/join-requests`) and different wording.
**Issues:**
- **Route missing**: `/sp-join` is not registered in `app.dart`.
- All text hardcoded Hebrew:
  `'לאיזה עסק'`, `'ברצונך להצטרף?'`, `'הגש בקשה'`, `'בעל העסק יקבל התראה'`, etc.
- Uses `AppColors.slate200` in `_SpJoinSheet` — **compilation error**.
- Calls `POST /businesses/:id/join-requests` — this endpoint likely doesn't exist on
  the backend (the backend has `POST /businesses/:id/registrations` for clients and
  `POST /service-providers` for creating SP accounts). Need to verify or create it.
- After join → `context.go('/home')` with snackbar, same UX issue as `BusinessSearchScreen`.
- Near-duplicate of `BusinessSearchScreen` (code duplication).

**Planned changes:**
- [ ] **Add `/sp-join` route** to `app.dart`.
- [ ] Fix `AppColors.slate200` → `AppColors.olive200` or `AppColors.border`.
- [ ] Localize all strings.
- [ ] Verify `POST /businesses/:id/join-requests` endpoint — if missing, create it.
- [ ] After successful join → navigate to `/registration-success`.
- [ ] Merge with `BusinessSearchScreen` (see above).

---

### O-7. Registration Success Screen (NEW — currently missing)
**Route:** `/registration-success`
**Purpose:** Shown after a client or SP submits a join/registration request to a business.
Currently the app just shows a snackbar and goes to `/home`, which is jarring.

**Design:**
```
┌─────────────────────────────┐
│  [amber circle ✓ icon]      │
│                             │
│  הבקשה נשלחה! 🎉           │
│                             │
│  שלחנו בקשת הצטרפות ל      │
│  [Business Name]            │
│                             │
│  ─────────────────          │
│  בעל העסק יאשר אותה בקרוב. │
│  תקבל התראה כשזה יקרה.      │
│                             │
│  [המשך לאפליקציה]           │
└─────────────────────────────┘
```

**Widget structure:**
- `Scaffold(backgroundColor: AppColors.background)`
- Large amber success circle (88px) with white check icon (lottie animation optional)
- Title: success message (l10n)
- Card: business name + description of next steps
- Primary button: `context.go('/home')`

**Params:** accept `businessName` as route extra or path param.
**API:** none.
**Files:** new `lib/presentation/features/auth/screens/registration_success_screen.dart`.

---

### O-8. App.dart — Routing Fixes (CRITICAL)
**Current state of missing/broken routes:**

| Route | Screen | Status |
|---|---|---|
| `/splash` | `_SplashScreen` | ✅ registered (needs redesign) |
| `/onboarding` | `OnboardingScreen` | ❌ NOT in `app.dart`! |
| `/welcome` | `WelcomeScreen` | ❌ NOT in `app.dart`! |
| `/auth/login` | `LoginScreen` | ✅ registered |
| `/auth/otp-verify` | `OtpScreen` | ✅ registered |
| `/auth/notification-permission` | `NotificationPermissionScreen` | ✅ registered but never navigated to |
| `/business-search` | `BusinessSearchScreen` | ❌ NOT in `app.dart`! |
| `/sp-join` | `SpJoinScreen` | ❌ NOT in `app.dart`! |
| `/registration-success` | (new) | ❌ NOT in `app.dart`! |

**Planned changes to `app.dart` redirect logic:**
```
1. Check SharedPreferences hasLaunched
   → false → go to /onboarding
   → true → continue

2. AuthInitial/AuthLoading → /splash

3. AuthUnauthenticated → /welcome (not /auth/login)
   (WelcomeScreen handles role choice + Google sign-in)

4. AuthAuthenticated + !phoneVerified → /auth/otp-verify

5. AuthAuthenticated + phoneVerified + first login →
   role == client → /business-search
   role == serviceProvider → /sp-join
   role == businessOwner || companyOwner → /home

6. AuthAuthenticated + normal → /home
```

**Files:** `app.dart` — add 5 new `GoRoute` entries, update redirect logic.

---

## Screen Inventory & Gap Analysis

### 1. Login Screen (`login_screen.dart`) ✅ Good
**Current:** Amber circle "T" logo, two sign-in buttons (client / business).
**Issues:**
- Hard-coded subtitle `'Smart Appointment Scheduling'` — should come from l10n.
- The business owner login pops a dialog asking for a business name — works but feels clunky.

**Planned changes:**
- [ ] Move subtitle to `l10n.appSlogan` (add ARB key).
- [ ] Optionally: replace dialog with a second step/page for BO registration (non-critical for now).

---

### 2. Home Screen + Bottom Nav (`home_screen.dart`)
**Current:** Beige background, role-based tabs, drawer for SP/BO/CO.
**Issues:**
- **No hamburger icon** in the AppBar for non-client users. The drawer is attached to
  `HomeScreen.Scaffold`, but each tab screen has its own `Scaffold` with its own AppBar,
  so the leading hamburger never appears in the tab screens' AppBars.
- Bottom nav labels are hardcoded English (`'Appointments'`, `'Services'`, etc.).

**Planned changes:**
- [ ] Add `builder` parameter to `HomeScreen` Scaffold that passes an explicit hamburger
  `leading` icon to each tab screen, **OR** move AppBars out of individual screens and into
  `HomeScreen` (simpler: expose a `GlobalKey<ScaffoldState>` and add a hamburger `IconButton`
  to each screen's AppBar that opens the parent drawer via the key).
- [ ] Replace hardcoded English labels with `context.l10n.*` strings.
- [ ] Add a subtle amber indicator dot or underline on the active tab icon.

**Implementation approach (hamburger):**
```dart
// In HomeScreen, expose a scaffold key
final _scaffoldKey = GlobalKey<ScaffoldState>();

// Pass it down to each tab screen as constructor param:
// Each screen's AppBar.leading = IconButton(icon: const Icon(Icons.menu_rounded),
//   onPressed: () => _scaffoldKey.currentState?.openDrawer())
```

---

### 3. App Drawer (`app_drawer.dart`)
**Current:** User header, nav items (icons + labels), dividers, QR invite, about, logout.
**Issues:**
- **No active item highlight.** The currently selected route is not visually indicated.
- `_DrawerNavTile` uses `context.go()` which replaces the navigation stack — this is correct,
  but the drawer doesn't know which route is currently active.
- The tile trailing `chevron_right` looks mismatched with typical drawer UX.
- No distinct visual separation between the main nav section and the utility section (about/logout).

**Planned changes:**
- [ ] Inject current route string into the drawer and highlight the matching tile with
  amber background + amber icon/text color (similar to selected `ListTile` behavior).
- [ ] Remove `trailing: chevron_right` from nav tiles — cleaner look.
- [ ] Use `GoRouter.of(context).routeInformationProvider.value.uri.path` to detect active route.
- [ ] Add a top-level amber gradient header behind the user avatar area.
- [ ] Add padding between the navigation group and the utility group (About / Logout).

---

### 4. Appointments Screen (`appointments_screen.dart`)
**Current:** Two tabs (Upcoming / Past), appointment cards with status chip + date + cancel.
**Issues:**
- **Missing SP name** for BO/CO view. The card shows `clientName` but `spName` is never shown.
  The appointment entity may not expose SP name directly.
- **Appointment entity** needs `spName` field (from deep-populated `serviceProviderId.userId`).
- Cancel button is inline on the card — correct but the button style needs refinement.
- The FAB for clients (book new appointment) is correct.
- **SP role view** should show client name prominently; currently `clientName` is shown as subtitle.

**Planned changes:**
- [ ] Add `spName` to `AppointmentEntity` and `AppointmentModel`.
- [ ] Show SP name in the card subtitle for BO/CO/Client view (when relevant).
- [ ] Add `spProfileImage` to show a small avatar in the card.
- [ ] Add appointment `price` to the card (from service).
- [ ] For BO: add a "Book for client" FAB (BO can book on behalf of a client).

---

### 5. Appointment Detail Screen (`appointment_detail_screen.dart`)
**Current:** Single card with detail rows (date, time, client, notes) + cancel button.
**Issues:**
- Uses `appointmentsProvider` list and filters by ID — fragile if not yet loaded.
  Should use a dedicated `appointmentDetailProvider(id)` calling `GET /appointments/:id`.
- Missing: SP info row (name, avatar).
- Missing: Price row.
- Missing: Duration row.
- The "not found" fallback shows plain text — should route back.

**Planned changes:**
- [ ] Create `appointmentDetailProvider(String id)` →
  `FutureProvider.family` → `GET /appointments/:id`.
- [ ] Add SP row with small avatar + name.
- [ ] Add price + duration info rows.
- [ ] Add `ref.watch(appointmentDetailProvider(id))` instead of filtering the list.

**New backend check:**
- `GET /appointments/:id` → already exists in `appointments/router.js`. ✅

---

### 6. Book Appointment Screen (`book_appointment_screen.dart`)
**Current:** 4-step flow with progress bar.
**Issues:**
- Step 1 fetches services using `business.ownerId` as `spId` — only shows BO's services,
  not all SPs' services from that business. For a business with multiple SPs, client
  should see services from all SPs.
- Date/time step uses native pickers — the Figma likely shows a custom calendar grid.
  For now this is acceptable.
- The "Any provider" option defaults to `service.serviceProviderId` — this should
  actually assign to the SP with fewest bookings (server-side logic is fine, just clarify).

**Planned changes:**
- [ ] Step 1: fetch services for ALL SPs in a business, not just `ownerId`.
  → Use `GET /businesses/:id/service-providers` then for each SP fetch their services,
  OR add a backend endpoint `GET /businesses/:id/services` (aggregated).
- [ ] Show service provider name below service name in step 1 list.
- [ ] Calendar step: add a simple week-picker calendar row above the time picker for
  better UX (optional enhancement, low priority).
- [ ] Add notes field to step 4 (confirm step) before submission.

**New backend endpoint needed:**
- [ ] `GET /businesses/:businessId/services` — returns all active services from all SPs
  in the business. See [Backend Changes](#backend-changes) section.

---

### 7. Services Screen (`services_screen.dart`)
**Current:** List of SP's services with icon, name, duration/price pills.
**Issues:**
- No edit/delete action on service cards.
- BO viewing services: shows BO's own user ID as spId — BO is not an SP,
  this will return an empty list. BO should see services of all SPs under their business.
- `context.push('/services/${service.id}')` routes to `/services/:id` which has no screen.

**Planned changes:**
- [ ] Add swipe-to-delete or long-press context menu on each card (SP role only).
- [ ] For BO: show a grouped list by SP name (requires fetching all SP services).
  OR just disable the Services tab for BO and show it only for SP (simpler).
  **Decision: Keep Services tab for SP only; BO manages services via Business → SP details.**
- [ ] Add `/services/:id` route → `ServiceDetailScreen` (or re-use create screen as edit).
- [ ] The `onTap` for service card should route to an edit screen.

**New screens needed:**
- [ ] `EditServiceScreen` (or pass `serviceId` to `CreateServiceScreen` for edit mode).

---

### 8. Create Service Screen (`create_service_screen.dart`)
**Current:** Form with name, duration, price, available days (chips), notes.
**Issues:**
- Available days use hardcoded English abbreviations (`'Sun'`, `'Mon'`, etc.) — should use l10n.
- No time range picker per day (the API supports `timeRanges: [{ day, start, end }]`).
- Posts to `/service-providers/${user.id}/services` using user ID (now handled by
  `resolveSpDoc` on backend, so this should work).

**Planned changes:**
- [ ] Add time range inputs per day (appears after a day chip is selected).
- [ ] Use l10n day abbreviations.
- [ ] Support **edit mode**: accept optional `serviceId` param → pre-fill form →
  `PUT /service-providers/:spId/services/:serviceId`.

---

### 9. Stats Screen (`stats_screen.dart`)
**Current:** Dark olive revenue card, 2×2 stat grid, bar chart.
**Issues:**
- Period selector at top takes significant vertical space. Consider moving it into the AppBar
  as a trailing segmented control.
- Bar chart only shows completed vs canceled. Should show a time-series breakdown.
- No date picker — period is `daily`/`monthly`/`yearly` but no date is chosen; defaults to
  today. A date picker button should be added next to the period selector.
- The chart title `'Appointments Overview'` is hardcoded English.

**Planned changes:**
- [ ] Add a date picker `IconButton` in AppBar to select the reference date
  (default: today). Pass as param to `statsProvider`.
- [ ] Move period selector into a `Row` with the date picker for compact layout.
- [ ] Localize chart labels and title.
- [ ] For SP: show `newClientsCount` prominently.
- [ ] Add total revenue trend: simple line below the dark card showing % vs previous period.

---

### 10. Profile Screen (`profile_screen.dart`)
**Current:** Large avatar, role badge, language toggle, phone, notifications, about, logout.
**Issues:**
- `'Are you sure you want to log out?'` is hardcoded English — should be l10n.
- Notifications tile routes to nothing (`onTap: () {}`).
- No way to edit name/phone from profile.
- The profile image only shows a Google avatar — no way to upload a custom one.

**Planned changes:**
- [ ] Localize logout confirmation.
- [ ] Notifications tile → navigate to `/notifications` (or show a coming-soon snackbar).
- [ ] Add an "Edit profile" tile → `EditProfileScreen` (name, phone fields) →
  `PUT /users/me` (check if this endpoint exists).
- [ ] Profile image tap → show options: "View", "Change photo" (requires image upload backend).

**New backend check:**
- `PUT /users/:id` → need to verify endpoint exists in `users/router.js`.

---

### 11. Business Screen (`business_screen.dart`)
**Current:** BO view: info card + 3 action tiles (Clients, SPs, Settings).
CO view: flat list of all businesses.
**Issues:**
- The BO info card is minimal — just logo + name. Should show more (address, status, SP count).
- Action tiles are plain `ListTile` with `chevron_right` — should be more prominent cards.
- CO list has no search/filter.
- Tapping a business in CO list routes to `/admin/businesses/:id` which has no screen.

**Planned changes:**
- [ ] Replace `_ActionTile` with styled `_MenuCard` widgets (icon container + amber border
  on the left, title, subtitle with count, chevron).
- [ ] Add SP count + client count to the BO info card (fetch from providers).
- [ ] CO: add search bar above the businesses list.
- [ ] CO: add `/admin/businesses/:id` route → `AdminBusinessDetailScreen` (shows business
  info + management actions: disable/enable, toggle reminders, view SPs).

---

### 12. Business Settings Screen (`business_settings_screen.dart`)
**Current:** Logo placeholder with edit icon, business name field, reminders toggle, save.
**Issues:**
- Logo edit button does nothing (camera icon but no `onTap`).
- No feedback when save fails with a specific error.
- Address editing is not supported (would need a map picker or autocomplete).

**Planned changes:**
- [ ] Logo edit: on tap → image picker → upload to backend → `PUT /businesses/:id`.
  (Requires adding image upload support; out of scope for now — add TODO.)
- [ ] Show address field as read-only (with note "contact support to update").
- [ ] Better error display: inline error text below form on failure.

---

### 13. Clients Screen (`clients_screen.dart`)
**Current:** Shows only **pending** registrations. Search bar, approve/reject buttons.
**Issues:**
- **Major gap**: Only pending registrations are shown. There's no way to view approved/active
  clients. The screen title says "Clients" but it behaves like "Pending Requests".
- No tabs to separate Pending vs Approved clients.
- The backend `GET /businesses/:id/registrations` returns users with `status = 'pending'`.
  Need a separate call for approved clients.

**Planned changes:**
- [ ] Add `TabBar` with two tabs: **Pending** (current) and **Clients** (approved).
- [ ] Create `approvedClientsProvider(businessId)`:
  → calls a new backend endpoint `GET /businesses/:id/clients` (returns approved users).
  → OR filter from `GET /users?businessId=:id&status=approved` if such endpoint exists.
- [ ] Show approved client cards with just avatar + name + email (no approve/reject buttons).
- [ ] Add client appointment count in the approved client card.

**New backend endpoint needed:**
- [ ] `GET /businesses/:businessId/clients` — returns users with `status = 'approved'`
  for the given business.

---

### 14. Service Providers Screen (`service_providers_screen.dart`)
**Current:** SP list with avatar, name, active/inactive badge; FAB opens invite dialog.
**Issues:**
- The invite dialog sends an email invite — the backend `POST /businesses/:id/invite-sp` may
  not exist yet (only the alias was added). Need to verify the actual inviteSp handler.
- SP cards are plain `ListTile` — should show more info (specialty, service count).
- No action to activate/deactivate a SP.
- No tap action on SP card.

**Planned changes:**
- [ ] Add tap on SP card → show SP detail bottom sheet with:
  services list, appointment history button, deactivate toggle.
- [ ] Restyle SP card to show specialty + `N services` count below name.
- [ ] Add `PUT /businesses/:id/service-providers/:spId/deactivate` action
  (check if endpoint exists).
- [ ] Verify `POST /businesses/:id/invite-sp` handler exists on backend.

---

### 15. Drawer — Active State Highlight
**Current:** No active item is highlighted.
**Planned changes:**
- [ ] In `_DrawerNavTile`, compare `route` to current GoRouter location.
  Use `GoRouterState.of(context).matchedLocation` to determine active route.
- [ ] Active tile: amber 10% opacity background + amber icon + amber text.

---

## New Screens Needed

### 16. Edit Profile Screen (NEW)
**Route:** `/profile/edit`
**Widgets:** Avatar with edit icon, first name field, last name field, phone field with
country code picker, save button.
**API:** `PUT /users/me` → needs to be verified/created.

---

### 17. Admin Business Detail Screen (NEW — CO role only)
**Route:** `/admin/businesses/:id`
**Widgets:** Business info card, stats summary, SP list, toggle disabled/reminders buttons.
**API:** `GET /businesses/:id`, `PUT /businesses/:id/disable`,
`PUT /businesses/:id/reminders`.

---

### 18. Service Detail / Edit Screen (NEW)
**Route:** `/services/:id`
**Reuses:** `CreateServiceScreen` in edit mode, or a new `ServiceDetailScreen`.
**API:** `GET /service-providers/:spId/services/:serviceId`,
`PUT /service-providers/:spId/services/:serviceId`.

---

## Backend Changes Needed

| # | Endpoint | Description | Priority |
|---|---|---|---|
| 1 | `GET /businesses/:id/services` | Aggregated services from all SPs in business | HIGH (booking step 1) |
| 2 | `GET /businesses/:id/clients` | Approved clients for a business | HIGH (Clients screen) |
| 3 | `PUT /users/me` | Update own profile (name, phone) | MEDIUM |
| 4 | `POST /businesses/:id/invite-sp` | Invite a SP by name+email | MEDIUM (verify exists) |
| 5 | `GET /appointments/:id` | Single appointment detail | LOW (already exists ✅) |
| 6 | `DELETE /service-providers/:spId/services/:id` | Delete a service | MEDIUM |

---

## TODO List (Prioritized)

### P0 — Critical fixes (broken/crashing)

- [ ] **`AppColors.slate*` compilation error** — `AppColors.slate900` and `AppColors.slate200`
  used in `welcome_screen.dart`, `business_search_screen.dart`, `sp_join_screen.dart` but not
  defined in `app_colors.dart`. **App will not compile.** Fix: add aliases to `app_colors.dart`.

- [ ] **Missing GoRouter routes** — `/onboarding`, `/welcome`, `/business-search`, `/sp-join`
  and `/registration-success` are not registered in `app.dart`. Any navigation to these routes
  causes a GoRouter crash. Fix: add all 5 `GoRoute` entries + update redirect logic.

- [ ] **OTP → notification-permission skipped** — After phone verification the app jumps
  directly to `/home`, bypassing `NotificationPermissionScreen`. Fix `verifyOtp` success path.

- [ ] **Notification denial leaves user stuck** — Denying permission shows a snackbar but
  never navigates to `/home`. Fix: always navigate on completion regardless of outcome.

- [ ] **Hamburger in AppBar** — Non-client users can't easily open the drawer.
  Fix: pass `GlobalKey<ScaffoldState>` to tab screens or add drawer-opening `IconButton`
  to each screen's `AppBar.leading` automatically (via `HomeScreen`).

- [ ] **Appointment detail uses list filter** — Replace with dedicated
  `appointmentDetailProvider(id)` and `GET /appointments/:id`.

- [ ] **Clients Screen tabs** — Add Pending / Approved tabs. Add backend
  `GET /businesses/:id/clients` endpoint and `approvedClientsProvider`.

- [ ] **Services for booking** — Fix step 1 to show services from all business SPs,
  not just `ownerId`. Add `GET /businesses/:id/services` backend endpoint.

### P1 — Important UI gaps

- [ ] **Splash screen redesign** — Extract `_SplashScreen` to its own file, add Tori logo
  + amber gradient, animate on entry.

- [ ] **Onboarding retheme** — Replace dark slide backgrounds with warm beige/olive/amber
  palette. Wire `_SlideData.titleEn` to locale.

- [ ] **Welcome screen strings** — Move all hardcoded Hebrew to `context.l10n.*`. Fix
  "already have account" button behaviour.

- [ ] **OTP strings** — Localize all OTP screen Hebrew text.

- [ ] **Notification permission** — Localize button, add Skip option, style with beige bg.

- [ ] **BusinessSearch / SpJoin merge** — Merge the two nearly-identical screens into one.

- [ ] **Registration Success screen** — New `/registration-success` screen with animated
  checkmark, business name, next-steps instructions, and a "continue to app" button.

- [ ] **Drawer active state** — Highlight currently active route item in amber.

- [ ] **Bottom nav labels** — Replace hardcoded English with l10n strings.

- [ ] **Appointment cards** — Add SP name + price to appointment cards (all roles).

- [ ] **Stats date picker** — Add date selector `IconButton` to stats screen AppBar.

- [ ] **Business Screen action tiles** — Replace plain `_ActionTile` with richer
  card widgets (icon container, subtitle with counts).

- [ ] **Profile logout confirm** — Localize `'Are you sure you want to log out?'`.

### P2 — Enhancements

- [ ] **Create Service — time ranges** — Add per-day time range inputs.
- [ ] **Service edit mode** — `CreateServiceScreen` accepting optional `serviceId`.
- [ ] **Service delete** — Swipe-to-delete or long-press menu.
- [ ] **SP card detail** — Tap on SP card opens bottom sheet with details.
- [ ] **Edit Profile screen** — `/profile/edit` route + `PUT /users/me`.
- [ ] **Admin Business Detail screen** — `/admin/businesses/:id` for CO role.
- [ ] **Stats localization** — Move hardcoded chart labels to l10n.
- [ ] **Stats period compact layout** — Period selector + date picker in a compact `Row`.

### P3 — Polish

- [ ] **Login subtitle** — Move to l10n.
- [ ] **Business Settings logo upload** — Add image picker (requires backend upload endpoint).
- [ ] **Address editing** — Add read-only address field with "contact support" note.
- [ ] **Notes field in booking step 4** — Add optional notes textarea before confirm.
- [ ] **Week calendar in booking step 3** — Replace native date picker with inline calendar row.

---

## Implementation Order

```
Phase 1 (P0 — Critical):
  1. Hamburger AppBar fix (home_screen.dart)
  2. appointmentDetailProvider + GET /appointments/:id usage
  3. Backend: GET /businesses/:id/clients endpoint
  4. Clients screen: Pending + Approved tabs
  5. Backend: GET /businesses/:id/services endpoint
  6. Book appointment step 1: use business-wide services

Phase 2 (P1 — Important):
  7. Drawer active state highlight
  8. Bottom nav l10n labels
  9. Appointment card: add spName + price
  10. Stats date picker
  11. Business screen: styled action cards

Phase 3 (P2/P3 — Enhancements):
  12. Service edit + delete
  13. Create Service: time ranges
  14. Edit Profile screen + PUT /users/me backend
  15. Admin Business Detail screen
  16. SP card detail bottom sheet
  17. All remaining polish items
```

---

## Files to Modify per Phase

### Phase 1
| File | Change |
|---|---|
| `home_screen.dart` | Pass scaffold key / hamburger icon to tab screens |
| `appointments_screen.dart` | (minor — appointment card already works) |
| `appointment_detail_screen.dart` | New `appointmentDetailProvider`, remove list filter |
| `appointments_provider.dart` | Add `appointmentDetailProvider(id)` |
| `clients_screen.dart` | Add TabBar, add `approvedClientsProvider` |
| `business_provider.dart` | Add `approvedClientsProvider(businessId)` |
| `book_appointment_screen.dart` | Step 1: use business services, not ownerId services |
| `tori-backend/modules/businesses/service.js` | Add `getBusinessClients()` + `getBusinessServices()` |
| `tori-backend/modules/businesses/controller.js` | Add controllers for new endpoints |
| `tori-backend/modules/businesses/router.js` | Add `GET /:id/clients`, `GET /:id/services` routes |

### Phase 2
| File | Change |
|---|---|
| `app_drawer.dart` | Active route detection + amber highlight |
| `home_screen.dart` | Bottom nav l10n labels |
| `appointments_screen.dart` | Add `spName` + `price` to card display |
| `appointment_entity.dart` | Add `spName` field |
| `appointment_model.dart` | Parse `spName` from nested populate |
| `stats_screen.dart` | Add date picker + compact period row |
| `business_screen.dart` | Styled `_MenuCard` action tiles |

### Phase 3
| File | Change |
|---|---|
| `create_service_screen.dart` | Edit mode + time ranges + l10n days |
| `services_screen.dart` | Swipe-to-delete, onTap edit |
| `app.dart` | Add new routes (`/profile/edit`, `/services/:id`, `/admin/businesses/:id`) |
| `profile_screen.dart` | Edit profile tile, l10n logout confirm |
| New: `edit_profile_screen.dart` | Edit name + phone |
| New: `admin_business_detail_screen.dart` | CO admin panel |
| `tori-backend/modules/users/router.js` | `PUT /users/me` endpoint |

---

## Notes on Figma Accuracy

The user mentioned the Figma design "is not 100% accurate" and requires judgment calls.
Based on the established design language:

1. **Keep** the current warm beige/olive/amber palette — it's correctly implemented.
2. **Keep** the card-based layout with 16px radius and subtle borders.
3. **Add** visual richness to the Business screen action tiles (they're too plain currently).
4. **Add** SP avatars to appointment cards for SP/client-name context.
5. **Ensure** all screens have the hamburger menu accessible in their AppBars.
6. **Ensure** the drawer shows the active screen highlighted in amber.


