# **Wakeel AI — API Documentation** 

#### **Version 9 — Unified (Backend-Verified)** 

This document is the single unified API reference for Wakeel AI. It merges the previous two documents — _Wakeel AI API Documentation v8 (Full)_ and _Wakeel AI Generated Documents API Specification (Section 12 Expansion)_ — into one document, reconciled against the actual .NET backend codebase, which is the ultimate source of truth. 

### **Merge & Verification Changelog** 

- The two source documents were merged into one. The Generated Documents specification now forms the expanded Section 12; its overlapping summary in v8 §12 was replaced (genuine duplicate removed). 

- All endpoint routes, methods, roles, payloads and status codes were verified against the .NET backend. Where documentation conflicted with the backend, **the backend implementation takes precedence** and this document was corrected. 

- APIs that are documented/planned but not present in the backend are preserved as forward contracts and clearly marked **<mark>[PENDING IMPLEMENTATION]</mark>** . They must not be treated as live APIs. 

- Key corrections vs v8: internal document save route is `POST /api/ai/documents/save` (not `/api/documents/save` ); internal context endpoints (§10.3/§10.4) return snake_case shapes; attachment upload returns **201** ; several implemented endpoints previously undocumented (change-password, dashboard summary, GET users/me, GET departments/{id}, DELETE employees/{id}, GET leave-requests/{id}, GET chat conversations) were added. 

## **1. Overview** 

Wakeel AI is an AI-powered HR-compliance SaaS for Egyptian SMEs. The platform consists of a .NET 10 backend (system of record, public API, gateway), a Node.js AI service (LLM orchestration, RAG, MongoDB chat persistence), a React HR dashboard, and a Flutter employee mobile app. 

**Base URL:** `https://api.wakeel-ai.com/v1` (all routes below are shown with their actual `/api/...` application paths). 

**Role Description** 

**Primary Client** 

|`Company_Owner`|Owns the company account. Manages HR accounts, departments, company<br>profile.|React Web|
|---|---|---|
|`HR_Manager`|Day-to-day HR operations: employees, leave approvals, policies,<br>documents, AI chat.|React Web|
|`Employee`|Self-service: profile, leave requests, AI chat, documents.|Flutter<br>Mobile|



## **2. Authentication** 

### **2.1 JWT Authentication (Public APIs)** 

Public APIs use Bearer JWT access tokens ( `Authorization: Bearer <token>` ). Refresh tokens are issued as an HttpOnly `refresh_token` cookie. Role-based authorization is enforced per endpoint via `[Authorize(Roles = ...)]` . 

### **2.2 Machine-to-Machine (M2M) Authentication (Internal APIs)** 

Internal server-to-server APIs (Node.js → .NET) bypass JWT and are secured by `InternalApiKeyMiddleware` , which requires all four headers: 

|**Header**|**Purpose**|
|---|---|
|`X-Internal-API-Key`|Shared secret between the services.|
|`X-User-Id`|Acting user identity (ownership scoping).|
|`X-Company-Id`|Tenant scoping.|
|`X-Role`|Acting user role.|



**Verified protected paths** (as configured in `InternalApiKeyMiddleware` ): `/api/ai/employee-context` , `/api/ai/company-context` , `/api/ai/templates/active` , `/api/documents/save` , `/api/ai/leave-requests` . 

**<mark>Verified security gap:</mark>** <mark>the middleware protects the path</mark> <mark>`/api/documents/save` , but the actual implemented route is</mark> <mark>`POST /api/ai/documents/save` (marked</mark> <mark>`[AllowAnonymous]` ).</mark> 

<mark>As a result the real document-save endpoint is</mark> **<mark>not</mark>** <mark>protected by the M2M key middleware. This must be fixed in the backend (see Backlog Sprint 4).</mark> 

**Verified error responses** (actual codes differ from the previously documented `UNAUTHORIZED_SERVICE` / `MISSING_IDENTITY_HEADERS` ): 

```
401  { "error": "unauthorized", ... }          // missing/invalid X-Internal-
API-Key
400  { "error": "missing_identity_headers", ... } // missing X-User-Id / X-
Company-Id / X-Role
```

### **2.3 POST /api/auth/register-company** 

**Auth:** Public. Registers a company and its Company_Owner user. 

