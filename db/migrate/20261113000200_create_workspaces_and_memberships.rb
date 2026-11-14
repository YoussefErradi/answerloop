class CreateWorkspacesAndMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :workspaces do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.jsonb :settings, null: false, default: {}
      t.timestamps
    end
    add_index :workspaces, :slug, unique: true

    create_table :memberships do |t|
      t.references :workspace, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :role, null: false
      t.timestamps
    end
    add_index :memberships, %i[workspace_id user_id], unique: true
    add_check_constraint :memberships, "role IN (0, 1, 2, 3)", name: "valid_membership_role"
  end
end
