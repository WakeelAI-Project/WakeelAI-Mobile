# **Wakeel AI — API Documentation** 

## Version 8 — AI Team Requirements Aligned 

_V5 Contracts Preserved · AI Team Contracts Integrated · V6 Additions Retained_ 

Base URL: https://api.wakeel-ai.com/v1 

Format: application/json unless stated otherwise (file uploads use multipart/form-data) 

### **Document Changelog** 

_This document consolidates all API contracts from Version 5 (the source of truth for all existing endpoints), Version 6 additions (internal AI leave workflow), and Version 8 alignment with the AI Team requirements. No existing V5 API has been modified, removed, or simplified unless required to align with an explicit AI Team requirement._ 

#### **Version 5 (Preserved)** 

- Full API catalog spanning authentication, users, company profile, departments, employees, leave requests, AI assistant gateway, all internal integrations, document templates, generated documents, company handbook, audit logs, error formats, and tenant isolation — every endpoint and every field preserved exactly as specified. 

- Internal integration endpoints (§10.1–§10.9) documented with formal field tables, types, required/optional markers, validation rules, header requirements, and response schemas. 

- Public endpoint catalog (§2–§8, §11–§15) fully preserved with request/response details. 

#### **Version 6 Additions (Retained)** 

- Internal AI Leave API: Three new M2M endpoints — POST /api/ai/leave-requests, PATCH /api/ai/leave-requests/{request_id}/submit, DELETE /api/ai/leave-requests/{request_id} — fully specified with field tables, validation rules, business rules, error codes, and integration behavior (§10.10–§10.12). 

- Pre-Chat Attachment Upload: New public endpoint POST /api/leave-requests/attachments — fully specified with multipart field name, file validation rules, and error responses (§14). 

- All new endpoints documented at the same formal contract level as V5 §10.3–§10.7. 

#### **Version 8 Additions — AI Team Requirements Alignment** 

- Chat Endpoint (§9.2, §10.1): Public POST /api/ai/chat endpoint aligned with AI Team requirement. Internal .NET → AI request body now includes a context object with userId, companyId, role, and conversationId fields, matching the AI architecture AIContext definition. 

- Employee Context (§10.3): Response schema updated from snake_case nested leave_balance to camelCase flat leaveBalance structure, matching the AI Team requirement exactly: { userId, companyId, fullName, role, department, employmentStatus, leaveBalance: { annual, used, remaining } }. 

- Company Context (§10.4): Response schema updated from snake_case to camelCase and expanded to include policyAvailable boolean field, matching the AI Team requirement exactly: { companyId, companyName, industry, workingHours, policyAvailable }. 

- Company Policy Upload (§13): Endpoint route updated from /company/policy-document to POST /api/company/policies, matching the AI Team required endpoint name. Functionality preserved: Owner uploads PDF, .NET extracts text, forwards to AI ingestion. 

- Knowledge Ingestion (§10.5): Request field renamed from sourceType to knowledgeType, matching the AI Team requirement exactly. All other fields, validation rules, and response schema preserved. 

- Document Save (§10.7): Request schema updated per AI Team requirement: employeeId and companyId moved into metadata object (metadata: { employeeId, companyId }), using camelCase throughout. Response schema updated to { success, documentId, status }. 

- Internal Leave API (§10.10): Required body field changed from attachment_id to attachment_url (string type), matching the screenshot requirement. 

- Integration Flow (§14): Updated to clearly state that the client passes the returned url (not attachment_id) back to the AI through field_values. 

#### **Version 8 Revisions to Existing Content** 

- M2M authentication header contract confirmed: all four headers (X-Internal-API-Key, X-User-Id, X- Company-Id, X-Role) required on every internal endpoint in both directions, including the new POST /api/company/policies ingestion call. 

- Internal AI leave endpoints explicitly added to the list of endpoints covered by the M2M header contract in §2.2. 

- Error code table (§16) expanded with leave-workflow-specific codes: not_a_draft, not_pending, attachment_required, invalid_attachment. 

- Tenant isolation rule (§18) reaffirmed and applied explicitly to all new and existing endpoints. 

- POST /chat/ask public endpoint (§9.2) documentation aligned: the public endpoint remains POST /api/ai/chat as specified by the AI Team, with .NET handling JWT authentication and forwarding to the AI server internally. 

### **1. Overview** 

Wakeel AI is a multi-tenant B2B SaaS: an AI-powered HR Compliance Assistant for Egyptian SMEs. Every company (tenant) has isolated data. The system utilizes a microservices architecture: 

- .NET 10 Backend: Manages RBAC, business logic, persistence (SQL Server), file storage, and acts as the API Gateway. 

- Node.js AI Service: Manages LLM orchestration (LangChain), RAG pipelines (MongoDB Atlas), vector embeddings, and AI chat persistence. 

The API enforces Tenant Isolation: every authenticated request carries a company_id inside its JWT, and every query on the backend must filter by that company_id. 

#### **Role-Based Access** 

|**Role**|**Client**|**Capabilities**|
|---|---|---|
|Company Owner|Web Dashboard|Company registration, HR account management, Department<br>management, Handbook upload, Audit Logs. Cannot manage<br>employees or use AI assistant.|
|HR Manager|Web Dashboard|Employee records, Document templates, Document<br>generation/review,Leave approval,AI assistant,Audit Logs.|
|Employee|Mobile App|Own profile, leave balances, own leave requests, own documents,<br>AI assistant(voice is client-side STT).|



### **2. Authentication** 

#### **2.1 User Authentication (JWT)** 

Wakeel AI uses JWT Bearer tokens (access + refresh token pattern) for Web and Mobile clients. Every JWT payload includes: 

```
{
  "user_id": "uuid",
```

```
  "company_id": "uuid",
  "role": "Company_Owner | HR_Manager | Employee",
  "exp": 1721568000
```

```
}
```

- Access token lifespan: 15 minutes. 

- Refresh token lifespan: 7 days. 

#### **2.2 Machine-to-Machine (M2M) Authentication [Internal] — Finalized** 

Server-to-server communication between the .NET backend and the Node.js AI service bypasses JWTs and uses an internal Pre-Shared Key (PSK), plus trusted identity headers. Every internal call, in both 

directions, carries all four headers below — there is no endpoint that uses a subset. The AI Server rejects any inbound request missing any of them, and never sends an outbound request to .NET without all four either. 

##### **Required Headers (all four, on every internal call in both directions):** 

```
X-Internal-API-Key: <WAKEEL_INTERNAL_API_KEY>
```

```
X-User-Id: <uuid>
```

```
X-Company-Id: <uuid>
```

```
X-Role: Company_Owner | HR_Manager | Employee
```

##### **This applies uniformly to all internal endpoints:** 

- POST /api/ai/chat 

- GET /api/ai/chat/history 

- POST /api/knowledge/ingest 

- GET /api/ai/employee-context 

- GET /api/ai/company-context 

- GET /api/ai/templates/active 

- POST /api/documents/save 

- POST /api/ai/leave-requests (new in v6) 

- PATCH /api/ai/leave-requests/{request_id}/submit (new in v6) 

- DELETE /api/ai/leave-requests/{request_id} (new in v6) 

- POST /api/company/policies → POST /api/knowledge/ingest (owner uploads policy, .NET forwards to AI ingestion) 