**Response:** `201 Created` with owner/company payload; sets `refresh_token` HttpOnly cookie. 

**Errors:** `409 email_already_exists` , `400 validation_error` . 

### **2.4 POST /api/auth/login** 

**Auth:** Public. Returns access token, user info, and a `must_change_password` flag (true for invited users with temporary passwords). Sets `refresh_token` cookie. 

**Errors:** `401 invalid_credentials` , `403 account_inactive` . 

### **2.5 POST /api/auth/refresh** 

**Auth:** `refresh_token` HttpOnly cookie. Rotates the refresh token and returns a new access token. 

**Errors:** `400/401 invalid_refresh_token` . 

### **2.6 POST /api/auth/logout** 

**Auth:** JWT required (verified — v8 did not state this). Revokes the refresh token and clears the cookie. **Response:** `204 No Content` . 

### **2.7 POST /api/account/change-password (implemented — previously undocumented)** 

**Auth:** JWT — Roles: `HR_Manager` , `Employee` . 

```
Request:  { "current_password": "...", "new_password": "..." }   //
new_password min length 8
```

```
Response: 204 No Content
```

```
Errors:   404 user_not_found, 400 invalid_current_password, 400
validation_error
```

## **3. Users & HR Accounts** 

### **3.1 POST /api/users/invite** 

**Auth:** JWT — Role: `Company_Owner` . Invites an HR account with a temporary password. 

```
Request:  { "full_name": "...", "email": "...", "role": "HR_Manager" }
Response: 201 Created
```

```
Errors:   400 invalid_role (only "HR_Manager" is accepted — verified), 409
email_already_exists, 400 validation_error
```

### **3.2 GET /api/users?role=&page=&limit=** 

**Auth:** JWT — Role: `Company_Owner` . Paginated list of company users, optional role filter. 

### **3.3 GET /api/users/me (implemented — previously undocumented)** 

**Auth:** JWT — Role: `HR_Manager` . Returns the current HR user profile. 

### **3.4 PATCH /api/users/{userId}/status** 

**Auth:** JWT — Role: `Company_Owner` **only** (verified — v8 previously said "Owner / HR"; the backend restricts this to the Owner). Activates/deactivates a user. 

## **4. Company Profile** 

### **4.1 GET /api/company/profile** 

**Auth:** JWT — Roles: `Company_Owner` , `HR_Manager` . Returns company profile including `logo_url` , `working_hours` , etc. 

### **4.2 PUT /api/company/profile** 

**Auth:** JWT — Role: `Company_Owner` . `multipart/form-data` ; partial update semantics (only provided fields change). Optional `logo` file: max 5 MB, extensions `.jpg .jpeg .png .webp` . 

## **5. Departments** 

|**Method & Route**|**Roles**|**Notes / Status codes**|
|---|---|---|
|`POST /api/departments`|Company_Owner|201 Created|
|`GET /api/departments?page=&limit=`|Company_Owner,<br>HR_Manager|Paginated (default limit 20)|
|`GET /api/departments/{id}` **(previously**<br>**undocumented)**|Company_Owner,<br>HR_Manager|200; 404 department_not_found|
|`PATCH /api/departments/{id}`|Company_Owner|200; 404 department_not_found|
|`DELETE /api/departments/{id}`|Company_Owner|204; 409 department_in_use if<br>employees assigned; 404<br>department_not_found|



## **6. Employees** 

### **6.1 POST /api/employees** 

**Auth:** JWT — Role: `HR_Manager` . Creates an employee (User + EmployeeProfile + default leave balances). 

```
Response: 201 Created
```

```
Errors:   409 email_already_exists, 400 hire_date_in_future, 404
department_not_found, 400 validation_error
```

### **6.2 GET /api/employees?status=&page=&limit=** 

**Auth:** JWT — Role: `HR_Manager` . Paginated. `status` must be `Active` or `Inactive` when provided. 

### **6.3 GET /api/employees/{recordId}** 

**Auth:** JWT — Role: `HR_Manager` . Employee detail including leave balances. **Errors:** 404 employee_not_found. 

### **6.4 PATCH /api/employees/{recordId}** 

**Auth:** JWT — Roles: `HR_Manager` , `Company_Owner` (verified — the Owner is also permitted, contrary to earlier docs implying HR only). 

