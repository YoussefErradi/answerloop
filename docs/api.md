# API v1 — Phase 1

The HTML application uses signed, HttpOnly Rails session cookies. The first JSON endpoints use the same authenticated session; no JWTs or public API tokens are issued.

| Method | Route | Authorization | Response |
|---|---|---|---|
| GET | `/api/v1/me` | Authenticated user | `{ "data": { "id", "email" } }` |
| GET | `/api/v1/workspaces` | Authenticated user | Only workspaces where the user is a member |
| POST | `/api/v1/workspaces` | Authenticated user | Creates workspace and owner membership in a transaction |
| GET | `/api/v1/workspaces/:slug` | Workspace member | Workspace details |
| GET | `/api/v1/workspaces/:workspace_slug/memberships` | Owner/admin | Team and roles |

## Errors

`401`: missing session (JSON `{ "error": { "code": "unauthenticated" } }`).

`403`: authenticated, insufficient permissions.

`404`: workspace outside user membership scope or nonexistent.

`422`: invalid input to create a workspace.

Authenticated mutations require Rails CSRF tokens. Do not add public bearer token auth without separate threat modeling.
