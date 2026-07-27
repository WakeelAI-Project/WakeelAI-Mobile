# — Wakeel AI API Documentation 

Version: v1 Base URL: `https://api.wakeel-ai.com/v1` Format: All requests and responses use `application/json` unless stated otherwise (file uploads use `multipart/form-data` ). 

## 1. Overview 

- Wakeel AI is a multi tenant B2B SaaS. Every company (tenant) has isolated data. The API enforces Tenant Isolation: every authenticated request carries a `company_id` inside its JWT, and every query on the backend must filter by that `company_id` — regardless of what the client sends. Clients never pass `company_id` manually in the request body; it is always derived from the token. 

### Three roles consume this API: 

Role Client Typical Endpoints `Company_Owner` Web Dashboard Company setup, user invitations, policy upload `HR_Manager` Web Dashboard Employee records, document generation, leave approval `Employee` Mobile App Own profile, AI chat, leave requests 

## 2. Authentication 

### 2.1 Method 

### Wakeel AI uses JWT Bearer tokens (access + refresh token pattern). 

```
Authorization: Bearer <access_token>
```

### Every JWT payload includes: 

json `{ "user_id": "uuid", "company_id": "uuid", "role": "Company_Owner | HR_Manager | Employee", "exp": 1721568000 }` 

### Access token lifespan: 15 minutes 

Refresh token lifespan: 7 days, stored as an httpOnly cookie (web) or secure storage (mobile) 

### 2.2 Endpoints 

#### **`POST /auth/register-company`** 

Creates a new company account and its Owner user in one step (first-time signup only). 

Request 

json `{ "company_name": "Acme Corp", "tax_id": "123456789", "owner_full_name": "Sara Ahmed", "owner_email": "sara@acme.com", "password": "StrongPassword123!" }` 

### Response **`201 Created`** 

json `{ "company_id": "c1a2...", "user_id": "u1a2...", "role": "Company_Owner", "access_token": "eyJ...", "refresh_token": "eyJ..." }` 

#### **`POST /auth/login`** 

### Used by all three roles. 

### Request 

json 

```
{
"email": "hr@acme.com",
"password": "StrongPassword123!"
}
```

### Response **`200 OK`** 

json `{ "user_id": "u1a2...", "company_id": "c1a2...", "role": "HR_Manager", "access_token": "eyJ...", "refresh_token": "eyJ...", "expires_in": 900 }` 

### Errors 

Status Body Meaning `401 {"error": "invalid_credentials"}` Wrong email/password `403 {"error": "account_inactive"}` User deactivated by Owner/HR 

```
POST /auth/refresh
```

### Request 

json `{ "refresh_token": "eyJ..." }` 

### Response **`200 OK`** 

json 

- `{ "access_token": "eyJ...", "expires_in": 900 }` 

#### **`POST /auth/logout`** 

Invalidates the refresh token. Requires Bearer token. Returns `204 No Content` . 

## 3. Owner Endpoints 

All endpoints below require `role: Company_Owner` . 

### 3.1 Invite / Add Users 

#### **`POST /users/invite`** 

- Invites an HR Manager or Employee. Sends an email with a signup link (or auto creates the account with a temp password, depending on your flow). 

Request 

json `{ "full_name": "Mohamed Ali", "email": "mohamed@acme.com", "role": "HR_Manager" }` 

### Response **`201 Created`** 

json `{ "user_id": "u3f2...", "email": "mohamed@acme.com", "role": "HR_Manager", "status": "invited" }` 

### 3.2 List Company Users 

#### **`GET /users?role=HR_Manager&page=1&limit=20`** 

### Response **`200 OK`** 

json 

`{ "data": [ { "user_id": "u3f2...", "full_name": "Mohamed Ali", "role": "HR_Manager", "is_ac ], "page": 1, "total": 4 }`   

### 3.3 Deactivate a User 

```
PATCH /users/{user_id}/status
```

### Request 

json `{ "is_active": false }` 

Response **`200 OK`** → returns the updated user object. 

### 3.4 Upload Employee Handbook / Company Policy 

```
POST /company/policy-document
```

```
multipart/form-data
```

|Field|Type|Description|
|---|---|---|
|`file`|fle(PDF)|The employee handbook|
|`title`|string|e.g. "Employee Handbook2026"|



### Response **`201 Created`** 

json `{ "document_id": "d9a1...", "title": "Employee Handbook 2026", "pdf_url": "https://storage.wakeel-ai.com/policies/d9a1....pdf", "indexed_for_rag": true }` 

This document is chunked and embedded into the company's private vector index, so ' — ' the AI chat only retrieves from this company s policy never another tenant s. 

## 4. HR Manager Endpoints 

Requires `role: HR_Manager` (Owner may also access these, depending on your permission matrix). 

### 4.1 Create Employee Record 

```
POST /employees
```

### Request 

json `{ "full_name": "Ahmed Youssef", "email": "ahmed@acme.com", "job_title": "Developer", "hire_date": "2026-07-01", "salary": 12000, "contract_type": "Full-time" }` 

### Response **`201 Created`** 

json `{ "user_id": "u5c1...", "record_id": "r7d2...", "full_name": "Ahmed Youssef", "job_title": "Developer", "salary": 12000, "employment_status": "Active" }` 

### 4.2 Edit Employee Record 

```
PATCH /employees/{record_id}
```

Request (partial update, any subset of fields) 

json `{ "salary": 13500, "job_title": "Senior Developer" }` 

### Response **`200 OK`** → updated record object. 

### 4.3 List Employees 

#### **`GET /employees?status=Active&page=1&limit=20`** 

### Response **`200 OK`** 