### **6.5 DELETE /api/employees/{recordId} (implemented — previously undocumented)** 

**Auth:** JWT — Role: `HR_Manager` . Soft deactivation (sets the employee Inactive). **Response:** 204 No Content. 

## **7. Employee Self-Service** 

### **7.1 GET /api/employees/me** 

**Auth:** JWT — Role: `Employee` . (Verified route — v8 abbreviated this as `GET /me` ; the actual route is `GET /api/employees/me` .) Returns the employee's own profile with the full threetype leave balance: 

```
{
  "full_name": "...", "job_title": "...", "department": "...", ...
  "leave_balance": {
    "annual": { "total_days": 21, "used_days": 4, "remaining_days": 17 },
    "sick":   { "total_days": ..., "used_days": ..., "remaining_days": ... },
    "unpaid": { "total_days": null, "used_days": ..., "remaining_days": null }
  }
}
```

## **Dashboard (HR Overview) (implemented — previously undocumented)** 

### **GET /api/dashboard/summary** 

**Auth:** JWT — Role: `HR_Manager` . 

```
Response 200:
```

```
{ "employee_count": n, "active_employees": n, "pending_leave_requests": n,
```

```
  "handbook_uploaded": true|false, "generated_documents_count": n }
```

## **8. Leave Requests** 

### **8.1 POST /api/leave-requests** 

**Auth:** JWT — Role: `Employee` . `multipart/form-data` (CreateLeaveRequestDto fields + optional `attachment` file). Creates a **Draft** leave request. 

```
Response: 201 Created
```

```
{ "request_id": "...", "status": "Draft", "days_requested": n }
Errors: 400 validation_error, 422 insufficient_leave_balance, 422
attachment_required (Sick)
```

### **8.2 GET /api/leave-requests?status=&page=&limit=** 

**Auth:** JWT — Roles: `Employee` , `HR_Manager` . Response envelope `{ "data": [...], "page": n, "total": n }` . 

**Verified visibility rule:** employees see their own requests; HR sees company requests **excluding Draft and Cancelled** . 

### **8.3 GET /api/leave-requests/{id} (implemented — previously undocumented)** 

**Auth:** JWT — Roles: `Employee` (own), `HR_Manager` (non-Draft/non-Cancelled only). 404 leave_request_not_found. 

### **8.4 PATCH /api/leave-requests/{id}/submit** 

**Auth:** JWT — Role: `Employee` . Draft → Pending. 

```
Response 200: { "request_id": "...", "status": "Pending" }
```

```
Errors: 404 leave_request_not_found, 409 not_a_draft
```

### **8.5 DELETE /api/leave-requests/{id}** 

**Auth:** JWT — Role: `Employee` . Cancels own request (sets `Cancelled` ). **Response:** 204 No Content. 

### **8.6 PATCH /api/leave-requests/{id} (HR review)** 

**Auth:** JWT — Role: `HR_Manager` . Body: `{ "status": "Approved"|"Rejected", "hr_note": "..." }` . 

- **Approved:** deducts the leave balance; `422 insufficient_leave_balance` if insufficient. 

- **Rejected:** `hr_note` is **required** (verified) — otherwise `400 validation_error` . 

- `409 not_pending` if the request is not in Pending state. 

## **9. AI Assistant (Public Gateway)** 

### **9.1 Conversation Lifecycle** 

The .NET gateway owns the `conversation_id` lifecycle: if the client omits it, the gateway generates a new one and forwards it to the Node.js AI service inside the M2M context. Clients must persist and resend `conversation_id` for follow-up turns. 

### **9.2 POST /api/ai/chat** 

**Auth:** JWT — Roles: `HR_Manager` , `Employee` . The gateway forwards to the Node.js AI service with all four M2M headers and the payload `{ message, language, field_values, context: { userId, companyId, role, conversationId } }` . 

```
Request:
{ "conversation_id": "optional", "message": "required", "language": "ar|en
(optional)",
  "field_values": { ... optional structured inputs ... } }
Response 200:
{ "chat_id": "...", "conversation_id": "...", "reply": "...",
  "sources": [ { "title": "...", "type": "...", "section": "...", "url": "..."
} ],
  "missing_fields": [ ... ], "result_card": { ... }, "created_at": "..." }
```

