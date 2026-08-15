# **Wakeel AI — Detailed MVP Backlog** 

**Version 10 — Backend-Verified** (updated from Version 9 — Internal AI Leave Workflow Aligned) 

Tracks: [BE] .NET 10 | [FE] React Web | [MOB] Flutter App | [AI-NODE] Node.js AI Service 

**<mark>Update basis:</mark>** <mark>every [BE] item was re-verified directly against the .NET backend codebase. Statuses were corrected where the previous backlog did not match the actual implementation. Story IDs, sprint structure, and terminology are preserved from Version 9. Status legend:</mark> **<mark>[Implemented] [Partially Implemented] [Not Implemented] [Implemented Differently] [Not Verified]</mark>** <mark>.</mark> 

## **Sprint 1 & 2: Foundations & Core HR Admin** 

Verified against the codebase — these stories are implemented in the .NET codebase and React web dashboard, with one correction: 

- Story 1.1-1.4: Auth & RBAC **[Completed — Verified]** (register-company, login with must_change_password, refresh rotation, logout, change-password, role-based authorization) 

- Story 1.9 & 2.8: Company Profile **[Completed — Verified]** (GET/PUT profile, logo upload ≤5MB) 

- Story 2.4: HR Accounts **[Completed — Verified]** (invite HR_Manager only, list users, PATCH status — note: status change is Company_Owner only) 

- Story 2.5: Department Management **[Completed — Verified]** (full CRUD incl. 409 department_in_use guard) 

- Story 2.6: Employee Management **[Completed — Verified]** (create/list/detail/update/deactivate + GET /api/employees/me self-service) 

- Story 2.7: Audit Logging **[NOT IMPLEMENTED — status corrected; REOPENED → moved to Sprint 4, Story 4.2]** 

   - Verified: no <mark>`AuditLog`</mark> entity, no migration, no <mark>`AuditLogsController`</mark> , no <mark>`GET /api/audit-logs` ,</mark> and no audit-write hooks exist anywhere in the backend. The previous [Completed] status was incorrect. 

## **Sprint 3: The Great AI Migration & M2M Auth (Days 10-14)** 

Sprint Goal: Move AI orchestration out of .NET into a standalone Node.js service. Establish Machine-to-Machine (M2M) authentication. Build the API Gateway routing for chat, internal context endpoints, internal leave APIs, and the LangChain RAG pipeline. 

### **Story 3.1: AI Service Foundation & M2M Security** 

- [BE] Implement X-Internal-API-Key middleware in .NET. Must secure all server-toserver endpoints (bypassing JWT). **[Partially Implemented]** — middleware exists and secures the internal context/template/leave paths, **but** it protects the path <mark>`/api/documents/save`</mark> while the actual route is <mark>`/api/ai/documents/save` ,</mark> leaving the real document-save endpoint unprotected. Fix tracked in Sprint 4 (Story 4.3, new). 

- [AI-NODE] Scaffold the Node.js + Express service. Strictly JavaScript (ES Modules). **[Implemented]** 

- [AI-NODE] Winston logging + Zod validation. **[Implemented]** 

- [AI-NODE] config/env.js validation, fail-fast. **[Implemented]** 

- [AI-NODE] GET /health. **[Implemented]** 

### **Story 3.2: Internal Context Integrations & Pre-Chat Uploads (.NET Data Access)** 

- [BE] DOCUMENT_TEMPLATE and GENERATED_DOCUMENT EF Core migrations. **[Implemented]** (entities + configurations exist; note: GeneratedDocument still lacks the columns required by the public documents contract — see Story 4.1a) 

- [BE] GET /api/ai/employee-context (M2M). **[Implemented]** — returns snake_case profile + 3-type leave balances. 

- [BE] GET /api/ai/company-context (M2M). **[Implemented]** — returns snake_case company profile + policy_available. 

- [BE] GET /api/ai/templates/active?documentType= (M2M). **[Implemented]** 

