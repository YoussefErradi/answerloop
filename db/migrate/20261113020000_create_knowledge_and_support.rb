class CreateKnowledgeAndSupport < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.references :workspace, null: false, foreign_key: true
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :categories, %i[workspace_id slug], unique: true

    create_table :articles do |t|
      t.references :workspace, null: false, foreign_key: true
      t.references :category, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.string :slug, null: false
      t.text :summary
      t.text :search_body, null: false, default: ""
      t.integer :status, null: false, default: 0
      t.datetime :published_at
      t.timestamps
    end
    add_index :articles, %i[workspace_id slug], unique: true
    add_index :articles, %i[workspace_id status published_at]
    add_index :articles, "to_tsvector('english', coalesce(title, '') || ' ' || coalesce(search_body, ''))", using: :gin, name: "index_articles_on_full_text"
    add_check_constraint :articles, "status IN (0, 1)", name: "valid_article_status"

    create_table :search_events do |t|
      t.references :workspace, null: false, foreign_key: true
      t.string :query, null: false
      t.integer :result_count, null: false, default: 0
      t.timestamps
    end
    add_index :search_events, %i[workspace_id created_at]

    create_table :customer_contacts do |t|
      t.references :workspace, null: false, foreign_key: true
      t.string :email, null: false
      t.string :name, null: false
      t.timestamps
    end
    add_index :customer_contacts, %i[workspace_id email], unique: true

    create_table :tickets do |t|
      t.references :workspace, null: false, foreign_key: true
      t.references :customer_contact, null: false, foreign_key: true
      t.references :assignee, foreign_key: { to_table: :users }
      t.string :subject, null: false
      t.integer :status, null: false, default: 0
      t.integer :priority, null: false, default: 1
      t.datetime :resolved_at
      t.timestamps
    end
    add_index :tickets, %i[workspace_id status created_at]
    add_check_constraint :tickets, "status IN (0, 1, 2)", name: "valid_ticket_status"
    add_check_constraint :tickets, "priority IN (0, 1, 2)", name: "valid_ticket_priority"

    create_table :ticket_messages do |t|
      t.references :ticket, null: false, foreign_key: true
      t.references :author, foreign_key: { to_table: :users }
      t.integer :kind, null: false, default: 0
      t.text :body, null: false
      t.timestamps
    end
    add_index :ticket_messages, %i[ticket_id created_at]
    add_check_constraint :ticket_messages, "kind IN (0, 1)", name: "valid_ticket_message_kind"

    create_table :ticket_access_links do |t|
      t.references :ticket, null: false, foreign_key: true
      t.string :token_digest, null: false
      t.datetime :expires_at, null: false
      t.datetime :used_at
      t.timestamps
    end
    add_index :ticket_access_links, :token_digest, unique: true

    create_table :audit_events do |t|
      t.references :workspace, null: false, foreign_key: true
      t.references :actor, foreign_key: { to_table: :users }
      t.references :ticket, foreign_key: true
      t.string :action, null: false
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
    end
    add_index :audit_events, %i[workspace_id created_at]
  end
end