**Verified:** `sources` is an array of citation objects (CitationDto), not plain strings. **Gateway errors:** `504 ai_timeout` , `502 ai_unavailable` / `502 ai_response_error` , passthrough `ai_error` with upstream status. 

### **9.3 GET /api/ai/chat/history?conversation_id=&page=&limit=** 

**Auth:** JWT — Roles: `HR_Manager` , `Employee` . Proxied to the Node.js service (MongoDB persistence); the Node response body is returned as-is. 

### **9.4 GET /api/ai/chat/conversations?page=&limit= (implemented — previously undocumented)** 

**Auth:** JWT — Roles: `HR_Manager` , `Employee` . Paginated list of the user's conversations, proxied to the Node.js service. 

## **10. Internal AI Integrations (M2M)** 

All endpoints in this section are server-to-server (Node.js ↔ .NET) and require the four M2M headers (§2.2), except where the verified middleware gap is noted. 

### **10.1 Chat Forwarding (.NET → Node)** 

`POST {NODE_BASE}/api/ai/chat` — the gateway forwards user messages with the M2M headers and context envelope described in §9.2. 

### **10.2 Chat History (.NET → Node)** 

`GET {NODE_BASE}/api/ai/chat/history` and `GET {NODE_BASE}/api/ai/chat/conversations` — proxied with M2M headers. 

### **10.3 GET /api/ai/employee-context (Node → .NET)** 

**Auth:** M2M headers. Scoped by `X-User-Id` / `X-Company-Id` . 

```
Response 200 (verified — snake_case):
```

```
{
  "record_id": "...", "company_id": "...", "full_name": "...", "role": "...",
  "department": "...", "job_title": "...", "employment_status": "...",
  "leave_balance": {
    "annual": { "total_days": n, "used_days": n, "remaining_days": n },
    "sick":   { "total_days": n, "used_days": n, "remaining_days": n },
    "unpaid": { "total_days": null, "used_days": n, "remaining_days": null }
  }
}
```

<mark>The camelCase flat contract previously shown in v8 §10.3 (</mark> <mark>`leaveBalance` with annual only) is</mark> **<mark>not implemented</mark>** <mark>and has been superseded by the verified snake_case shape above, which is also what the Node.js client validates against.</mark> 

**Errors:** 404 with `{ "error": { "code": "leave_request_not_found", "message": "Employee not found." } }` (verified — note the backend currently reuses this error code for a missing employee). 

### **10.4 GET /api/ai/company-context (Node → .NET)** 

**Auth:** M2M headers. 

```
Response 200 (verified — snake_case):
```

```
{ "id": "...", "name": "...", "tax_id": "...", "industry": "...", "address":
"...",
  "phone_number": "...", "email": "...", "logo_url": "...", "working_hours":
"...",
  "registered_at": "...", "policy_available": true|false }
```

<mark>`policy_available` is true when at least one CompanyHandbook exists. The minimal camelCase contract previously shown in v8 §10.4 is</mark> **<mark>not implemented</mark>** <mark>; the shape above is authoritative.</mark> 

### **10.5 POST {NODE_BASE}/api/knowledge/ingest (.NET → Node)** 

Fired best-effort (fire-and-forget) after a company policy PDF upload (§13). Payload: 

```
{ "companyId": "...", "knowledgeType": "company-policy", "documentId": "...",
"title": "...", "content": "<extracted text>" }
```

### **10.6 GET /api/ai/templates/active?documentType= (Node → .NET)** 

**Auth:** M2M headers. Enforces the one-active-template rule. 

```
Response 200: { "template_id": "...", "document_type": "...", "name": "...",
"content_template": "..." }
```

```
Errors: 400 validation_error (documentType missing), 404 template_not_found
```

### **10.7 POST /api/ai/documents/save (Node → .NET)** 

**Verified route:** `POST /api/ai/documents/save` — **not** `POST /api/documents/save` as previously documented. 

```
Request (snake_case, SaveDocumentRequest):
```

```
{ "document_type": "required", "title": "required", "content_html":
"required",
```

```
  "employee_id": "optional", "template_id": "optional", "metadata": { optional
} }
```

```
Response 200:
```

```
{ "success": true, "documentId": "...", "status": "Draft" }
```

- **Verified:** `template_id` and `metadata` are accepted but currently **ignored / not persisted** (GeneratedDocument has no TemplateId column). 

