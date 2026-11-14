# AnswerLoop

A knowledge-base and customer-support app built with **Ruby on Rails 8.1**, **JavaScript**, **Hotwire (Turbo + Stimulus)**, **Tailwind CSS**, and **PostgreSQL**. It includes workspaces, team invitations, rich articles, a public help center with search, support tickets, and analytics.

> **Status:** Local development demo. The Rails tests and Brakeman scan run in Docker. Production deployment, durable jobs, external email delivery, and backups remain in Phase 6.

## Requirements

- Ruby 3.3.13 and Bundler for local execution; Docker includes the matching Ruby version
- PostgreSQL 16+, or Docker with Docker Compose
- Internet access for the first `bundle install` and Tailwind binary install

## Quick start with Docker

```bash
docker compose up --build
```

Open <http://localhost:3000>. This starts PostgreSQL and Rails, runs migrations, builds Tailwind CSS, and serves the application. Ports are bound to localhost. Emails are written to `tmp/mail/` (not sent externally). PostgreSQL data and uploaded article files use Docker named volumes. If Docker Desktop's disk image is on an external SSD, these volumes stay there.

Create demo data (optional):

```bash
docker compose exec -e SEED_DEMO=1 web bin/rails db:seed
```

Demo credentials: `demo@answerloop.local` / `ChangeMe12345!`. **Development only; never deploy this account or password.**

Stop services: `docker compose down`. To destroy local data as well: `docker compose down -v`.

## Run Rails locally and PostgreSQL in Docker

```bash
docker compose up -d db
bundle install
export DATABASE_URL=postgres://answerloop:local_dev_password@localhost:5433/answerloop_development
bin/rails db:prepare
bin/rails tailwindcss:build
bin/dev
```

Visit <http://localhost:3000>. `bin/dev` starts Rails and watches Tailwind changes.

## Authentication and membership flow

1. Visit `/registration/new` and create an account (12-character minimum password).
2. Create a workspace; the creator becomes its **owner** in one DB transaction.
3. Owners/admins can visit **Manage team** and invite an email address as `admin`, `editor`, or `agent`.
4. Development invitation emails appear in `tmp/mail/`. Copy the acceptance URL.
5. Create or sign in with exactly the invited email address and open that URL.
6. Accept once before the seven-day expiry. The token cannot be reused.
7. An unauthorized user cannot access another workspace by guessing its slug.

### Roles

| Role | Manage articles | Work tickets | View analytics | Manage team |
|---|---|---|---|---|
| Owner | Yes | Yes | Yes | Yes |
| Admin | Yes | Yes | Yes | Yes |
| Editor | Yes | No | No | No |
| Agent | No | Yes | No | No |
| Outsider | No | No | No | No |

Open a workspace to manage categories and articles. Publish an article to show it in `/help/WORKSPACE_SLUG`. Customers can search published articles or submit a ticket there. A ticket link is emailed to the customer and expires after 30 minutes; they can request a fresh link. Staff can create tickets, maintain customer contacts, reply, add private notes, and assign tickets. Owners and admins can view analytics for articles, tickets, and searches.

## Run tests

If PostgreSQL is already up, and `DATABASE_URL` targets the **test** database:

```bash
RAILS_ENV=test DATABASE_URL=postgres://answerloop:local_dev_password@localhost:5433/answerloop_test bin/rails db:prepare
RAILS_ENV=test DATABASE_URL=postgres://answerloop:local_dev_password@localhost:5433/answerloop_test bundle exec rspec
bundle exec brakeman -q
npm run test:js
```

Alternatively, with the Docker image already built:

```bash
docker compose run --rm -e RAILS_ENV=test -e DATABASE_URL=postgres://answerloop:local_dev_password@db:5432/answerloop_test web bundle exec rspec
```

CI is defined in `.github/workflows/ci.yml` and runs Postgres, migration preparation, RSpec, autoloading validation, Tailwind compilation, and Brakeman.

## Code layout

- `app/models/`: users, workspaces, articles, tickets, customer contacts, search and audit events
- `app/controllers/`: authentication, knowledge base, public portal, support, and analytics
- `app/policies/`: Pundit authorization
- `app/javascript/controllers/`: Stimulus features
- `db/migrate/`: PostgreSQL schema, constraints, and full-text search index
- `spec/`: model, policy, authentication, tenant isolation, invitation, article, and ticket tests
- `docs/architecture.md`: architecture and security decisions
- `docs/roadmap.md`: delivery phases and acceptance criteria
- `docs/api.md`: available versioned JSON endpoints

## Security boundaries

Workspace records are loaded through `current_user.workspaces`, not unrestricted `Workspace.find`. Pundit checks membership role before listing team members and sending invitations. Invitation tokens are random, stored as SHA-256 digests, expire after seven days, require the matching signed-in email, and are redeemed under a database row lock. Forms use Rails CSRF protection. Session IDs live in signed, HttpOnly cookies.

## Remaining production work

- Development mail is written to files. Configure and verify real SMTP before deployment.
- Add password reset, email verification, request throttling, and a durable job adapter before public production use.
- Configure private object storage, monitoring, backups, and a production security review.

## Home page customer story

The home page includes a 40-second motion graphic about Maya and Sunday Studio.
It is an illustrative workflow, with seven scenes covering help-center search,
support requests, assignment, private notes, customer replies, and insights.
The video uses native playback controls, optional English captions, and a text
transcript. It has no audio and does not autoplay or preload the video file.

`public/media/` contains the finished H.264 MP4, poster, and WebVTT captions.
`script/render_feature_video.py` draws all 1,200 frames and streams them to ffmpeg,
without saving a large sequence of temporary image files. To regenerate on macOS
with Python, Pillow, Avenir Next, and ffmpeg installed:

```bash
python3 script/render_feature_video.py --ffmpeg /path/to/ffmpeg
```

Use `--stills` for the seven keyframes and storyboard in `tmp/feature-video/`.
Set `ANSWERLOOP_VIDEO_FONT` to an equivalent font collection when rendering on
another operating system. Edit captions and the home-page transcript when
changing the story text.

## License

MIT. See `LICENSE`.