- [BE] POST /api/documents/save (M2M). **[Implemented Differently]** — actual route is <mark>`POST /api/ai/documents/save` ;</mark> response is <mark>`{ success, documentId, status`</mark> `}` ; <mark>`template_id` /</mark> <mark>`metadata`</mark> accepted but not persisted; endpoint is not covered by the M2M middleware (see Story 4.3, new). 

- [BE] POST /api/leave-requests/attachments (JWT). **[Implemented]** — returns 201 { attachment_id, url }. 

- [AI-NODE] WakeelApiClient module with internal auth headers. **[Implemented]** — note: its document-api.js still calls the old <mark>`/api/documents/save`</mark> route (see Story 4.3, new). 

### **Story 3.3: Chat History Gateway & Mongo Persistence** 

- [AI-NODE] MongoDB Atlas: Conversations and Messages (nested Citations). **[Implemented]** 

- [AI-NODE] GET /api/ai/chat/history. **[Implemented]** 

- [BE] Refactor GET /chat/history as API Gateway. **[Implemented]** (also GET /api/ai/chat/conversations gateway) 

- [BE] Refactor POST /chat/ask as API Gateway owning conversationId lifecycle. **[Implemented]** (route: POST /api/ai/chat) 

- [BE] .NET HttpClient with strict minimum 60-second timeout. **[Implemented]** 

### **Story 3.4: LLM Orchestration & RAG Pipeline (Node.js)** 

- [AI-NODE] LangChain chat-model and embedding abstractions. **[Implemented]** 

- [BE] COMPANY_HANDBOOK EF Core migration. **[Implemented]** 

- [AI-NODE] POST /api/knowledge/ingest. **[Implemented]** 

- [BE] Hook policy upload endpoint → forward raw text to Node.js ingestion. **[Implemented]** (actual route: POST /api/company/policies; requires pdf + title; fire-and-forget forwarding) 

- [AI-NODE] searchKnowledge scoped by companyId or null (public law). **[Implemented]** 

### **Story 3.5: AI Skills, Tools & Internal Leave API** 

- [AI-NODE] Skill & Tool Registries. **[Implemented]** 

- [AI-NODE] Calculator Skill (pure JS deterministic calculations). **[Implemented]** 

- [AI-NODE] Document Generation Skill (scaffold). **[Implemented]** 

- [BE] Internal Leave API: POST /api/ai/leave-requests, PATCH /api/ai/leaverequests/{id}/submit, DELETE /api/ai/leave-requests/{id} (M2M, reuses LeaveRequestService). **[Partially Implemented]** — endpoints, ownership via X- User-Id, attachment validation (422 invalid_attachment / attachment_required), and balance checks are implemented. **Missing:** strict Employee-role enforcement from X-Role (documented 403 rule) is **not** implemented — carried to Sprint 4 (Story 4.3, new). 

- [BE] Extensive integration tests for the Internal Leave API. **[Not Verified]** — test projects (Wakeel.Tests.Unit / Wakeel.Tests.Integration) exist in the solution but test sources were not available for audit. 

- [AI-NODE] Leave Request Tool via WakeelApiClient with attachment_id. **[Implemented]** 

- [AI-NODE] Orchestrator (intent-router.js): intent detection, missing_fields, tools, result_card. **[Implemented]** 

## **Sprint 4: Feature Completion & Mobile Delivery (Days 15-19)** 

Sprint Goal: Complete the HR Dashboard document and leave workflows. Deliver the fully functional Flutter mobile application for employees. 

**<mark>Version 10 change:</mark>** <mark>the backend audit showed that Sprint 4 previously contained only [FE]/[MOB] tasks, while the backend APIs those tasks depend on (Templates CRUD, public Generated Documents, Audit Logs) do not exist. The required [BE] stories have been added below (4.1a, 4.1b, 4.2 [BE] items, 4.3) so the sprint reflects the real remaining work.</mark> 

### **Story 4.1: Document Templates & Generation UI (HR)** 

- [FE] Build the HR "Templates" page: list by type, activate/deactivate, and rich-text editor. **[Blocked — depends on Story 4.1a]** 

- [FE] Build the "Generate Document" AI chat flow. Render missing_fields as dynamic forms. Show Draft Review screen. 

