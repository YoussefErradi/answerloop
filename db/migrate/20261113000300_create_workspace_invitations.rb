class CreateWorkspaceInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :workspace_invitations do |t|
      t.references :workspace, null: false, foreign_key: true
      t.references :invited_by_user, null: false, foreign_key: { to_table: :users }
      t.string :email, null: false
      t.integer :role, null: false
      t.string :token_digest, null: false
      t.datetime :expires_at, null: false
      t.datetime :accepted_at
      t.timestamps
    end
    add_index :workspace_invitations, :token_digest, unique: true
    add_index :workspace_invitations, %i[workspace_id email]
    add_check_constraint :workspace_invitations, "role IN (1, 2, 3)", name: "valid_invitation_role"
  end
end
