module SampleData
  def create_user(email: "dev@example.test", password: "a-long-test-password")
    User.create!(email_address: email, password: password, password_confirmation: password)
  end

  def create_workspace_for(user, name: "Alpha Workspace", role: :owner)
    workspace = Workspace.create!(name: name)
    Membership.create!(workspace: workspace, user: user, role: role)
    workspace
  end

  def sign_in(user, password: "a-long-test-password")
    post session_path, params: { email_address: user.email_address, password: password }
    expect(response).to redirect_to(root_path)
  end
end