json `{ "data": [ { "record_id": "r7d2...", "full_name": "Ahmed Youssef", "job_title": "Developer" ], "page": 1, "total": 34 }`   

### - 4.4 Generate a Document (AI powered) 

#### **`POST /documents/generate`** 

### This is the core "AI generates paperwork" feature. 

Request 

json `{ "employee_id": "u5c1...", "doc_type": "Contract", "prompt": "Create a contract for Ahmed, Developer, 12,000 EGP" }` 

### Response **`201 Created`** 

json `{ "doc_id": "g4f1...", "doc_type": "Contract", "pdf_url": "https://storage.wakeel-ai.com/docs/g4f1....pdf", "created_at": "2026-07-21T10:15:00Z" }` Supported **`doc_type`** values: `Contract` , `Warning_Letter` , `Resignation_Letter` 

### Errors 

|Status|Body|Meaning|
|---|---|---|
|`422`|`{"error": "missing_employee_data", "fields":`|<br>Notenough datatogenerate|
||`["salary"]}`|the document|
|`404`|`{"error": "employee_not_found"}`|Employee doesn'tbelongto<br>thiscompany|



### 4.5 List Leave Requests (pending approval) 

#### **`GET /leave-requests?status=Pending`** 

### Response **`200 OK`** 

json `{ "data": [ { "request_id": "l1a2...", "employee_id": "u5c1...", "employee_name": "Ahmed Youssef", "leave_type": "Annual", "start_date": "2026-08-01", "end_date": "2026-08-05", "days_requested": 5, "status": "Pending" } ] }` 

### 4.6 Approve / Reject a Leave Request 

#### **`PATCH /leave-requests/{request_id}`** 

### Request 

json 

```
{"status": "Approved","hr_note": "Enjoy your vacation"}
```

Response **`200 OK`** → updated request; if approved, the employee's `LEAVE_BALANCE` is decremented automaticall . y 

## 5. Employee Endpoints 

Requires `role: Employee` . All results are automatically scoped to `user_id` from the JWT 

— an employee can never fetch another employee's data. 

### 5.1 Get My Profile 

#### **`GET /me`** 

Response **`200 OK`** 

json 

```
{
"user_id": "u5c1...",
"full_name": "Ahmed Youssef",
"job_title": "Developer",
"salary": 12000,
"hire_date": "2026-07-01",
"leave_balances": [
{"leave_type": "Annual","balance": 16,"year": 2026},
{"leave_type": "Sick","balance": 5,"year": 2026}
]
}
```

### 5.2 Submit a Leave Request 

#### **`POST /leave-requests`** 

### Request 

json `{ "leave_type": "Annual", "start_date": "2026-08-01", "end_date": "2026-08-05" }` 

### Response **`201 Created`** 

json 

```
{
"request_id": "l1a2...",
"status": "Pending",
"days_requested": 5
}
```

### Errors 

Status Body Meaning `422` <mark>`{"error": "insufficient_balance", "available":`</mark> Not enough leave <mark>`3}`</mark> balance 

### 5.3 Ask the AI Assistant 

#### **`POST /chat/ask`** 

### Request 

json `{ "message": "` عندي؟ باقي اإلجازات رصید كام `", "language": "AR" }` 

Response **`200 OK`** 

json `{ "chat_id": "ch9d1...", "reply": "2026` لعام يوم `16` ھو السنوية اإلجازة من الحالي رصیدك `.", "sources": ["employee_leave_balance", "company_policy_doc"], "created_at": "2026-07-21T10:20:00Z" }` 

The RAG pipeline retrieves context strictly from: (1) this employee's own records, (2) this company's policy documents, (3) a general Egyptian Labor Law knowledge base — never from another tenant's data. 

### 5.4 Get My Chat History 

**`GET /chat/history?page=1&limit=20`** Response **`200 OK`** 

json `{ "data": [ { "chat_id": "ch9d1...", "sender": "employee", "message": "...", "created_at": " { "chat_id": "ch9d2...", "sender": "system", "message": "...", "created_at": ".. ] }`   

## - 6. Audit Log (Owner / HR read only) 

**`GET /audit-logs?user_id=&action=&page=1&limit=50`** Response **`200 OK`** 

json `{ "data": [ { "log_id": "al1...", "user_id": "u3f2...", "action": "GENERATE_DOCUMENT", "resource_type": "Contract", "created_at": "2026-07-21T09:00:00Z" } ], "page": 1, "total": 210 }` 

## 7. Standard Error Format 

### All errors follow the same envelope: 

json 

```
{
"error": "error_code",
"message": "Human-readable description",
"status": 400
}
```

#### Status Meaning 

`400` Bad request / validation error `401` Missing or invalid token `403` Authenticated but not authorized for this resource/role `404` Resource not found (or belongs to another tenant → treated as not found, not 403, to avoid leaking existence) - `422` Business rule violation (e.g., insufficient leave balance) `429` Rate limit exceeded `500` Internal server error 

## 8. Rate Limiting 

Endpoint group Limit `/chat/ask` 20 requests / minute / user `/documents/generate` 10 requests / minute / user All other endpoints 100 requests / minute / user 

- Rate limited responses return `429` with a `Retry-After` header (seconds). 

## 9. Tenant Isolation Rule (applies to every endpoint above) 

- ' - 

- 1. `company_id` is never accepted from the client it s extracted server side from the JWT. 

2. Every database query filters by `company_id` in addition to any other `WHERE` clause. 

3. Requesting a resource ( `employee_id` , `doc_id` , `request_id` , etc.) that exists but belongs to a different company returns `404` , not `403` — this prevents leaking the existence of other companies' data. 

4. The RAG vector index used by `/chat/ask` is partitioned per `company_id` , so retrieval can never cross tenant boundaries. 