- [FE] Build "Finalize & Send" flow. Post-finalization, export HTML to PDF and trigger email. **[Blocked — depends on Story 4.1b]** 

### **Story 4.1a: Template CRUD APIs** **<mark>NEW [BE]</mark>** 

- [BE] Build <mark>`TemplatesController`</mark> with POST /api/templates, GET /api/templates (list, filter by documentType, paginated), GET /api/templates/{id}, PATCH /api/templates/{id}, DELETE /api/templates/{id}. Roles: HR_Manager. **[Not Implemented]** 

- [BE] Enforce the one-active-template-per-documentType rule on create/activate. **[Not Implemented]** 

### **Story 4.1b: Public Generated Documents Lifecycle APIs** **<mark>NEW [BE]</mark>** 

- [BE] Migration: add <mark>`TemplateId` ,</mark> <mark>`PdfUrl` ,</mark> <mark>`GeneratedByUserId` ,</mark> <mark>`EmailSentTo`</mark> , <mark>`EmailSentAt` ,</mark> <mark>`FinalizedAt`</mark> columns to GENERATED_DOCUMENT. **[Not Implemented]** 

- [BE] Build <mark>`DocumentsController`</mark> : GET /api/documents (paginated, filters: type/status/employee_id/sort/order), GET /api/documents/{doc_id}, PATCH /api/documents/{doc_id} (HR, Draft only), POST /api/documents/{doc_id}/finalize, POST /api/documents/{doc_id}/send-email. Role matrix per unified API doc §12 (Owner 403; HR company-wide; Employee own-only read). **[Not Implemented]** 

- [BE] Add PDF generation service (e.g. QuestPDF) for finalize; store PdfUrl; enforce one-way Draft → Finalized. **[Not Implemented]** 

- [BE] Email delivery for send-email with 409 not_finalized / 422 employee_no_email / 502 email_send_failed. **[Not Implemented]** 

### **Story 4.2: HR Leave Approvals & Overviews** 

- [FE] Build HR "Leave Approvals" page. (Backend ready: GET/PATCH /api/leaverequests incl. approve/reject with mandatory hr_note on rejection.) 

- [BE] Audit Logging backend **<mark>MOVED FROM STORY 2.7 (was wrongly marked Completed)</mark>** : create <mark>`AuditLog`</mark> entity + EF Core migration, write hooks on sensitive actions (auth events, user status changes, leave decisions, policy uploads, document finalization), and <mark>`GET /api/audit-logs`</mark> (paginated; Company_Owner/HR_Manager). **[Not Implemented]** 

- [FE] Build Audit Logs viewer table. **[Blocked — depends on the [BE] audit logging item above]** 

- [FE] Build HR Overview cards. (Backend ready: GET /api/dashboard/summary.) 

### **Story 4.3: M2M Integration Reconciliation & Hardening** **<mark>NEW [BE] / [AI-NODE]</mark>** 

   - [BE] Fix <mark>`InternalApiKeyMiddleware`</mark> path list: protect the actual route 

- <mark>`/api/ai/documents/save`</mark> (currently the middleware guards the non-existent 

   - <mark>`/api/documents/save`</mark> , leaving the real endpoint unsecured). **[Not Implemented]** 

- [BE] [AI-NODE] Reconcile the internal document-save contract: Node <mark>`documentapi.js`</mark> calls <mark>`POST /api/documents/save`</mark> and expects <mark>`{ success, document_id, document_type, status, created_at }` ,</mark> while .NET implements <mark>`POST /api/ai/documents/save`</mark> returning <mark>`{ success, documentId, status }` .</mark> Align route and response envelope (integration currently broken). **[Not Implemented]** 

- [BE] Enforce Employee role (X-Role) on the Internal Leave API with 403 for other roles, per Story 3.5 requirement. **[Not Implemented]** 

- [BE] Persist <mark>`template_id`</mark> (and optionally <mark>`metadata` )</mark> in the internal document save once the GENERATED_DOCUMENT migration (Story 4.1b) lands. **[Not Implemented]** 

