# Architecture decision notes

## 001: Rails 8.1 modular monolith

All HTTP endpoints, business models, and views live in one Rails application. This minimizes operational complexity and makes debugging and tests straightforward. The workspace data boundary is enforced with scoped queries, authorization policies, and database constraints. Knowledge, Search, Support, and Analytics are implemented in the monolith.

## 002: Hotwire before a separate SPA

Rails renders HTML, Turbo handles navigation, and Stimulus handles browser-side interactions. This demonstrates server/client engineering without adding duplicated frontend state management and a second deployable app. JavaScript lives in `app/javascript/controllers/`.

## 003: Authentication and authorization

`has_secure_password` hashes passwords with bcrypt. Session IDs use signed HttpOnly cookies, SameSite Lax, and the Secure flag over HTTPS. Session records are stored server-side. Pundit decides role capabilities; every workspace record is loaded from the authenticated user's memberships. All privileged actions are authorized server-side.

## 004: Invitation acceptance

An owner/admin invites by email; the invitation contains a one-time random bearer token. The database stores only SHA-256(token), not the raw token. Recipients must authenticate using the exact invited email address. Invitation acceptance occurs inside `with_lock` to stop double redemption and creates membership only once.

## 005: PostgreSQL schema

Workspace slugs are globally unique and include a random suffix. Memberships have a unique `(workspace_id, user_id)` index. Email uniqueness is enforced by a functional index on `lower(email_address)`. Role enums have database `CHECK` constraints to prevent invalid values. Tokens have unique digests.

## 006: Knowledge and customer support

Articles and categories belong to workspaces. Published articles alone appear in the public portal and PostgreSQL full-text search. A GIN index supports title and article-body search; search events record result counts for analytics. Tickets belong to a workspace and customer contact; staff can add replies or private notes. Customer access uses emailed, one-time, SHA-256-digested links exchanged for an encrypted HttpOnly cookie scoped to one ticket. Changing a contact email revokes outstanding links and invalidates existing ticket cookies.

## Security checklist before production

- [ ] Verify email ownership before enabling invitations and sensitive support features
- [ ] Implement password reset, throttling, and login abuse controls
- [ ] Use durable background jobs for invitation mail
- [ ] Add audit records for membership changes and role assignments (ticket and contact events are recorded)
- [ ] Configure secure SMTP, allowed hosts, CSP, HSTS, and deployment secrets
- [ ] Set up monitoring, backups and restore exercises
- [ ] Run external dependency audit and production security testing