##### **Failure modes (identical on every internal endpoint):** 

- Missing/invalid X-Internal-API-Key → 401 UNAUTHORIZED_SERVICE 

- Missing X-User-Id / X-Company-Id / X-Role → 400 MISSING_IDENTITY_HEADERS 

#### **2.3 Register a Company (First-Time Signup)** 

##### **POST /auth/register-company (Public)** 

Creates a new company account and its Owner user in one step. 

```
{
  "company_name": "Acme Corp",
  "tax_id": "123456789",
  "owner_full_name": "Sara Ahmed",
  "owner_email": "sara@acme.com",
  "password": "StrongPassword123!"
}
```

##### **Response (201 Created):** 

```
{ "company_id": "c1a2...", "user_id": "u1a2...", "role": "Company_Owner",
"access_token": "eyJ...", "refresh_token": "eyJ..." }
```

#### **2.4 Log In** 

##### **POST /auth/login (Public)** 

```
{ "email": "hr@acme.com", "password": "TempPassword!" }
```

##### **Response (200 OK):** 

```
{ "user_id": "u1a2...", "company_id": "c1a2...", "role": "HR_Manager",
"access_token": "eyJ...", "refresh_token": "eyJ...", "expires_in": 900,
"must_change_password": true }
```

#### **2.5 Refresh an Access Token** 

##### **POST /auth/refresh (Public)** 

— { "refresh_token": "eyJ..." } → { "access_token": "eyJ...", "refresh_token": "eyJ...", "expires_in": 900 } 

#### **2.6 Log Out** 

##### **POST /auth/logout (Bearer token)** 

— Invalidates the refresh token server-side. Returns 204 No Content. 

### **3. Users (Owner)** 

#### **3.1 Invite an HR Manager** 

##### **POST /users/invite (Company Owner)** 

- Creates an HR Manager account and sends a credentials email with a temporary password. 

```
{ "full_name": "Mohamed Ali", "email": "mohamed@acme.com", "role":
"HR_Manager" }
```

##### **Response (201 Created):** 

```
{ "user_id": "u3f2...", "email": "mohamed@acme.com", "role": "HR_Manager",
"status": "invited" }
```

#### **3.2 List Company Users** 

##### **GET /users?role=HR_Manager&page=1&limit=20 (Company Owner)** 

- Returns paginated users. 

#### **3.3 Deactivate / Reactivate a User** 

##### **PATCH /users/{user_id}/status (Owner / HR)** 

- { "is_active": false }. Deactivation immediately revokes all active refresh tokens for the user. 

### **4. Company Profile** 

#### **4.1 Get My Company Profile** 

##### **GET /company/profile (Owner, HR Manager)** 

```
{
```

```
  "id": "c1a2...", "name": "Acme Corp", "tax_id": "123456789",
```

```
  "industry": "Tech", "address": "Cairo",
  "phone_number": "+20100000000", "email": "contact@acme.com",
```

```
  "logo_url": "/uploads/company_logos/abc.png",
```

```
  "working_hours": "09:00-17:00",
```

```
  "registered_at": "2026-07-21T09:00:00Z"
}
```

#### **4.2 Update Company Profile** 

##### **PUT /company/profile (Company Owner)** 

— multipart/form-data. Accepts updates to address, phone_number, email, industry, working_hours, and an optional image logo file. Returns the updated profile object. 

### **5. Departments** 

#### **5.1 List Departments** 

##### **GET /departments?page=1&limit=50 (Owner, HR Manager)** 

- Soft-deleted departments are always excluded. 

#### **5.2 Create a Department** 

##### **POST /departments (Company Owner)** 

```
{ "name": "Engineering", "description": "Software team" }
```

→ 201 Created Department object. 

#### **5.3 Update a Department** 

##### **PATCH /departments/{department_id} (Company Owner)** 

- Partial update for name and description. 

#### **5.4 Delete a Department (Soft Delete)** 

##### **DELETE /departments/{department_id} (Company Owner)** 

- Sets IsDeleted=true. If employees are assigned to this department, returns 409 department_in_use. 

### **6. Employees (HR Manager)** 

#### **6.1 Create an Employee** 

##### **POST /employees (HR Manager)** 

— Creates the USERS row and EMPLOYEE_PROFILE row, emails the temporary password, and initializes 

3 LEAVE_BALANCE rows automatically. 

```
{
  "full_name": "Ahmed Youssef", "email": "ahmed@acme.com",
```

```
  "job_title": "Developer", "department_id": "d3b1...",
  "hire_date": "2026-07-01", "salary": 12000,
```

```
  "contract_type": "Full-time", "national_id": "29001011234567"
```

```
}
```

_Note: national_id is nullable._ 

#### **6.2 List Employees** 

##### **GET /employees?status=Active&page=1&limit=20 (HR Manager)** 

#### **6.3 Get / Edit an Employee** 

- Get: GET /employees/{record_id} 

- Edit: PATCH /employees/{record_id} (Partial updates to profile fields). 

### **7. Employee Self-Service** 

#### **7.1 Get My Profile (with Leave Balances)** 

##### **GET /me (Employee)** 

— Returns the employee's personal profile combined with their live leave balances (Annual, Sick, Unpaid). 

### **8. Leave Requests** 

#### **8.1 Create a Leave Request (Draft)** 

##### **POST /leave-requests (Employee)** 

- multipart/form-data if an attachment is included (required for Sick leave), otherwise JSON. 

```
{
  "leave_type": "Sick",
  "start_date": "2026-08-01",
  "end_date": "2026-08-05",
  "reason": "Medical procedure"
```

```
}
```

_Note: Returns 201 Created with status: Draft._ 

#### **8.2 List Leave Requests (Role-Scoped)** 

##### **GET /leave-requests?status=Pending&page=1&limit=20 (Employee, HR Manager)** 

- Employee: Returns only the caller's requests (All statuses). 

- HR Manager: Returns company-wide submitted requests (Pending, Approved, Rejected). 

#### **8.3 Draft Actions** 

- Submit: PATCH /leave-requests/{request_id}/submit (Changes Draft to Pending). 

- Cancel: DELETE /leave-requests/{request_id} (Changes Draft to Cancelled; retained in history). 

#### **8.4 Approve / Reject a Leave Request (HR)** 

##### **PATCH /leave-requests/{request_id} (HR Manager)** 

```
{ "status": "Approved", "hr_note": "Enjoy your vacation" }
```

- On approval, LEAVE_BALANCE is deducted automatically in a transaction. 

### **9. AI Assistant (API Gateway Pattern) — Finalized** 

The .NET backend does not execute AI orchestration. These endpoints act as an API Gateway: .NET intercepts the JWT, extracts user identity, resolves/generates the conversationId, and proxies the payload securely to the Node.js AI Service using the internal M2M contract (§2.2, §10). 

#### **9.1 conversationId Lifecycle (Finalized — Decision 1)** 

The AI Server never generates a conversationId; .NET is solely responsible for it. 

- 1. Client sends POST /api/ai/chat with no conversation_id → this is a new conversation. 

- 2. .NET generates a new conversationId (UUID) and includes it in the conversationId field of the body it sends to POST /api/ai/chat on the AI Server. 

