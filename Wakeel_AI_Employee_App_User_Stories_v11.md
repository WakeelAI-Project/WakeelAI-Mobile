# **WAKEEL AI** 

## **Employee Mobile App** 

User Stories & Task Backlog — Version 11 

_Aligned to API Documentation v8 and Backlog v10_ 

8 stories · Home, Profile, AI Chat, Voice, Leave Requests, Documents, Settings, and Navigation Shell 

_AI-Powered HR & Legal Compliance Assistant for Egyptian SMEs_ 

### What Changed in v11 

This revision reconciles the Employee Mobile App user stories against API Documentation v8 and Backlog v10. It corrects one outdated endpoint reference, adds logic the mobile app was missing, and flags contract gaps that still need to be closed in the API documentation / backlog (owned by the backend team, not fixed in this document). 

**[UPDATED]** — an existing line changed to match API v8 (e.g. an endpoint rename). 

**[NEW]** — a task or acceptance criterion this document was missing. 

**[GAP – BACKEND]** — the mobile team needs this from the API/backlog, and it isn't specified yet. Flagged for the backend team to close in API Documentation v8 / Backlog v10, not resolved here. 

### Contents 

E1  Employee home dashboard 

- E2  Profile screen 

E3  AI chat with citations and structured inputs  [UPDATED] 

E4  Voice input in chat  [UPDATED] 

E5  Leave requests: chat flow + My Leave Requests  [UPDATED] 

E6  My Documents  [UPDATED] 

E7  Settings, language & session 

E8  App shell / bottom navigation 

Appendix A  Consolidated Gaps for Backend (API Documentation & Backlog) 

_Scope: everything the Employee role can do per the Wakeel AI API (v8) — own profile, leave balances, leave requests, own documents, and the AI assistant (text + voice). HR and Owner capabilities live in the separate Web Dashboard backlog and are out of scope for this app._ 

##### **STORY E1** 

### Employee home dashboard 

_As an employee, I want a home dashboard showing my leave balances and quick access to every feature, so that I can see my status at a glance and get to what I need in one tap._ 

##### **DEFINITION OF DONE** 

The home screen replaces the current placeholder and shows my live leave balances and a way to reach every other screen. Data comes from the real API and refreshes correctly. 

- Home shows my Annual/Sick/Unpaid leave balances pulled from GET /me. 

- Home provides quick navigation to AI Chat, My Leave Requests, My Documents, and Profile. 

- Balances refresh on pull-to-refresh and when returning from a flow that could change them. 

- Loading, error (with retry), and empty states are handled. 

- Changes to balances elsewhere in the app (e.g. after a leave approval) are reflected on next visit without a manual restart. 

##### **TASKS** 

- Replace the placeholder EmployeeHomeScreen with the real Home layout: app bar (greeting + avatar), scrollable body, quick-nav section. 

- Wire a GET /me provider (Riverpod) returning profile + leave_balances. 

- Build a leave-balance stat card widget per type (Annual/Sick/Unpaid): remaining/total, progress bar, low-balance color state using the design system's status tokens. 

- Build the quick-navigation section (Chat / My Leave Requests / My Documents / Profile) using the design system's button variants. 

- Loading skeleton on cold start, retry-capable error view, pull-to-refresh. 

- Cache the GET /me response; invalidate on pull-to-refresh and on returning from Leave/Chat flows. 

- Widget tests: loading → success renders balances; error → retry; pull-to-refresh triggers refetch. 

##### **STORY E2** 

### Profile screen 

_As an employee, I want to view my profile details, so that I can confirm my job info is correct without asking HR._ 

##### **DEFINITION OF DONE** 

- Profile shows full name, email, job title, department, hire date, and salary from GET /me. 

- Logout is reachable from Profile and works correctly. 

- Loading and error states are handled. 

- Profile data is not re-fetched redundantly if Home already loaded it this session. 

##### **TASKS** 

- Build the Profile screen UI: avatar/initials, name, job title, department chip, formatted hire date, EGP-formatted salary. 

- Reuse the GET /me provider from Story E1 — no duplicate network call. 

- Loading skeleton + retry error view consistent with shared widgets. 

- Add a Logout action with a confirmation dialog, reusing the existing auth logout flow. 

- Wire Profile as reachable from Home's quick-nav and from the app shell (Story E8). 

- Widget tests: renders fields from a GET /me fixture; logout triggers confirmation, clears the stored token, and redirects to Login. 

##### **STORY E3** 