- **Verified:** `employee_id` , when provided, is validated against the company → `404 employee_not_found` . 

- **Verified:** the success response uses camelCase `documentId` and contains only `success, documentId, status` — not the richer envelope previously documented. 

**<mark>Known integration drift (must be reconciled):</mark>** <mark>(1) the Node.js client (</mark> <mark>`document-api.js` ) still calls</mark> <mark>`POST /api/documents/save` , which does not exist in .NET (would 404), and expects</mark> <mark>`{ success, document_id, document_type, status, created_at }` ; (2) the M2M middleware protects</mark> <mark>`/api/documents/save` instead of the real route, leaving</mark> <mark>`/api/ai/documents/save` unprotected (see §2.2). Both items are tracked in the Backlog (Sprint 4).</mark> 

### **10.8 missing_fields Contract** 

When the AI requires structured input, the reply carries `missing_fields` : an array of field descriptors (name, label, type, required, options where applicable). Clients render these as dynamic forms and resend values via `field_values` (§9.2). 

### **10.9 result_card Contract** 

`result_card` is a typed payload rendered as a card in clients. Three variants: `calculation` (deterministic HR calculation result), `document_draft` (generated document draft reference), `leave_draft` (draft leave request reference). 

### **10.10 POST /api/ai/leave-requests (Node → .NET)** 

**Auth:** M2M headers. Ownership extracted from `X-User-Id` . Reuses LeaveRequestService (no duplicated business logic). 

```
Response 201 (verified):
```

```
{ "request_id": "...", "status": "Draft", "days_requested": n }
```

```
Errors: 400 validation_error, 422 insufficient_leave_balance,
```

```
        422 attachment_required (Sick leave without attachment_url),
```

```
        422 invalid_attachment (attachment_url not a valid company-scoped
LeaveAttachment)
```

**<mark>Verified deviations from the previous documentation:</mark>** <mark>(1) the response contains only the three fields above — the previously documented 7-field response (leave_type, start_date, end_date, attachment_uploaded, ...) is</mark> **<mark>not implemented</mark>** <mark>; (2) the documented rule "403 if X-Role is not Employee" is</mark> **<mark>not enforced</mark>** <mark>in the current backend. Both are tracked in the Backlog.</mark> 

### **10.11 PATCH /api/ai/leave-requests/{requestId}/submit (Node → .NET)** 

```
Response 200: { "request_id": "...", "status": "Pending" }
```

```
Errors: 404 leave_request_not_found, 409 not_a_draft
```

### **10.12 DELETE /api/ai/leave-requests/{requestId} (Node → .NET)** 

```
Response: 204 No Content
```

```
Errors: 404 leave_request_not_found, 409 not_a_draft
```

## **11. Document Templates** **<mark>[PENDING IMPLEMENTATION - Sprint</mark>** 

## **4]** 

**Verified backend state:** the `DocumentTemplate` entity exists (Id, CompanyId, DocumentType, Name, ContentTemplate, IsActive) and the internal endpoint §10.6 reads active templates, but there is **no TemplatesController** and none of the public Template CRUD APIs below exist yet. They are preserved as the planned API contract for the frontend Templates page. 

|**Planned Endpoint**|**Roles**|**Purpose**|**Status**|
|---|---|---|---|
|`POST /api/templates`|HR_Manager|Create a<br>template|**[PENDING**<br>**IMPLEMENTATION -**<br>**Sprint 4]**|



|`GET`<br>`/api/templates?documentType=&page=&limit=`|HR_Manager|List templates<br>by type|**[PENDING**<br>**IMPLEMENTATION -**<br>**Sprint 4]**|
|---|---|---|---|
|`GET /api/templates/{id}`|HR_Manager|Template<br>detail|**[PENDING**<br>**IMPLEMENTATION -**<br>**Sprint 4]**|
|`PATCH /api/templates/{id}`|HR_Manager|Edit / activate<br>/ deactivate<br>(must<br>preserve the<br>one-active-<br>template-per-<br>type rule)|**[PENDING**<br>**IMPLEMENTATION -**<br>**Sprint 4]**|
|`DELETE /api/templates/{id}`|HR_Manager|Delete a<br>template|**[PENDING**<br>**IMPLEMENTATION -**<br>**Sprint 4]**|