- 3. .NET returns that identifier to the client as conversation_id in the response. 

- 4. The client includes conversation_id on every subsequent POST /api/ai/chat and on GET /chat/history for that thread. 

- 5. .NET forwards the client-supplied conversation_id verbatim as conversationId to the AI Server. 

#### **9.2 Ask the Assistant** 

##### **POST /api/ai/chat (HR Manager, Employee)** 

##### **Client Request:** 

```
{
  "conversation_id": "cv77...",
  "message": "How many annual leave days do I have?",
  "language": "AR",
  "field_values": null
}
```

_The frontend does NOT send userId, companyId, or role — these are extracted from the authenticated JWT by .NET._ 

##### **Response (200 OK):** 

```
{
  "chat_id": "ch9d1...",
  "conversation_id": "cv77...",
  "reply": "You currently have 7 annual leave days remaining.",
  "sources": ["employee_leave_balance"],
  "missing_fields": null,
  "result_card": null,
  "created_at": "2026-07-21T10:20:00Z"
```

```
}
```

.NET builds this envelope itself — chat_id and created_at are generated by .NET, and reply/conversation_id are translated from the AI Server's message/conversationId fields. 

#### **9.3 Get My Chat History** 

##### **GET /chat/history?conversation_id=cv77...&page=1&limit=20 (HR Manager, Employee)** 

.NET proxies this request to the Node.js service (forwarding conversation_id as the required internal conversationId query parameter), which retrieves the history directly from MongoDB and returns it to the client. 

### **10. Internal AI Integrations [Server-to-Server]** 

_This section defines the internal endpoints used exclusively for Machine-to-Machine communication between the .NET Backend and the Node.js AI Service. Mandatory headers (all four): X-Internal-API-Key, X-User-Id, X-Company-Id, X-Role — as defined in §2.2._ 

#### **10.1 Forward Chat Handoff (.NET → Node.js)** 

##### **POST /api/ai/chat** 

|**Property**|**Detail**|
|---|---|
|Caller|.NET API Gateway|
|Direction|.NET→Node.js AI Service|
|Method|POST|
|Route|/api/ai/chat|
|Authentication|M2M — all four headers required(§2.2)|
|Content-Type|application/json|



##### **Request Body:** 

_The request body MUST include a context object carrying the user identity extracted from the JWT. This context object matches the AIContext definition in the AI architecture and MUST contain userId, companyId, role, and conversationId._ 

```
{
  "message": "How many annual leave days do I have?",
  "context": {
```

```
    "userId": "user-123",
    "companyId": "company-456",
    "role": "Employee",
    "conversationId": "conversation-789"
```

```
  }
```

```
}
```

|**Field**|**Type**|**Required**|**Notes**|
|---|---|---|---|
|message|string|Yes|The user's message to the AI assistant. Non-<br>empty.|
|context|object|Yes|Carrier object for user identity and<br>conversation context. Must contain userId,<br>companyId, role, and conversationId. This<br>object matches the AIContext definition in<br>the AI architecture.|
|context.userId|string (UUID)|Yes|The authenticated user ID extracted from the<br>JWT by.NET.|
|context.companyId|string (UUID)|Yes|The company ID extracted from the JWT by<br>.NET. Used for tenant isolation.|
|context.role|string|Yes|The user role extracted from the JWT:<br>Company_Owner,HR_Manager,or Employee.|



|context.conversationId|string (UUID)|Yes|The conversationId generated or forwarded<br>by .NET. .NET generates a new UUID when|
|---|---|---|---|
||||the client omits conversation_id(see§9.1).|



##### **Response:** 

The AI Server returns its internal chat response. .NET translates this into the client-facing envelope defined in §9.2. 

```
{
  "conversationId": "conversation-789",
  "message": "You currently have 7 annual leave days remaining.",
  "type": "text",
  "sources": [],
  "actions": []
}
```

#### **10.2 Fetch Chat History (.NET → Node.js)** 

##### **GET /api/ai/chat/history** 

|**Property**|**Detail**|
|---|---|
|Caller|.NET API Gateway|
|Direction|.NET→Node.js AI Service|
|Method|GET|
|Route|/api/ai/chat/history|
|Authentication|M2M — all four headers required(§2.2)|



##### **Query Parameters:** 

|**Parameter**|**Type**|**Required**|**Validation**|**Default**|
|---|---|---|---|---|
|conversationId|string|Yes|Non-empty. Must match a<br>conversation belonging to X-<br>User-Id + X-Company-Id.|—|
|page|integer|No|≥ 1|1|
|limit|integer|No|1–100|20|



##### **Response:** 

```
{
  "conversationId": "cv77...",
  "messages": [
```

```
    { "messageId": "string", "role": "user|assistant", "content": "string",
      "type": "string", "sources": [], "actions": [],
```

```
      "createdAt": "ISO string" }
  ],
  "pagination": { "page": 1, "limit": 20, "total": 0, "hasNextPage": false }
}
```

##### **Error Responses:** 

- 404 CONVERSATION_NOT_FOUND if the conversation does not belong to the requesting userId + companyId. 

#### **10.3 Fetch Employee Context (Node.js → .NET)** 

##### **GET /api/ai/employee-context** 

|**Property**|**Detail**|
|---|---|
|Caller|Node.js AI Service(EmployeeContextService)|
|Direction|Node.js→.NET Backend|
|Method|GET|
|Route|/api/ai/employee-context|
|Authentication|M2M — all four headers required(§2.2)|
|Authorization|Identity derived strictly from X-User-Id. X-User-Id is the authenticated requester<br>(HR manager or employee)— never a target-employee ID.|



##### **Important:** 

- X-User-Id is the authenticated requester (HR manager or employee) — never a target-employee ID. There is no name-based employee lookup through this endpoint, and no employeeName query parameter exists. 

##### **Required Response Schema (matches the AI Team requirement exactly):** 

```
{
  "userId": "user-123",
  "companyId": "company-456",
  "fullName": "Ahmed Ali",
  "role": "Employee",
  "department": "Engineering",
  "employmentStatus": "Active",
  "leaveBalance": {
    "annual": 12,
    "used": 5,
    "remaining": 7
  }
```

```
}
```

_leaveBalance contains only annual leave fields (annual, used, remaining). The leaveBalance object may be omitted or null if leave data is unavailable. The response uses camelCase field names as specified by the AI Team requirement._ 

|**Field**|**Type**|**Required**|**Notes**|
|---|---|---|---|
|userId|string (UUID)|Yes|The authenticated user ID. Matches<br>the userId in the request headers.|
|companyId|string (UUID)|Yes|The company ID. Used for tenant<br>isolation.|
|fullName|string|Yes|The employee's full name.|
|role|string|Yes|The user role: Company_Owner,<br>HR_Manager,or Employee.|
|department|string | null|Yes|The department name. Null if no<br>department is assigned.|
|employmentStatus|string | null|Yes|The employment status: Active or<br>Inactive.|
|leaveBalance|object | null|No|Flat object containing annual leave<br>balance only. May be omitted or null.<br>Contains annual (total days), used<br>(days taken), and remaining (days left).<br>Sick and unpaid leave balances are not<br>included in this endpoint response.|
|leaveBalance.annual|number|Yes|Total annual leave days available for<br>the currentyear.|
|leaveBalance.used|number|Yes|Number of annual leave days already<br>used.|
|leaveBalance.remaining|number|Yes|Remaining annual leave days (annual -<br>used).|