### AI chat with citations and structured inputs 

_As an employee, I want to chat with the AI assistant about labor law, company policy, and my own data, so that I get instant, cited answers without waiting on HR._ 

##### **DEFINITION OF DONE** 

- **[UPDATED]** Messages send via POST /api/ai/chat and render with citations. 

- History loads via GET /chat/history and survives app restart. 

- Missing-field prompts render as real input controls, not plain text. 

- **[UPDATED]** Calculation and leave-draft result cards render correctly, with visible actions driven by the card's own actions[] list. 

- **[NEW]** The app's current language setting (AR/EN) is sent with every chat message. 

- Rate limiting (429) degrades gracefully. 

##### **TASKS** 

- Build the Chat screen: message list (user/AI bubbles), timestamps, auto-scroll, empty state with sample prompts in Arabic and English. 

- Build the composer: multiline input, send button disabled while empty, loading/error affordances. 

- **[UPDATED]** Wire POST /api/ai/chat: per-message loading shimmer, optimistic render of the user's own message with rollback on failure. 

- **[NEW]** Include the current app language (from Story E7's language setting) as the language field on every POST /api/ai/chat request; keep it in sync when the user switches language mid-session. 

- Wire GET /chat/history: paginated load-older on scroll-up, conversation restored after app restart, local cache of the last page. 

- **[UPDATED]** Persist and resend conversation_id from the response on every subsequent POST /api/ai/chat and on GET /chat/history for that thread; start a new thread by omitting conversation_id. 

- Render sources[]/citations as chips using the seal_mark component — the design system's dedicated trust-signal element, not a generic badge. 

- Progressive typewriter-style reveal for AI replies (client-side only — the API is non-streaming). 

- Build the shared structured-input renderer: text/number/dropdown/date/file controls driven by missing_fields descriptors, submitted back via field_values. 

- **[UPDATED]** Build the result-card renderer: calculation card (result + breakdown) and leave_draft card. Read each card's actions[] array to decide which buttons (e.g. Submit, Cancel) are shown/enabled, rather than always showing both — wire the shown actions to the endpoints in Story E5. 

- Rate-limit handling: 429 → countdown toast using the Retry-After header. 

- Inline error banner with retry on a failed send. 

- **[GAP – BACKEND]** Confirm the shape of field_values with the AI-NODE team before implementation — currently unspecified in the API documentation (see Appendix A). 

- **[UPDATED]** Widget/integration tests: send → reply renders with citations; missing_fields renders the correct input types; leave_draft card actions call only the endpoints listed in its own actions[]; language field reflects the active app locale; 429 shows the countdown. 

##### **STORY E4** 

### Voice input in chat 

_As an employee, I want to ask the AI a question by voice, so that I can get answers hands-free when I'm on the floor, not at a desk._ 

##### **DEFINITION OF DONE** 

- Mic button in the composer starts/stops recording with a visible timer and waveform. 

- Transcription (AR/EN) lands in the composer for review/edit before send — never auto-sent. 

- Permission denial is handled gracefully with a path to Settings. 

- **[UPDATED]** The same POST /api/ai/chat flow is reused — no separate backend path. 

##### **TASKS** 

- Add a mic button to the composer with the iOS/Android runtime permission flow and a graceful denial path (settings deep-link + explanation dialog). 

- Build the recording UI: elapsed timer, waveform/animation, cancel and confirm actions. 

- Integrate speech_to_text with Arabic + English locale support (following the app's current language setting, with an in-flow override). 

- **[UPDATED]** Land the transcription in the composer text field for review — reuse the Story E3 send flow (including the language field on POST /api/ai/chat), don't build a second path. 

- Accessibility: mic button has a semantic label and a minimum 40×40 hit target per the design system. 

- Widget tests: permission-denied path shows the explanation dialog; transcription populates the composer without sending; cancel discards the recording. 

##### **STORY E5** 

### Leave requests: chat flow + My Leave Requests 

_As an employee, I want to request leave through the AI chat and track every request I've made, so that I don't have to email HR and lose track of what's approved._ 

##### **DEFINITION OF DONE** 

- **[UPDATED]** A leave Draft can be created two ways: (a) directly via POST /leave-requests (multipart, with attachment inline when required), used by the standalone leave-request screen; and (b) through AI chat, where the AI creates the draft server-side via its own internal API — the client's role in that path is only to upload the attachment first and hand the AI its URL. 

- **[NEW]** For the chat-driven Sick-leave flow, the medical report is uploaded via POST /api/leaverequests/attachments before the draft is requested, and the returned url (never the attachment_id) is passed back to the AI via field_values. 

- **[UPDATED]** Submit and Cancel work from the leave_draft chat card, gated by that card's own actions[] list (see Story E3). 

- “My Leave Requests” lists all my requests (every status) from the employee-scoped GET /leaverequests, with filtering and pagination. 

- **[UPDATED]** Sick leave without an attachment is blocked before it ever reaches the server, in both the direct-form flow and the chat flow. 

##### **TASKS** 

- **[UPDATED]** Reconcile the existing (unpushed) leave-request screen against the current design tokens and the chat-driven leave_draft flow — confirm it wires to POST /leave-requests (multipart when an attachment is present) and produces the same draft object the chat card expects. This is the direct-entry path; keep it clearly separate from the chat-driven path below. 

- Build the leave-type dropdown (Annual/Sick/Unpaid), date-range picker (locale-aware, Friday/Saturday weekend display), optional reason field, and a medical-report picker (camera/gallery/PDF, shown only for Sick) with client-side type/size validation (PDF/JPG/PNG, ≤10MB), used by the direct-entry screen. 

- **[NEW]** Build the pre-chat medical-report upload step for the chat-driven Sick-leave flow: when the AI's missing_fields prompt asks for a medical report, launch the same file picker/validation used in the direct-entry screen, call POST /api/leave-requests/attachments, and hold onto the returned url (discard the attachment_id — it is not sent to the AI). 

- **[NEW]** Submit the structured input back to the AI via field_values, including the attachment url gathered above for Sick leave; confirm the exact field_values shape with the AI-NODE team (see Appendix A gap). 

- **[UPDATED]** Render the Draft response (from either path) as a summary card (type, dates, computed days, attachment name) with Submit (PATCH /leave-requests/{id}/submit) and Cancel (DELETE /leave-requests/{id}) actions, shown/enabled per the card's actions[] where the card came from chat. 

- Build “My Leave Requests” fed by the employee-scoped GET /leave-requests: status filter chips (All/Draft/Pending/Approved/Rejected/Cancelled), card list (type icon, date range, days, status badge, hr_note/rejection reason when present, attachment thumbnail). 

- Pull-to-refresh, scroll pagination, empty state with an “Ask the assistant to request leave” shortcut into Chat. 

- Draft cards expose Submit/Cancel inline; Pending/Approved/Rejected/Cancelled cards are readonly. 

- Add “My Leave Requests” to Home's quick-nav and the app shell. 

- **[GAP – BACKEND]** Confirm the GET /leave-requests response schema with backend before building the card list — hr_note, rejection reason, and attachment reference fields are not yet documented (see Appendix A). 

- **[UPDATED]** Widget/integration tests: sick leave without an attachment is blocked client-side in both flows (and the 422 is surfaced if it still reaches the server); the chat flow refuses to call the leave-request tool without a url on file for Sick leave; Submit flips Draft→Pending in the UI; Cancel flips Draft→Cancelled and keeps it visible in history; status filter chips filter correctly. 

##### **STORY E6** 

### My Documents 

_As an employee, I want to view and download my own generated documents, so that I always have access to my contracts and letters._ 

##### **DEFINITION OF DONE** 

- Documents list is scoped to me via GET /documents (server-enforced), paginated. 

- **[NEW]** Document detail is fetched via GET /documents/{doc_id}, not read off the list payload. 

- Final documents preview and download as PDF; Draft documents show a “being reviewed” state with no download. 

- List survives brief offline periods with a stale indicator. 

##### **TASKS** 

- Build the Documents screen: list from GET /documents (employee-scoped) — card per document (type icon, status badge, created date), infinite-scroll pagination, empty state, pull-to-refresh, filter chips (All/Contracts/Warning/Termination). 

- **[UPDATED]** Build the Document detail screen: fetch the single document via GET /documents/{doc_id} on entry (don't rely on the list item's fields alone), then render metadata + PDF preview (pdf_url) in an in-app viewer with pinch-zoom. 

- Download action saving to device storage with a visible success path, plus OS share-sheet integration. 

- Draft documents (pdf_url = null) show a “Being reviewed by HR” state with no download affordance. 

- Offline-cached document list with a stale indicator. 

- Add “My Documents” to Home's quick-nav and the app shell. 

- **[GAP – BACKEND]** Confirm the GET /documents and GET /documents/{doc_id} response schemas and the canonical documentType enum with backend before finalizing the filter chips and detail fields — not yet documented (see Appendix A). 

- **[UPDATED]** Widget/integration tests: Final document shows download/share; Draft shows the reviewing state with no download button; scroll triggers next-page load; detail screen fetches by id rather than reusing stale list data. 

##### **STORY E7** 

### Settings, language & session 

_As an employee, I want to control my app language and theme and manage my session, so that the app matches how I read and I stay in control of being logged in._ 

##### **DEFINITION OF DONE** 

- **[UPDATED]** Language toggle (AR/EN) switches locale and layout direction (RTL/LTR) immediately, app-wide, including the language sent on every chat message (Story E3). 

- Theme selector (light/dark/high-contrast) applies the correct design-system token set. 

- Logout clears my session and returns me to Login. 

- Language and theme choices persist across app restarts. 

##### **TASKS** 

- Build the Settings screen (reachable from Profile or the app shell): language toggle, theme selector, app version display. 

- Wire the language toggle to the existing intl/flutter_localizations setup; verify RTL applies correctly across every built screen (Home, Chat, Leave, Documents, Profile) using logical start/end properties per the design system. 

- **[NEW]** Expose the current language selection to the Chat feature (Story E3) so it can be included on every POST /api/ai/chat request. 

- Wire the theme selector to the existing theme-provider (light/dark/high-contrast tokens already defined in core/theme/). 

- Logout action with confirmation, clearing secure storage and redirecting to Login. 

- Persist language/theme choice locally so it survives app restart. 

- **[UPDATED]** Widget tests: language toggle flips locale and direction and updates the language sent with new chat messages; theme selector applies the correct tokens; logout clears the token. 

##### **STORY E8** 

### App shell / bottom navigation 

_As an employee, I want consistent navigation across the app, so that I can move between Home, Chat, Leave, and Documents without getting lost._ 

##### **DEFINITION OF DONE** 

- Bottom navigation (Home, Chat, Leaves, Documents) plus a Profile/Settings entry is present on every screen. 

- Active tab is visually highlighted using the design system's signature motion. 

- Each tab preserves its own navigation stack and scroll position. 

- No HR/Owner-only concept is ever reachable (defensive, since this is an Employee-only app). 

##### **TASKS** 

- Build the bottom-navigation shell (Home, Chat, Leaves, Documents) — implementing for real the skeleton originally stubbed in the auth work, replacing today's single-screen placeholder routing. 

- Apply the design system's --motion-slow spring shared-element highlight to the active-tab indicator. 

- Wire go_router nested routes so each tab keeps its own stack (e.g. drilling into a document detail doesn't lose the Documents tab's scroll position). 

- Confirm no HR/Owner-only screen or data path is exposed anywhere in navigation. 

- Widget tests: tab switch preserves per-tab navigation stack; a deep link to a specific tab lands correctly after login. 

##### **APPENDIX A** 

### Consolidated Gaps for Backend (API Documentation & Backlog) 

Everything below is needed by this app but is not yet specified in API Documentation v8 or Backlog v10. Flagged here so the backend team can close it in those documents — nothing in this appendix is resolved by this document. 

- 

#### **GET /me response schema** 

   - No formal field-by-field schema exists for this endpoint, despite Home (E1) and Profile (E2) depending on it for full_name, email, job_title, department, hire_date, salary, and the three leave balances (Annual/Sick/Unpaid). 

- 

#### **field_values request shape** 

POST /api/ai/chat accepts a field_values payload (used to answer missing_fields prompts and to pass the attachment url for Sick leave), but its shape is never defined — e.g. whether it's a flat object keyed by field_name or an array matching missing_fields. 

- 

#### **result_card.actions[] semantics** 

The leave_draft, calculation, and document_draft result cards all carry an actions array, but no document lists the possible action values or what each one should do client-side. 

#### – **GET /leave-requests response schema** 

Story E5 needs hr_note, rejection reason, and an attachment reference/thumbnail per request; none of these fields are documented on this endpoint. 

- **GET /documents and GET /documents/{doc_id} response schemas** 

Story E6 needs pdf_url, a draft/final status flag, document type, and created date; none of these are specified. 

#### – 

#### **Canonical documentType enum** 

API v8 §10.6 only gives examples ("Contract", "OfferLetter"), while the mobile filter chips reference Contracts/Warning/Termination — there is no single authoritative list shared across services. 

