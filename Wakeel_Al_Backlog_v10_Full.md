# **Wakeel AI — Detailed MVP Backlog** 

## Version 10 — API v8 Contract Aligned 

_AI Team Requirements · API Documentation v8 · Backlog Tasks — Fully Consistent_ 

Tracks: [BE] .NET 10  |  [FE] React Web  |  [MOB] Flutter App  |  [AI-NODE] Node.js AI Service 

_Source of Truth Chain:  AI Team Requirements  →  API Documentation v8  →  Backlog Tasks v10_ 

### **Sprint 1 & 2: Foundations & Core HR Admin (Completed / Code-Aligned)** 

These stories are fully implemented in the .NET codebase and React web dashboard. 

- • Story 1.1-1.4: Auth & RBAC [Completed]. 

- • Story 1.9 & 2.8: Company Profile [Completed]. 

- • Story 2.4: HR Accounts [Completed]. 

- • Story 2.5: Department Management [Completed]. 

- • Story 2.6: Employee Management [Completed]. 

- • Story 2.7: Audit Logging [Completed]. 

### **Sprint 3: The Great AI Migration & M2M Auth (Days 10-14)** 

Sprint Goal: Move AI orchestration out of .NET into a standalone Node.js service. Establish Machine-toMachine (M2M) authentication. Build the API Gateway routing for chat, internal context endpoints, internal leave APIs, and the LangChain RAG pipeline. 

#### **Story 3.1: AI Service Foundation & M2M Security** 

- • [BE] Implement X-Internal-API-Key middleware in .NET. Must secure all server-to-server endpoints (bypassing JWT). 

- • [AI-NODE] Scaffold the Node.js + Express service. Strictly JavaScript (ES Modules). No TypeScript, no BullMQ worker architectures allowed. 

- • [AI-NODE] Setup Winston for centralized logging and Zod for runtime request validation. 

- • [AI-NODE] Create config/env.js to validate required variables. Fail process if missing. 

- • [AI-NODE] Implement GET /health returning service status. 

#### **Story 3.2: Internal Context Integrations & Pre-Chat Uploads (.NET Data Access)** 

- • [BE] Create DOCUMENT_TEMPLATE and GENERATED_DOCUMENT EF Core migrations. 

##### **• [BE] Build GET /api/ai/employee-context** 

(secured by M2M headers: X-Internal-API-Key, X-User-Id, X-Company-Id, X-Role). Returns specific employee details and live leave balances. 

Response schema (camelCase, flat leaveBalance): 

```
{
  "userId": "uuid",
  "companyId": "uuid",
  "fullName": "string",
  "role": "Employee",
  "department": "string | null",
  "employmentStatus": "Active | Inactive",
  "leaveBalance": { "annual": 12, "used": 5, "remaining": 7 }
}
```

_The leaveBalance field is a flat object containing only annual leave (annual, used, remaining). It may be omitted or null._ 

##### **• [BE] Build GET /api/ai/company-context** 

(secured by M2M headers). Returns company working hours, industry, and profile data. 

Response schema (camelCase): 

```
{
  "companyId": "uuid",
  "companyName": "string",
  "industry": "string | null",
  "workingHours": "string | null",
  "policyAvailable": true | false
```

```
}
```

_The policyAvailable field indicates whether company policy/handbook content is available in the RAG system for retrieval. No additional fields (tax_id, address, phone_number, email, logo_url, registered_at) are returned._ 

- • [BE] Build GET /api/ai/templates/active?documentType= (secured by M2M headers). Enforces one-active-template rule. 

##### **• [BE] Build POST /api/documents/save** 

(secured by M2M headers). 

Request schema (camelCase): 

```
{
  "documentType": "employment_contract",
  "title": "string",
  "content": "string",
  "metadata": { "employeeId": "uuid", "companyId": "uuid" }
}
```