#### **10.4 Fetch Company Context (Node.js → .NET)** 

##### **GET /api/ai/company-context** 

|**Property**|**Detail**|
|---|---|
|Caller|Node.js AI Service(CompanyContextService)|
|Direction|Node.js→.NET Backend|
|Method|GET|
|Route|/api/ai/company-context|
|Authentication|M2M — all four headers required(§2.2)|



##### **Required Response Schema (matches the AI Team requirement exactly):** 

```
{
  "companyId": "company-456",
  "companyName": "Wakeel Technologies",
```

```
  "industry": "Technology",
```

```
  "workingHours": "09:00-17:00",
```

###### `"policyAvailable": true` 

###### `}` 

_The response uses camelCase field names as specified by the AI Team requirement. The policyAvailable field indicates whether company policy/handbook content is available in the RAG system for retrieval._ 

|**Field**|**Type**|**Required**|**Notes**|
|---|---|---|---|
|companyId|string (UUID)|Yes|The company ID. Used for tenant<br>isolation.|
|companyName|string|Yes|The companyname.|
|industry|string |null|Yes|The companyindustry. Null if not set.|
|workingHours|string | null|Yes|The company working hours (e.g.,<br>"09:00-17:00"). Null if not set.|
|policyAvailable|boolean|Yes|Indicates whether company<br>policy/handbook content is available in<br>the RAG system. true if a policy<br>document has been uploaded and<br>ingested;false otherwise.|



_No additional fields (tax_id, address, phone_number, email, logo_url, registered_at) are returned by this endpoint. Company profile data and RAG-indexed policy/handbook content are strictly separate: policy content is retrieved exclusively through RAG (§10.5), never through this endpoint. The policyAvailable flag is the only connection point — it informs the AI whether policy data exists for retrieval, without exposing the policy content itself._ 

#### **10.5 Ingest Knowledge (.NET → Node.js)** 

##### **POST /api/knowledge/ingest** 

|**Property**|**Detail**|
|---|---|
|Caller|.NET Backend (when HR uploads a handbook PDF; .NET extracts the raw text<br>first)|
|Direction|.NET→Node.js AI Service|
|Method|POST|
|Route|/api/knowledge/ingest|
|Authentication|M2M — all four headers required (§2.2). This endpoint now enforces the same<br>internal M2M authentication as everyother endpoint in this section.|
|Content-Type|application/json|



##### **Request Body:** 

```
{
  "companyId": "company-456",
  "knowledgeType": "company-policy",
  "documentId": "policy-123",
```

```
  "title": "Company Leave Policy",
```

```
  "content": "Full extracted policy text..."
```

```
}
```

**knowledgeType accepts exactly two values: labor-law, company-policy. The request body is strictly validated — no undeclared fields are accepted. The field was renamed from sourceType to knowledgeType to align with the AI Team requirement.** 

|**Field**|**Type**|**Required**|**Notes**|
|---|---|---|---|
|companyId|string (UUID)|Yes|The company that owns this policy<br>document.|
|knowledgeType|string (enum)|Yes|Exactly one of: "labor-law" or<br>"company-policy". No other values<br>accepted. Renamed from sourceType<br>per AI Team requirement.|
|documentId|string (UUID)|Yes|Unique identifier for this knowledge<br>document.|
|title|string|Yes|Human-readable title for the<br>document.|
|content|string|Yes|The full extracted text content to be<br>chunked and embedded.|



#### **10.6 Fetch Active Template (Node.js → .NET) — New in v5** 

##### **GET /api/ai/templates/active?documentType={documentType}** 

|**Property**|**Detail**|
|---|---|
|Caller|Node.js AI Service(Document Generation Skill)|
|Direction|Node.js→.NET Backend|
|Method|GET|
|Route|/api/ai/templates/active|
|Authentication|M2M — all four headers required(§2.2)|



##### **Query Parameters:** 

|**Parameter**|**Type**|**Required**|**Notes**|
|---|---|---|---|
|documentType|string|Yes|The document type to fetch the active<br>template for (e.g., "Contract",<br>"OfferLetter").|



##### **Required Response Schema:** 

```
{ "template_id": "string", "document_type": "string", "name": "string",
```

```
"content_template": "string" }
```

**.NET must return 404 if no active template exists for the company + document type combination, and must enforce the one-active-template-per-document-type-per-company rule server-side. The AI Server does not fabricate a template on a miss.** 

**10.7 Save Generated Document (Node.js → .NET) — Finalized (Decision 2)** 

##### **POST /api/documents/save** 

|**Property**|**Detail**|
|---|---|
|Caller|Node.js AI Service(DocumentGenerationService)|
|Direction|Node.js→.NET Backend|
|Method|POST|
|Route|/api/documents/save|
|Authentication|M2M — all four headers required(§2.2)|
|Content-Type|application/json|



##### **Request Body — Canonical, Strictly Validated, No Undeclared Fields Accepted.** 

_Identity fields (userId, companyId) are carried in the metadata object per the AI Team requirement. The X-User-Id and X-Company-Id headers provide the caller identity for authorization. The employeeId in metadata identifies the target employee the document is about — not the caller's identity._ 

```
{
```

```
  "documentType": "employment_contract",
```

```
  "title": "Employment Contract - Ahmed Ali",
```

```
  "content": "...generated document content...",
```

```
  "metadata": {
```

```
    "employeeId": "employee-123",
```

```
    "companyId": "company-456"
```

```
  }
```

###### `}` 

|**Field**|**Type**|**Required**|**Notes**|
|---|---|---|---|
|documentType|string|Yes|The type of document being saved<br>(e.g., "employment_contract").<br>Matches the document_type used to<br>fetch the active template(§10.6).|
|title|string|Yes|Human-readable document title.|
|content|string|Yes|Fully rendered document content, as<br>HTML orplain text.|
|metadata|object|Yes|Carrier object for document-related<br>identifiers. Contains employeeId (the<br>target employee the document is<br>about) and companyId. All identity<br>fields are grouped here per AI Team<br>requirement.|
|metadata.employeeId|string (UUID)|Yes|The target employee the document is<br>about. Not the caller's identity.|
|metadata.companyId|string (UUID)|Yes|The company the document belongs<br>to.|



##### **Response (matches the AI Team requirement):** 

```
{ "success": true, "documentId": "document-789", "status": "saved" }
```

|**Field**|**Type**|**Required**|**Notes**|
|---|---|---|---|
|success|boolean|Yes|Always true on successful save. false if<br>the save failed.|
|documentId|string (UUID)|Yes|The unique identifier of the saved<br>document.|
|status|string|Yes|The status of the saved document<br>(e.g.,"saved","Draft").|



_If success is false, or the response doesn't validate against this schema, the AI Server treats the save as failed and will not report a document as saved to the user._ 

_.NET remains the source of truth for document business persistence. The field names in the final contract must match the existing document entity/DTO in the .NET backend._ 

#### **10.8 Contract — Finalized: missing_fields** 

Returned as part of the POST /api/ai/chat response when the AI needs explicit input from the user (e.g., during future document generation): 

