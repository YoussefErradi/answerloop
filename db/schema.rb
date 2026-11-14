# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_13_020000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "articles", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.bigint "category_id"
    t.bigint "author_id", null: false
    t.string "title", null: false
    t.string "slug", null: false
    t.text "summary"
    t.text "search_body", default: "", null: false
    t.integer "status", default: 0, null: false
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "to_tsvector('english'::regconfig, (((COALESCE(title, ''::character varying))::text || ' '::text) || COALESCE(search_body, ''::text)))", name: "index_articles_on_full_text", using: :gin
    t.index ["author_id"], name: "index_articles_on_author_id"
    t.index ["category_id"], name: "index_articles_on_category_id"
    t.index ["workspace_id", "slug"], name: "index_articles_on_workspace_id_and_slug", unique: true
    t.index ["workspace_id", "status", "published_at"], name: "index_articles_on_workspace_id_and_status_and_published_at"
    t.index ["workspace_id"], name: "index_articles_on_workspace_id"
    t.check_constraint "status = ANY (ARRAY[0, 1])", name: "valid_article_status"
  end

  create_table "audit_events", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.bigint "actor_id"
    t.bigint "ticket_id"
    t.string "action", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_audit_events_on_actor_id"
    t.index ["ticket_id"], name: "index_audit_events_on_ticket_id"
    t.index ["workspace_id", "created_at"], name: "index_audit_events_on_workspace_id_and_created_at"
    t.index ["workspace_id"], name: "index_audit_events_on_workspace_id"
  end

  create_table "categories", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workspace_id", "slug"], name: "index_categories_on_workspace_id_and_slug", unique: true
    t.index ["workspace_id"], name: "index_categories_on_workspace_id"
  end

  create_table "customer_contacts", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workspace_id", "email"], name: "index_customer_contacts_on_workspace_id_and_email", unique: true
    t.index ["workspace_id"], name: "index_customer_contacts_on_workspace_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.bigint "user_id", null: false
    t.integer "role", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_memberships_on_user_id"
    t.index ["workspace_id", "user_id"], name: "index_memberships_on_workspace_id_and_user_id", unique: true
    t.index ["workspace_id"], name: "index_memberships_on_workspace_id"
    t.check_constraint "role = ANY (ARRAY[0, 1, 2, 3])", name: "valid_membership_role"
  end

  create_table "search_events", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.string "query", null: false
    t.integer "result_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workspace_id", "created_at"], name: "index_search_events_on_workspace_id_and_created_at"
    t.index ["workspace_id"], name: "index_search_events_on_workspace_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "ticket_access_links", force: :cascade do |t|
    t.bigint "ticket_id", null: false
    t.string "token_digest", null: false
    t.datetime "expires_at", null: false
    t.datetime "used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ticket_id"], name: "index_ticket_access_links_on_ticket_id"
    t.index ["token_digest"], name: "index_ticket_access_links_on_token_digest", unique: true
  end

  create_table "ticket_messages", force: :cascade do |t|
    t.bigint "ticket_id", null: false
    t.bigint "author_id"
    t.integer "kind", default: 0, null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_ticket_messages_on_author_id"
    t.index ["ticket_id", "created_at"], name: "index_ticket_messages_on_ticket_id_and_created_at"
    t.index ["ticket_id"], name: "index_ticket_messages_on_ticket_id"
    t.check_constraint "kind = ANY (ARRAY[0, 1])", name: "valid_ticket_message_kind"
  end

  create_table "tickets", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.bigint "customer_contact_id", null: false
    t.bigint "assignee_id"
    t.string "subject", null: false
    t.integer "status", default: 0, null: false
    t.integer "priority", default: 1, null: false
    t.datetime "resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_tickets_on_assignee_id"
    t.index ["customer_contact_id"], name: "index_tickets_on_customer_contact_id"
    t.index ["workspace_id", "status", "created_at"], name: "index_tickets_on_workspace_id_and_status_and_created_at"
    t.index ["workspace_id"], name: "index_tickets_on_workspace_id"
    t.check_constraint "priority = ANY (ARRAY[0, 1, 2])", name: "valid_ticket_priority"
    t.check_constraint "status = ANY (ARRAY[0, 1, 2])", name: "valid_ticket_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((email_address)::text)", name: "index_users_on_lower_email_address", unique: true
  end

  create_table "workspace_invitations", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.bigint "invited_by_user_id", null: false
    t.string "email", null: false
    t.integer "role", null: false
    t.string "token_digest", null: false
    t.datetime "expires_at", null: false
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invited_by_user_id"], name: "index_workspace_invitations_on_invited_by_user_id"
    t.index ["token_digest"], name: "index_workspace_invitations_on_token_digest", unique: true
    t.index ["workspace_id", "email"], name: "index_workspace_invitations_on_workspace_id_and_email"
    t.index ["workspace_id"], name: "index_workspace_invitations_on_workspace_id"
    t.check_constraint "role = ANY (ARRAY[1, 2, 3])", name: "valid_invitation_role"
  end

  create_table "workspaces", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.jsonb "settings", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_workspaces_on_slug", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "articles", "categories"
  add_foreign_key "articles", "users", column: "author_id"
  add_foreign_key "articles", "workspaces"
  add_foreign_key "audit_events", "tickets"
  add_foreign_key "audit_events", "users", column: "actor_id"
  add_foreign_key "audit_events", "workspaces"
  add_foreign_key "categories", "workspaces"
  add_foreign_key "customer_contacts", "workspaces"
  add_foreign_key "memberships", "users"
  add_foreign_key "memberships", "workspaces"
  add_foreign_key "search_events", "workspaces"
  add_foreign_key "sessions", "users"
  add_foreign_key "ticket_access_links", "tickets"
  add_foreign_key "ticket_messages", "tickets"
  add_foreign_key "ticket_messages", "users", column: "author_id"
  add_foreign_key "tickets", "customer_contacts"
  add_foreign_key "tickets", "users", column: "assignee_id"
  add_foreign_key "tickets", "workspaces"
  add_foreign_key "workspace_invitations", "users", column: "invited_by_user_id"
  add_foreign_key "workspace_invitations", "workspaces"
end
