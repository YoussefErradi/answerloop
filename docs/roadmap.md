# AnswerLoop delivery plan

## Completed in Phase 0/1

- Rails 8.1 foundation with Hotwire, Stimulus, Tailwind, PostgreSQL
- Responsive staff dashboard and sign-in/register flows
- Workspace creation and role-based membership policy
- Team listing for authorized administrators
- One-time invitation workflow with invitation email
- Initial migrations, optional local seed, RSpec coverage
- Docker and CI workflow

The Docker build, PostgreSQL migrations, and Rails tests have been run locally. `Gemfile.lock` is included.

## Phase 2: Knowledge base — implemented

- Categories, articles, ownership, draft and publish states
- Action Text editor, preview, media uploads
- Pundit article permissions and workspace isolation
- Search index preparation

## Phase 3: Public portal and PostgreSQL search — implemented

- Public read-only article pages
- Full-text search with GIN and ranking
- Search event tracking and zero-result metrics

## Phase 4: Support tickets — implemented

- Contacts, tickets, messages, notes, assignment
- Email-based customer ticket authentication
- Notification jobs and audit events

## Phase 5: Analytics + polish — implemented

- Staff dashboard metrics and filters
- Responsive/accessibility review, request and model tests
- Query/index performance review

## Phase 6: Deploy

- Staging, security hardening, production email, durable jobs
- Private attachment storage, monitoring, backups
- Public demo and maintainer documentation