```
[
  { "field_name": "contract_type",
    "input_type": "text | number | dropdown | date | file",
```

```
    "label": "Contract Type",
    "options": ["Full-time", "Part-time"] }
```

```
]
```

##### **input_type enum has exactly five values: text, number, dropdown, date, file.** 

_options is optional — an array of strings when present (typically for dropdown fields), never null._ 

#### **10.9 Contract — Finalized: result_card** 

A discriminated union on type, with exactly three variants — no others exist: 

_// type: "calculation"_ 

```
{ "type": "calculation", "calculation_type": "string", "inputs": {}, "result":
0, "currency": "string?", "breakdown": []? }
```

_// type: "document_draft"_ 

```
{ "type": "document_draft", "doc_id": "string", "doc_type": "string",
"employee_id": "string?", "employee_name": "string?" }
```

_// type: "leave_draft"_ 

```
{ "type": "leave_draft", "request_id": "string", "leave_type": "string",
"start_date": "string", "end_date": "string", "days_requested": 0,
"attachment_uploaded": true, "actions": ["string"] }
```

**10.10 Internal AI Leave API — Create Leave Request Draft (Node.js → .NET)** 

**_NEW in v6 — Fully Specified · Retained in v8_** 

##### **POST /api/ai/leave-requests** 

|**Property**|**Detail**|
|---|---|
|Endpoint|POST/api/ai/leave-requests|
|Caller|Node.js AI Service(Leave Request Tool)|
|Direction|Node.js→.NET Backend|
|Method|POST|
|Route|/api/ai/leave-requests|
|Authentication|M2M — all four headers required (§2.2): X-Internal-API-Key, X-User-Id, X-<br>Company-Id,X-Role|
|Authorization|Employee role required. X-Role must be "Employee". The endpoint enforces the<br>Employee role and extracts ownershipstrictlyfrom X-User-Id.|
|Content-Type|application/json|
|Identity Rule|Does NOT accept employee_id in the request body. .NET derives the employee<br>exclusively from X-User-Id. X-User-Id is the authenticated requester — never a<br>target lookupkey.|



##### **Request Body — Strictly Validated. No undeclared fields accepted.** 

```
{
  "leave_type": "Annual",
  "start_date": "2026-08-01",
  "end_date": "2026-08-05",
  "reason": "Annual vacation",
```

```
  "attachment_url": "/uploads/leave-requests/550e8400-e29b-41d4-a716-
446655440000.pdf"
```

###### `}` 