- [BE] Company Policies management: add <mark>`GET /api/company/policies`</mark> (list) and <mark>`DELETE /api/company/policies/{handbookId}`</mark> (delete + de-index). Currently only POST exists. **[Not Implemented]** 

### **Story E1 & E2: Mobile Home & Profile** 

- [MOB] Build Bottom Navigation Shell (Home, Chat, Leaves, Documents). 

- [MOB] Build Profile Screen. Wire GET /me. (Verified actual route: <mark>`GET /api/employees/me`</mark> .) 

- [MOB] Build Home Dashboard. Display Annual/Sick/Unpaid leave balance stat cards. (Backend ready.) 

### **Story E3 & E4: Mobile AI Chat & Voice** 

- [MOB] Build Chat UI. Message list with user/AI bubbles, timestamps, and progressive typewriter reveal. Must persist and resend conversation_id. 

- [MOB] Render sources[]/citations as distinct UI chips beneath AI replies. (Verified: sources are citation objects {title, type, section, url}.) 

- [MOB] Render missing_fields as inline dynamic forms. 

- [MOB] Implement Voice Input (STT). Transcription lands in composer for review (never auto-send). 

### **Story E5 & E6: Mobile Leave Requests & Documents** 

- [MOB] Build "My Leave Requests" screen. Filter chips (All/Draft/Pending/Approved). Paginated card list. (Backend ready.) 

- [MOB] Build chat-driven leave flow. Include pre-chat medical report upload step (calling POST /api/leave-requests/attachments) to acquire attachment_id before submitting the structured input back to the AI. (Backend ready — returns 201.) 

- [MOB] Build "My Documents" screen. **[Blocked — depends on Story 4.1b]** 

- [MOB] Build Document detail. In-app PDF viewer. Drafts show "Being reviewed by HR" (no download). Finalized docs allow local device download. **[Blocked — depends on Story 4.1b]** 

### **Story E7: Mobile Settings & Localization** 

- [MOB] Build Settings screen: Language toggle (AR/EN), Theme selector, Logout. 

- [MOB] Ensure RTL/LTR layouts flip instantaneously and persist across app restarts. 

**Sprint 5: Hardening, E2E Testing, Deployment & Demo (Days 20-23)** 

Sprint Goal: Stabilization only. Security sweeps, timeout handling, cross-service error resilience, and public deployment. 

### **Story 5.1: Cross-Service Stability & Security** 

- [AI-NODE] Ensure graceful failure handling for distributed tasks. 

- [BE] Input-validation sweep across every POST/PATCH endpoint ensuring strict 400 envelope returns. 

- [BE] [AI-NODE] Secrets sweep. (Include verification that the Story 4.3 middleware fix covers all internal routes.) 

**Story 5.2: E2E Testing & AI Evaluation** 

- [BE] Run integration suites on the test tenant. (Must include the Internal Leave API integration tests from Story 3.5, currently [Not Verified].) 

- [AI-NODE] AI Evaluation run: Assert 8/10 on Labor Law retrieval, exact-match asserts on JS Calculator functions, and proper Orchestrator intent routing. 

- [MOB] [FE] Execute manual QA matrix. 

**Story 5.3: Deployment & Demo Seeding** 

- [BE] [AI-NODE] Deploy .NET API and Node.js Express service to Azure/AWS. Verify M2M connectivity. 

- [BE] Run the demo seed script. 

- [FE] Deploy React dashboard to static hosting. 

- [MOB] Produce release builds. 

- [ALL] Rehearse Demo Scenarios (Employee Voice Chat & HR Document Generation). 

Wakeel AI — Detailed MVP Backlog, Version 10 (Backend-Verified). Updated from Version 9 after a full audit of the .NET backend codebase. Key corrections: Story 2.7 (Audit Logging) reopened; internal document-save route drift recorded; new [BE] stories 4.1a, 4.1b, 4.3 added for Templates CRUD, public Generated Documents lifecycle, M2M hardening, X-Role enforcement, and Company Policies GET/DELETE. 