## **12. Generated Documents** **<mark>[PENDING IMPLEMENTATION - Sprint</mark>** 

## **4]** 

This section is the merged full specification (formerly the separate _Generated Documents API Spec_ ). **Verified backend state:** the `GeneratedDocument` entity and the internal save endpoint (§10.7) exist, but there is **no public DocumentsController** — none of the five public endpoints below are implemented yet. They are preserved as the agreed forward contract for web and mobile. 

### **12.1 Roles & Access Matrix** 

|**Endpoint**|**Company_Owner**|**HR_Manager**|**Employee**|
|---|---|---|---|
|GET /api/documents|403|Company-wide|Own documents only|
|GET /api/documents/{doc_id}|403|Company-wide|Own only|



|PATCH /api/documents/{doc_id}|403|Allowed (Draft only)|403|
|---|---|---|---|
|POST /api/documents/{doc_id}/finalize|403|Allowed|403|
|POST /api/documents/{doc_id}/send-email|403|Allowed|403|



### **12.2 GET /api/documents** **<mark>[PENDING IMPLEMENTATION - Sprint 4]</mark>** 

Paginated listing. Query: `page, limit, type, status, employee_id, sort, order` . Response: `{ "data": [DocumentSummary], "page": n, "limit": n, "total": n }` . 

### **12.3 GET /api/documents/{doc_id}** **<mark>[PENDING IMPLEMENTATION - Sprint 4]</mark>** 

Returns DocumentDetail including `content_html` (Draft) / `pdf_url` (Finalized). Error: `404 document_not_found` . 

### **12.4 PATCH /api/documents/{doc_id}** **<mark>[PENDING IMPLEMENTATION - Sprint</mark>** 

### **4]** 

HR edits a Draft (title/content). Errors: `409 not_a_draft` , `404 document_not_found` . 

### **12.5 POST /api/documents/{doc_id}/finalize** **<mark>[PENDING IMPLEMENTATION -</mark>** 

### **<mark>Sprint 4]</mark>** 

One-way Draft → Finalized transition; renders the HTML content to PDF and stores `pdf_url` . Errors: `409 not_a_draft` , `422 document_has_no_content` , `404 document_not_found` . 

### **12.6 POST /api/documents/{doc_id}/send-email** **<mark>[PENDING</mark>** 

### **<mark>IMPLEMENTATION - Sprint 4]</mark>** 

Emails the finalized PDF to the linked employee (or optional `email_to` override). Errors: `409 not_finalized` , `422 employee_no_email` , `502 email_send_failed` , `404 document_not_found` . 

### **12.7 Status Model & Error Codes** 

Statuses: `Draft → Finalized` (one-way). Error codes reserved by this contract: `document_not_found, not_a_draft, not_finalized, document_has_no_content,` 

`invalid_template, employee_no_email, email_send_failed, employee_not_found, template_not_found` . 

### **12.8 Entity Mapping — Verified Backend Notes** 

Current `GeneratedDocument` entity (verified): `Id, CompanyId, EmployeeId (nullable), DocumentType, Title, Content, Status (default "Draft"), CreatedAt, UpdatedAt` . 

- **Resolved:** the `Title` column previously flagged as missing now exists. 

- **Still missing columns required by this contract:** `TemplateId` , `PdfUrl` , `GeneratedByUserId` , `EmailSentTo` / `EmailSentAt` , `FinalizedAt` — a migration is required (Backlog Sprint 4). 

- No PDF-generation library is installed (only PdfPig for text extraction); finalize requires adding one (e.g. QuestPDF). 

## **13. Company Policy Upload** 

### **13.1 POST /api/company/policies** 

**Auth:** JWT — Role: `Company_Owner` . `multipart/form-data` : 

|**Field**|**Type**|**Rules (verified)**|
|---|---|---|
|`pdf`|file|Required.`.pdf`only, max 20 MB.|
|`title`|text|**Required**form field (verified — previously undocumented).|



**Behavior (verified):** extracts the PDF text (PdfPig), saves a `CompanyHandbook` record, then forwards the text best-effort (fire-and-forget) to the Node.js service `POST /api/knowledge/ingest` (§10.5) for RAG indexing. Ingestion failure does not fail the upload. 