|**Field**|**Type**|**Required**|**Validation Rules**|**Notes**|
|---|---|---|---|---|
|leave_type|string (enum)|Yes|Must be exactly one of:<br>"Annual", "Sick", "Unpaid".<br>Case-sensitive. No other<br>values accepted.|Matches the leave type<br>values used by the public<br>leave endpoint (§8.1).|
|start_date|string (date)|Yes|Format: YYYY-MM-DD (ISO<br>8601 date). Must not be in<br>the past (must be ≥<br>today's date). Must be ≤<br>end_date.|Date string in ISO 8601<br>date format.|
|end_date|string (date)|Yes|Format: YYYY-MM-DD.<br>Must be ≥ start_date.|Date string in ISO 8601<br>date format.|
|reason|string|No|Maximum 500 characters.<br>Rejected if exceeded.|Free-text explanation for<br>the leave request.<br>Optional.|
|attachment_url|string|No — Required<br>when|Must be a valid URL path<br>to apreviouslyuploaded|URL path to a previously<br>uploaded medical report|



|leave_type is|attachment (see §14).|attachment. Replaces|
|---|---|---|
|"Sick"|Required when leave_type|attachment_id as the|
||is "Sick"; optional for|required field per v8|
||"Annual" and "Unpaid".|update.|



##### **NOT ACCEPTED IN REQUEST BODY:** 

- employee_id — This field MUST NOT be included in the request body under any circumstances. If present, return 400 Bad Request with error code validation_error. The employee is derived exclusively from X-User-Id. 

- Any other undeclared fields — The request body is strictly validated. No fields beyond those listed above are accepted. 

##### **Response (201 Created):** 

```
{
  "request_id": "550e8400-e29b-41d4-a716-446655440000",
  "status": "Draft",
```

```
  "leave_type": "Annual",
```

```
  "start_date": "2026-08-01",
```

```
  "end_date": "2026-08-05",
```

```
  "days_requested": 5,
```

```
  "attachment_uploaded": true
```

```
}
```

|**Field**|**Type**|**Required**|**Notes**|
|---|---|---|---|
|request_id|string (UUID)|Yes|The unique identifier of the created<br>leave request. Used for subsequent<br>submit/cancel operations.|
|status|string|Yes|Always "Draft" for newly created<br>requests.|
|leave_type|string|Yes|Echoes the leave_type from the<br>request.|
|start_date|string|Yes|Echoes the start_date from the<br>request(YYYY-MM-DD format).|
|end_date|string|Yes|Echoes the end_date from the request<br>(YYYY-MM-DD format).|
|days_requested|integer|Yes|Number of calendar days requested<br>(end_date - start_date + 1).|
|attachment_uploaded|boolean|Yes|True if a valid attachment_url was<br>provided and validated; false<br>otherwise.|



##### **Business Rules:** 

- 1. The endpoint MUST NOT accept employee_id in the request body. If present, return 400 Bad Request with error code validation_error. This prevents the AI from spoofing employee IDs. 

- 2. The employee is derived exclusively from the X-User-Id header. The X-User-Id is the authenticated requester — never a target lookup key. 

- 3. The Employee role MUST be enforced. If X-Role is not "Employee", return 403 Forbidden. 

- 4. For Sick leave requests, attachment_url is REQUIRED. If leave_type is "Sick" and attachment_url is missing, null, or empty, return 422 Unprocessable Entity with error code attachment_required. 

- 5. The attachment_url must reference a valid, previously uploaded attachment (via §14). If the attachment_url does not exist, has been invalidated, or does not belong to the same company, return 422 Unprocessable Entity with error code invalid_attachment. 

- 6. Date validation: start_date must not be in the past (≥ today). end_date must be ≥ start_date. If dates are invalid, return 400 Bad Request with error code validation_error. 

- 7. Leave balance validation: For Annual and Sick leave types, the system checks the employee's available balance for the year of the start_date. If the requested days exceed the remaining balance, return 422 Unprocessable Entity with error code insufficient_leave_balance. 

- 8. Unpaid leave has no balance check (TotalDays is null for Unpaid in LEAVE_BALANCE). 

- 9. The endpoint reuses the existing LeaveRequestService — no business logic duplication. 

- 10. Tenant isolation: The company_id is derived from X-Company-Id header. The request is automatically scoped to the employee's company. Cross-company requests return 404 Not Found with error code leave_request_not_found. 

##### **Error Responses:** 

|**Status Code**|**Error Code**|**Condition**|
|---|---|---|
|400|validation_error|Invalid request body: missing required fields, invalid<br>date format (not YYYY-MM-DD), start_date in the<br>past, end_date < start_date, invalid leave_type<br>value,or employee_idpresent in request body.|
|400|MISSING_IDENTITY_HEADERS|Missing X-User-Id, X-Company-Id, or X-Role header<br>(§2.2).|
|401|UNAUTHORIZED_SERVICE|Missingor invalid X-Internal-API-Keyheader(§2.2).|
|403|FORBIDDEN|X-Role is not "Employee". Only employees can create<br>their own leave requests via the AI.|
|422|attachment_required|leave_type is "Sick" but attachment_url is missing,<br>null,or empty.|
|422|invalid_attachment|attachment_url references a non-existent,<br>invalidated,or cross-companyattachment.|
|422|insufficient_leave_balance|Requested days exceed the employee's available<br>balance for Annual or Sick leave in the relevantyear.|
|404|leave_request_not_found|Cross-company request detected (attachment<br>belongs to a different company, or employee not<br>found in the companyderived from X-Company-Id).|



##### **Internal Error Envelope (returned to Node.js on failure):** 

```
{ "success": false, "error": { "code": "ERROR_CODE", "message": "Human-
readable description" } }
```

##### **Integration Behavior:** 

- The Node.js Leave Request Tool calls this endpoint via the WakeelApiClient (wakeel-client.js), which attaches all four M2M headers automatically. 

- The attachment_url is gathered by the Mobile App / Web Client via the pre-chat upload flow (§14). The client uploads the file first, receives the url in the response, and then passes the url to the AI via field_values during the chat conversation. The AI Leave Request Tool then uses this url when calling this endpoint. 

- On success, the tool receives the response and formats it as a result_card of type "leave_draft" (§10.9) to present to the user. 

- The request is created with status "Draft". The employee can later submit it via §10.11 or cancel it via §10.12, or via the public endpoints (§8.3). 

#### **10.11 Internal AI Leave API — Submit Draft (Node.js → .NET)** 

##### **_NEW in v6 — Fully Specified · Retained in v8_** 

##### **PATCH /api/ai/leave-requests/{request_id}/submit** 

|**Property**|**Detail**|
|---|---|
|Endpoint|PATCH/api/ai/leave-requests/{request_id}/submit|
|Caller|Node.js AI Service(Leave Request Tool)|
|Direction|Node.js→.NET Backend|
|Method|PATCH|
|Route|/api/ai/leave-requests/{request_id}/submit|
|Authentication|M2M — all four headers required (§2.2): X-Internal-API-Key, X-User-Id, X-<br>Company-Id,X-Role|
|Authorization|Employee role required. X-Role must be "Employee".|
|Content-Type|application/json|
|Request Body|None (empty body). This is a state transition endpoint that requires no<br>additional data.|



##### **Path Parameters:** 

|**Parameter**|**Type**|**Required**|**Validation**|**Notes**|
|---|---|---|---|---|
|request_id|string (UUID)|Yes|Must be a valid UUID v4<br>format. Must match an<br>existing leave request<br>belonging to the employee<br>identified byX-User-Id.|The ID of the draft<br>leave request to<br>submit.|



##### **Response (200 OK):** 

- `{ "request_id": "550e8400-e29b-41d4-a716-446655440000", "status": "Pending" }` 

|**Field**|**Type**|**Required**|**Notes**|
|---|---|---|---|
|request_id|string (UUID)|Yes|The unique identifier of the submitted<br>leave request.|
|status|string|Yes|Always "Pending" after successful<br>submission.|



##### **Business Rules:** 

- 1. The target leave request MUST be in "Draft" status. If the request is in any other status (Pending, Approved, Rejected, Cancelled), return 409 Conflict with error code not_a_draft. 

- 2. This endpoint transitions the request from "Draft" to "Pending". It does NOT approve the request — approval is handled exclusively by the HR Manager via the public endpoint (§8.4). 

- 3. The employee is derived from X-User-Id. The request must belong to the employee identified by X-User-Id. If the request belongs to a different employee, return 404 Not Found with error code leave_request_not_found. 

- 4. The request must belong to the same company as derived from X-Company-Id. Cross-company requests return 404 Not Found. 

- 5. Tenant isolation applies: cross-tenant access returns 404 Not Found, never 403 Forbidden — to prevent data existence leaks. 

- 6. This endpoint reuses the existing LeaveRequestService.SubmitDraftAsync — no business logic duplication. 

##### **Error Responses:** 

|**Status Code**|**Error Code**|**Condition**|
|---|---|---|
|400|validation_error|Invalid UUID format for request_idpathparameter.|
|400|MISSING_IDENTITY_HEADERS|Missing X-User-Id, X-Company-Id, or X-Role header<br>(§2.2).|
|401|UNAUTHORIZED_SERVICE|Missingor invalid X-Internal-API-Keyheader(§2.2).|
|403|FORBIDDEN|X-Role is not "Employee".|
|404|leave_request_not_found|Request not found, belongs to another employee, or<br>belongs to another company.|
|409|not_a_draft|Request is not in Draft status (already Pending,<br>Approved, Rejected, or Cancelled). Cannot submit a<br>request that is alreadyin a non-Draft state.|



##### **Internal Error Envelope (returned to Node.js on failure):** 

```
{ "success": false, "error": { "code": "ERROR_CODE", "message": "Human-
readable description" } }
```

##### **Integration Behavior:** 

- After creating a draft (§10.10), the Node.js Leave Request Tool can submit it by calling this endpoint with the request_id returned from the draft creation. 

- On success, the tool receives the response and can inform the user that the leave request has been submitted and is now pending HR review. 

- If the tool receives a 409 not_a_draft, it should inform the user that the request has already been submitted or is in another non-Draft state. 

#### **10.12 Internal AI Leave API — Cancel Draft (Node.js → .NET)** 

##### **_NEW in v6 — Fully Specified · Retained in v8_** 

##### **DELETE /api/ai/leave-requests/{request_id}** 

|**Property**|**Detail**|
|---|---|
|Endpoint|DELETE/api/ai/leave-requests/{request_id}|
|Caller|Node.js AI Service(Leave Request Tool)|
|Direction|Node.js→.NET Backend|
|Method|DELETE|
|Route|/api/ai/leave-requests/{request_id}|
|Authentication|M2M — all four headers required (§2.2): X-Internal-API-Key, X-User-Id, X-<br>Company-Id,X-Role|
|Authorization|Employee role required. X-Role must be "Employee".|
|Content-Type|N/A(DELETE request with no body)|
|Request Body|None.|



##### **Path Parameters:** 

|**Parameter**|**Type**|**Required**|**Validation**|**Notes**|
|---|---|---|---|---|
|request_id|string (UUID)|Yes|Must be a valid UUID v4<br>format. Must match an<br>existing leave request<br>belonging to the employee<br>identified byX-User-Id.|The ID of the draft<br>leave request to<br>cancel.|



##### **Response:** 

204 No Content — The request was successfully cancelled. No response body is returned. 

##### **Business Rules:** 

- 1. The target leave request MUST be in "Draft" status. If the request is in any other status (Pending, Approved, Rejected, Cancelled), return 409 Conflict with error code not_a_draft. 

- 2. Cancellation transitions the request to "Cancelled" status. The request is retained in history (not deleted from the database) for audit purposes. 

- 3. The employee is derived from X-User-Id. The request must belong to the employee identified by X-User-Id. If the request belongs to a different employee, return 404 Not Found with error code leave_request_not_found. 

- 4. The request must belong to the same company as derived from X-Company-Id. Cross-company requests return 404 Not Found. 

- 5. Tenant isolation: cross-tenant access returns 404 Not Found, never 403 Forbidden. 

- 6. This endpoint reuses the existing LeaveRequestService.CancelDraftAsync — no business logic duplication. 

##### **Error Responses:** 

|**Status Code**|**Error Code**|**Condition**|
|---|---|---|
|400|validation_error|Invalid UUID format for request_idpathparameter.|
|400|MISSING_IDENTITY_HEADERS|Missing X-User-Id, X-Company-Id, or X-Role header<br>(§2.2).|
|401|UNAUTHORIZED_SERVICE|Missingor invalid X-Internal-API-Keyheader(§2.2).|
|403|FORBIDDEN|X-Role is not "Employee".|
|404|leave_request_not_found|Request not found, belongs to another employee, or<br>belongs to another company.|
|409|not_a_draft|Request is not in Draft status (already Pending,<br>Approved, Rejected, or Cancelled). Cannot cancel a<br>request that is alreadyin a non-Draft state.|



##### **Internal Error Envelope (returned to Node.js on failure — note: 204 No Content on success means no body):** 

```
{ "success": false, "error": { "code": "ERROR_CODE", "message": "Human-
readable description" } }
```

##### **Integration Behavior:** 

- The Node.js Leave Request Tool can cancel a draft by calling this endpoint with the request_id returned from draft creation (§10.10). 

- On 204 No Content, the tool confirms cancellation to the user. 

- If the tool receives a 409 not_a_draft, it should inform the user that the request has already been submitted, approved, rejected, or cancelled and cannot be cancelled further. 

### **11. Document Templates** 

Managed strictly by HR in the .NET backend (used by AI as context for generation via §10.6). 

- GET /templates 

- GET /templates/{template_id} 

- POST /templates 

- PATCH /templates/{template_id} 

- DELETE /templates/{template_id} 

### **12. Generated Documents** 

Lifecycle: AI generates content (via Node.js, using §10.6/§10.7) → Saves as Draft (in .NET) → HR Reviews → Edits → Finalizes → Exports PDF/Emails. 

##### **Endpoints:** 

- GET /documents (HR: company-wide, Employee: own only). 

- GET /documents/{doc_id} 

- PATCH /documents/{doc_id} (Edit Draft). 

- POST /documents/{doc_id}/finalize (Locks edits, generates PDF). 

- POST /documents/{doc_id}/send-email (Sends finalized PDF to employee). 

### **13. Company Policy Upload** 

##### **POST /api/company/policies (Company Owner)** 

— multipart/form-data (PDF upload). .NET extracts the text and securely forwards the payload (with the required internal headers) to the Node.js POST /api/knowledge/ingest endpoint (§10.5) to update the Vector DB. Returns indexed_for_rag: true. 

_This endpoint was updated in v8 from /company/policy-document to /api/company/policies to align with the AI Team requirement._ 

##### **Request:** 

_multipart/form-data. The request contains a file field with the policy document (PDF format). The companyId is NOT sent in the body — it is derived from the authenticated Owner's JWT._ 

##### **Flow:** 

- 1. Owner sends POST /api/company/policies with a PDF file (multipart/form-data). 

- 2. .NET authenticates the Owner via JWT Bearer token and extracts the companyId from the JWT. 

- 3. .NET extracts the raw text from the uploaded PDF. 

- 4. .NET creates a policy/document ID and calls POST /api/knowledge/ingest (§10.5) with the extracted text, using M2M headers. 

- 5. The AI Server chunks the text, generates embeddings (BGE-M3, 1024 dimensions), and stores the chunks in MongoDB Atlas Vector Search. 

- 6. .NET returns { "indexed_for_rag": true } to the Owner. 

#### **14. Pre-Chat Attachment Upload (Public) — New in v6** 

##### **_FULLY SPECIFIED_** 

##### **POST /api/leave-requests/attachments** 

|**Property**|**Detail**|
|---|---|
|Endpoint|POST/api/leave-requests/attachments|
|Caller|Mobile App /Web Client(Employee)|
|Direction|Client→.NET Backend|
|Method|POST|
|Route|/api/leave-requests/attachments|
|Authentication|JWT Bearer Token (§2.1). The Authorization header must contain a valid access<br>token.|
|Authorization|Employee role required. Only authenticated employees can upload medical<br>report attachments.|
|Content-Type|multipart/form-data. The request must be a multipart form upload — NOT JSON.|
|Purpose|Allows clients to upload a medical report file BEFORE instructing the AI to create<br>a sick leave request. The AI internal network (§10.10–§10.12) communicates<br>purely via JSON and cannot handle file uploads directly. This endpoint bridges<br>thatgapby providingan attachment_url that the AI can reference.|



##### **Multipart Form Fields:** 

|**Field Name**|**Type**|**Required**|**Validation Rules**|**Notes**|
|---|---|---|---|---|
|file|file (binary)|Yes|MIME types: application/pdf,<br>image/jpeg, image/png. Maximum<br>file size: 10MB (10,485,760 bytes).<br>Minimum file size: 1 byte.|The medical report file<br>to upload. This is the<br>ONLY field in the<br>multipart request. The<br>field name is literally<br>"file" — clients must<br>use this exact field<br>name.|



##### **File Field Name:** 

**The multipart form field name for the uploaded file is "file". Clients MUST use this exact field name in their multipart form data. If a different field name is used, the server returns 400 Bad Request with error code validation_error.** 

##### **File Validation Rules:** 

- 1. Allowed file types: PDF (application/pdf), JPEG (image/jpeg), PNG (image/png). No other file types are accepted. 

- 2. Maximum file size: 10MB (10,485,760 bytes). Files exceeding this limit are rejected. 

- 3. Minimum file size: 1 byte. Empty files (0 bytes) are rejected. 

- 4. The file is stored in the .NET backend's file storage system (same system used for other file uploads, e.g., company logos, leave request attachments). 

- 5. The file is associated with the authenticated employee's company (derived from the JWT). 

##### **Response (200 OK):** 

```
{ "attachment_id": "550e8400-e29b-41d4-a716-446655440000", "url":
"/uploads/leave-requests/550e8400-e29b-41d4-a716-446655440000.pdf" }
```

_The response contains two fields: attachment_id (a unique identifier for the uploaded attachment) and url (the relative URL path to access the uploaded file)._ 

|**Field**|**Type**|**Required**|**Notes**|
|---|---|---|---|
|attachment_id|string (UUID)|Yes|Unique identifier for the uploaded<br>attachment. Used internally by the<br>.NET backend to reference this upload.|
|url|string|Yes|Relative URL path to the uploaded file<br>(e.g., "/uploads/leave-<br>requests/550e8400-e29b-41d4-a716-<br>446655440000.pdf"). This is a relative<br>path — not a full absolute URL. Clients<br>can use this path to download or<br>display the file within the application<br>context.|



##### **Business Rules:** 

- 1. Only employees can upload attachments. If the authenticated user's role (from JWT) is not "Employee", return 403 Forbidden. 

- 2. The attachment is scoped to the employee's company (derived from JWT company_id claim). Cross-company access is not possible. 

- 3. Each upload creates a new attachment record. The same file uploaded twice creates two separate attachment records with different attachment_ids. 

- 4. The url returned in the response is the path the client MUST pass back to the AI (not the attachment_id). 

- 5. Attachments are retained until explicitly deleted by the system (no user-facing delete endpoint exists in the current API). 

- 6. Tenant isolation: attachments are scoped to the employee's company. Cross-tenant attachment access returns 404 Not Found. 

##### **Error Responses:** 

|**Status Code**|**Error Code**|**Condition**|
|---|---|---|
|400|validation_error|No file field in the multipart request, or file field is<br>empty (0 bytes), or the multipart request is<br>malformed(not valid multipart/form-data).|
|400|invalid_attachment|File type is not allowed (not PDF, JPG, or PNG). File<br>exceeds 10MB maximum size. File is empty (0 bytes).|
|401|Unauthorized|Missing or invalid JWT Bearer token in the<br>Authorization header.|



|403|Forbidden|Authenticated user exists but is not an Employee<br>(e.g., Company_Owner or HR_Manager attempting<br>to upload).|
|---|---|---|
|422|invalid_attachment|Alternative error code for file validation failures<br>(type not supported, file too large). Both 400<br>invalid_attachment and 422 invalid_attachment may<br>be used depending on whether the request format is<br>valid but the file content is invalid (422) vs. the<br>request itself is malformed(400).|
|422|attachment_missing|No file was provided in the request — the "file" field<br>is absent from the multipart form data.|



##### **Integration Flow (Updated in v8):** 

- Step 1: The Mobile App / Web Client uploads a medical report file via POST /api/leaverequests/attachments. The request uses multipart/form-data with a "file" field. 

- Step 2: The server validates the file (type, size), stores it, and returns an attachment_id and url in the response. 

- Step 3: The client passes the returned url (NOT the attachment_id) to the AI via field_values during the chat conversation (e.g., in the POST /api/ai/chat request body). The url is the path the AI needs to reference the uploaded file. 

- Step 4: The AI (Node.js Leave Request Tool) uses the url received via field_values when calling POST /api/ai/leave-requests (§10.10) to create a Sick leave draft. The url is included in the attachment_url field of the request body. 

- Step 5: The .NET backend validates that the attachment_url references a valid, existing attachment that belongs to the same company, then associates it with the created leave request. 

### **15. Audit Log (Read-Only)** 

**GET /audit-logs?user_id=&action=&page=1&limit=50 (Company Owner, HR Manager)** 

— Immutable ledger of all sensitive business actions (e.g., DOCUMENT_GENERATED, LEAVE_APPROVED). 

### **16. Standard Error Format & Business Codes** 

##### **Client-facing errors follow the same envelope:** 

```
{ "error": "error_code", "message": "Human-readable description", "status":
400 }
```

##### **Common Error Codes:** 

|**Status Code**|**Error Code**|**Meaning**|
|---|---|---|
|401|Unauthorized|Missingor invalid token.|
|403|Forbidden|Authenticated but forbidden.|
|404|Not Found|Resource not found(or belongs to another tenant).|
|409|Conflict|State conflict.|
|422|Unprocessable Entity|Business rule violation.|
|429|Too ManyRequests|Rate limit exceeded(includes Retry-After header).|



##### **Common Leave Workflow Codes:** 

|**Status Code**|**Error Code**|**Meaning**|
|---|---|---|
|404|leave_request_not_found|The requested leave request does not exist, belongs<br>to another employee, or belongs to another<br>company. Returns 404 (not 403) to prevent data<br>existence leaks.|
|409|not_a_draft|Cannot submit or cancel a request that is already<br>Pending/Approved/Rejected/Cancelled. The request<br>must be in Draft status to perform these actions.<br>Applies to both public (§8.3) and internal AI (§10.11,<br>§10.12)leave endpoints.|
|409|not_pending|HR cannot approve or reject a request that is not in<br>Pendingstatus(e.g.,tryingto approve a Draft).|
|422|insufficient_leave_balance|The requested number of leave days exceeds the<br>employee's available balance for the given leave<br>type andyear.|
|422|attachment_required|Sick leave requested without an attachment_url. A<br>medical report attachment is mandatory for Sick<br>leave requests. Applies to both public (§8.1) and<br>internal AI(§10.10)leave endpoints.|
|422|invalid_attachment|The provided attachment_url does not exist, has<br>been invalidated, is not a valid URL path, or does not<br>belong to the same company as the employee.<br>Applies to both public and internal AI leave<br>endpoints.|



**Note: .NET translates the internal AI Server error envelope (§17) into the standard client-facing format above. It must never pass the internal envelope straight through to a client.** 

### **17. Internal Error Envelope (AI Server)** 

The AI Server (Node.js) uses a different error envelope for its internal responses. This envelope is used when the AI Server returns errors to the .NET backend, or when .NET proxies errors from the AI Server back to the client (after translation per §16). 

```
{ "success": false, "error": { "code": "ERROR_CODE", "message": "Human
readable message" } }
```

**Secrets and stack traces are never exposed, even for 500 errors.** 

### **18. Tenant Isolation Rule (Strict)** 

- 1. company_id is NEVER accepted from the client request body; it is extracted strictly server-side from the JWT (for public endpoints) or from the internal X-Company-Id header (for M2M endpoints). Never from a request body. 

- 2. Every single database query in .NET (SQL Server) and Node.js (MongoDB) must filter by company_id. No query may execute without an explicit company_id filter unless it operates on global/shared data (e.g., labor law knowledge chunks). 

- 3. Requesting a cross-tenant resource (or cross-employee resource) returns a generic 404 Not Found (never 403), preventing bad actors from probing data existence. This applies identically to: 

- AI-owned chat history (§10.2) — conversations not belonging to the requesting userId + companyId return 404 CONVERSATION_NOT_FOUND. 

- Employee context (§10.3) — employees not found in the requesting company return appropriate errors. 

- Internal AI leave requests (§10.10–§10.12) — leave requests belonging to other employees or other companies return 404 leave_request_not_found. 

- Generated documents, attachments, templates — any resource scoped to a company. 

- Company policy uploads (§13) — policy documents are scoped to the uploading Owner's company. 

- Knowledge ingestion (§10.5) — chunks are scoped to the companyId provided in the request, which must match the company of the authenticated Owner (for public uploads) or the X-Company-Id header (for internal calls). 

**19. AI Server Implementation Notes (Informational — for Backend Awareness)** During the V5 reconciliation, two implementation defects were found and fixed directly in the AI Server codebase (not exposed as contract changes — the fixes make the AI Server match what this document already specifies): 

- POST /api/knowledge/ingest was previously reachable without the internal M2M authentication middleware. It is now protected identically to every other endpoint in §10. 

- template-api.js and document-api.js referenced an internal function name that did not exist in the shared HTTP client module, which would have caused a runtime failure the first time either integration was actually invoked outside of mocked unit tests. This has been corrected and both modules now share the same internal client function. 

_Both fixes are covered by the AI Server's automated test suite (111 tests passing across 21 suites; 2 database-dependent integration suites are skipped outside a live MongoDB environment, unrelated to this change)._ 

- _End of Document —_ 

_Wakeel AI API Documentation v8 · V5 contracts preserved · V6 additions retained · AI Team requirements integrated_ 