The metadata object carries employeeId (the target employee the document is about — not the caller's identity) and companyId. 

Response schema: 

```
{ "success": true, "documentId": "uuid", "status": "saved" }
```

_.NET remains the source of truth for document business persistence._ 

- • [BE] Build POST /api/leave-requests/attachments (Public/JWT). Allows the Mobile App to upload a medical report before chat, returning an attachment_id and url. 

_The client must pass the returned url (not the attachment_id) back to the AI through field_values during the chat conversation._ 

- • [AI-NODE] WakeelApiClient module: configure outbound HTTP client with base URL and attach internal auth headers to every outgoing request. 

#### **Story 3.3: Chat History Gateway & Mongo Persistence** 

- • [AI-NODE] Provision MongoDB Atlas cluster. Create collections: Conversations and Messages (with nested Citations). 

- • [AI-NODE] Build GET /api/ai/chat/history to fetch a user's chat history from MongoDB. 

##### **• [BE] Refactor .NET POST /api/ai/chat endpoint to act as an API Gateway, and own the conversationId lifecycle.** 

Public request (Client → .NET): 

```
POST /api/ai/chat  —  { "message": "...", "conversation_id"?: "..." }
```

_The frontend sends ONLY a message and optionally a conversation_id. The frontend does NOT send userId, companyId, or role — these are extracted from the authenticated JWT by .NET. If the client omits conversation_id, .NET generates a new UUID._ 

Internal forwarding (.NET → AI): 

```
POST /api/ai/chat  —  { "message": "...", "context": { "userId": "...",
"companyId": "...", "role": "...", "conversationId": "..." } }
```

_The context object carries the user identity extracted from the JWT (userId, companyId, role) and the conversationId (generated by .NET or forwarded from the client). This context object matches the AIContext definition in the AI architecture._ 

AI response → .NET → Client: 

```
AI returns: { "conversationId", "message", "type", "sources", "actions" }
.NET translates to client-facing envelope:
{ "chat_id", "conversation_id", "reply" (mapped from message), "sources",
"missing_fields", "result_card", "created_at" }
```

- • [BE] Configure the .NET HttpClient with a strict minimum 60-second timeout for Node.js calls. 

#### **Story 3.4: LLM Orchestration & RAG Pipeline (Node.js)** 

- • [AI-NODE] Create LangChain chat-model and embedding abstractions (src/llm/chat-model.js, embeddings.js). 

- • [BE] Create COMPANY_HANDBOOK EF Core migration to support handbook uploads. 

- • [AI-NODE] Implement POST /api/knowledge/ingest. 

##### **• [BE] Hook into the POST /api/company/policies endpoint (Company Owner, JWT).** 

multipart/form-data PDF upload. .NET extracts the raw text and forwards it (with M2M headers) to the Node.js POST /api/knowledge/ingest endpoint. 

Request body for ingestion: 

```
{
  "companyId": "uuid",
  "knowledgeType": "company-policy",
  "documentId": "uuid",
  "title": "string",
  "content": "Full extracted policy text..."
```

```
}
```

_The knowledgeType field accepts exactly two values: labor-law, company-policy. The companyId is NOT sent in the upload request body — it is derived from the authenticated Owner's JWT._ 

- • [AI-NODE] Implement searchKnowledge retrieving chunks scoped strictly by companyId or null (public law). 

#### **Story 3.5: AI Skills, Tools & Internal Leave API** 

- • [AI-NODE] Build Skill & Tool Registries. 

- • [AI-NODE] Calculator Skill: Implement deterministic HR calculations in pure JavaScript. 

- • [AI-NODE] Document Generation Skill (scaffold): will receive structured input, fetch companycontext (§10.4) and the active template (§10.6), fill placeholders, and call .NET POST /api/documents/save using the finalized request schema. 

##### **• [BE] Build Internal Leave API: POST /api/ai/leave-requests, PATCH /api/ai/leaverequests/{id}/submit, DELETE /api/ai/leave-requests/{id}.** 

Secured via M2M headers. Strictly enforces Employee role, extracts ownership purely from X-UserId, and reuses existing LeaveRequestService without duplicating business logic. 

- • [BE] Write extensive integration tests for the Internal Leave API (Auth missing/invalid, ownership validation, state transitions, attachment rules, and cross-company rejection). 

##### **• [AI-NODE] Leave Request Tool: Submit draft leave requests by calling the new internal .NET** 

##### **/api/ai/leave-requests endpoints using WakeelApiClient, passing the attachment_url (the URL path returned from POST /api/leave-requests/attachments, §14) gathered from structured inputs.** 

_The attachment_url field is required in the request body for Sick leave requests._ 

- • [AI-NODE] Build Orchestrator (intent-router.js). Detect intent, ask for missing_fields, trigger tools, format result_card. 

### **Sprint 4: Feature Completion & Mobile Delivery (Days 15-19)** 

Sprint Goal: Complete the HR Dashboard document and leave workflows. Deliver the fully functional Flutter mobile application for employees. 

#### **Story 4.1: Document Templates & Generation UI (HR)** 

- • [FE] Build the HR "Templates" page: list by type, activate/deactivate, and rich-text editor with {{placeholders}}. 

- • [FE] Build the "Generate Document" AI chat flow. Render missing_fields as dynamic forms. Show Draft Review screen. 

- • [FE] Build "Finalize & Send" flow. Post-finalization, export HTML to PDF and trigger email. 

#### **Story 4.2: HR Leave Approvals & Overviews** 

- • [FE] Build HR "Leave Approvals" page. 

- • [FE] Build Audit Logs viewer table. 

- • [FE] Build HR Overview cards. 

#### **Story E1 & E2: Mobile Home & Profile** 

- • [MOB] Build Bottom Navigation Shell (Home, Chat, Leaves, Documents). 

- • [MOB] Build Profile Screen. Wire GET /me. 

- • [MOB] Build Home Dashboard. Display Annual/Sick/Unpaid leave balance stat cards. 

#### **Story E3 & E4: Mobile AI Chat & Voice** 

- • [MOB] Build Chat UI. Message list with user/AI bubbles, timestamps, and progressive typewriter reveal. Must persist and resend conversation_id. 

- • [MOB] Render sources[]/citations as distinct UI chips beneath AI replies. 

- • [MOB] Render missing_fields as inline dynamic forms. 

- • [MOB] Implement Voice Input (STT). Transcription lands in composer for review (never auto-send). 

#### **Story E5 & E6: Mobile Leave Requests & Documents** 

- • [MOB] Build "My Leave Requests" screen. Filter chips (All/Draft/Pending/Approved). Paginated card list. 

- • [MOB] Build chat-driven leave flow. Include pre-chat medical report upload step (calling POST /api/leave-requests/attachments) to acquire the url (not attachment_id) before submitting the structured input back to the AI. 

- • [MOB] Build "My Documents" screen. 

- • [MOB] Build Document detail. In-app PDF viewer. Drafts show "Being reviewed by HR" (no download). Finalized docs allow local device download. 

#### **Story E7: Mobile Settings & Localization** 

- • [MOB] Build Settings screen: Language toggle (AR/EN), Theme selector, Logout. 

- • [MOB] Ensure RTL/LTR layouts flip instantaneously and persist across app restarts. 

### **Sprint 5: Hardening, E2E Testing, Deployment & Demo (Days 20-23)** 

Sprint Goal: Stabilization only. Security sweeps, timeout handling, cross-service error resilience, and public deployment. 

#### **Story 5.1: Cross-Service Stability & Security** 

- • [AI-NODE] Ensure graceful failure handling for distributed tasks. 

- • [BE] Input-validation sweep across every POST/PATCH endpoint ensuring strict 400 envelope returns. 

- • [BE] [AI-NODE] Secrets sweep. 

#### **Story 5.2: E2E Testing & AI Evaluation** 

- • [BE] Run integration suites on the test tenant. 

- • [AI-NODE] AI Evaluation run: Assert 8/10 on Labor Law retrieval, exact-match asserts on JS Calculator functions, and proper Orchestrator intent routing. 

- • [MOB] [FE] Execute manual QA matrix. 

#### **Story 5.3: Deployment & Demo Seeding** 

- • [BE] [AI-NODE] Deploy .NET API and Node.js Express service to Azure/AWS. Verify M2M connectivity. 

- • [BE] Run the demo seed script. 

- • [FE] Deploy React dashboard to static hosting. 

- • [MOB] Produce release builds. 

- • [ALL] Rehearse Demo Scenarios (Employee Voice Chat & HR Document Generation). 