```
Response 201 Created (verified — previously documented as 200 with
indexed_for_rag):
{ "handbook_id": "...", "title": "...", "file_url": "...", "uploaded_at":
"..." }
```

### **13.2 GET /api/company/policies** **<mark>[PENDING IMPLEMENTATION]</mark>** 

List uploaded policy documents. **Not implemented** — required by the dashboard; tracked in the Backlog. 

### **13.3 DELETE /api/company/policies/{handbookId}** **<mark>[PENDING</mark>** 

### **<mark>IMPLEMENTATION]</mark>** 

Delete a policy document (and de-index its knowledge). **Not implemented** — tracked in the Backlog. 

## **14. Pre-Chat Attachment Upload** 

### **14.1 POST /api/leave-requests/attachments** 

**Auth:** JWT — Role: `Employee` . `multipart/form-data` , field `file` : max 10 MB; extensions `.pdf .jpg .jpeg .png` . Used by the mobile app to upload a medical report before the AI chat; the returned id is passed to the AI as `attachment_id` . 

```
Response 201 Created (verified — previously documented as 200 OK):
```

```
{ "attachment_id": "...", "url": "..." }
```

```
Implemented errors: 400 validation_error, 400 invalid_attachment
```

```
(The previously documented 422 error variants are NOT implemented.)
```

## **15. Audit Log** **<mark>[PENDING IMPLEMENTATION]</mark>** 

**Verified backend state:** there is **no** `AuditLog` entity, no `AuditLogsController` , and no audit-write hooks anywhere in the backend. The contract below is preserved as planned; the Backlog item previously marked Completed has been reopened. 

|**Planned Endpoint**|**Roles**|**Purpose**|**Status**|
|---|---|---|---|
|`GET /api/audit-`<br>`logs?page=&limit=&action=&user_id=`|Company_Owner,<br>HR_Manager|Paginated audit<br>trail of sensitive<br>actions (auth,<br>user status, leave<br>decisions,<br>document<br>finalization,<br>policy uploads)|**[PENDING**<br>**IMPLEMENTATION]**|



## **16. Standard Error Format (Public APIs)** 

```
{ "error": { "code": "snake_case_code", "message": "Human readable message." }
}
```

Common codes (verified in code): `validation_error, invalid_credentials, account_inactive, email_already_exists, invalid_role, department_not_found, department_in_use, employee_not_found, hire_date_in_future, leave_request_not_found, not_a_draft, not_pending, insufficient_leave_balance, attachment_required, invalid_attachment, user_not_found, invalid_current_password, invalid_refresh_token, template_not_found, ai_timeout, ai_unavailable, ai_response_error, ai_error` . 

## **17. Internal Error Envelope (M2M)** 

Internal endpoints use the same envelope as §16. The middleware-level failures return the flat verified shapes shown in §2.2 ( `{"error":"unauthorized"}` / `{"error":"missing_identity_headers"}` ). 

## **18. Tenant Isolation Rule** 

Every query is scoped by `CompanyId` (from JWT claims on public APIs, from `X-Company-Id` on M2M APIs). Cross-company access must return 404 (not 403) to avoid resource enumeration. Verified examples: internal leave APIs validate attachment ownership company-scoped; internal document save validates `employee_id` via the employee's department CompanyId. 

## **19. AI Server Implementation Notes** 

- Node.js service is plain JavaScript (ES Modules), Express, Zod validation, Winston logging, MongoDB Atlas for chat persistence, LangChain for LLM/RAG. 

- .NET HttpClient to Node uses a strict minimum 60-second timeout; gateway maps failures to `504 ai_timeout` / `502 ai_unavailable` . 

- Knowledge retrieval is scoped strictly by `companyId` or `null` (public labor law). 

- **Verified drift to fix:** Node `document-api.js` targets `POST /api/documents/save` and expects a response envelope the .NET backend does not return (see §10.7). Until reconciled, the AI document-save integration is broken. 

- Node leave-api client expects `{ request_id, status: "Draft", days_requested }` — matches the verified backend (§10.10). 

- Node employee/company context clients validate the snake_case shapes in §10.3– §10.4 — match the verified backend. 

Wakeel AI — Unified API Documentation (Version 9 Unified, backend-verified). Sources merged: API Documentation v8 (Full) + Generated Documents API Spec. Source of truth: .NET backend codebase. 

