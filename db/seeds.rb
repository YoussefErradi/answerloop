# Optional local-only demo. Never use these credentials in a deployed application.
if ENV["SEED_DEMO"] == "1"
  abort "Demo seed prohibited in production" if Rails.env.production?
  user = User.find_or_create_by!(email_address: "demo@answerloop.local") do |u|
    u.password = ENV.fetch("DEMO_PASSWORD", "ChangeMe12345!")
    u.password_confirmation = u.password
  end
  workspace = Workspace.find_or_create_by!(slug: "demo-workspace") do |w|
    w.name = "Demo Workspace"
  end
  Membership.find_or_create_by!(user: user, workspace: workspace) { |m| m.role = :owner }
  category = workspace.categories.find_or_create_by!(slug: "getting-started") { |c| c.name = "Getting started" }
  workspace.articles.find_or_create_by!(slug: "welcome-to-answerloop") do |article|
    article.category = category
    article.author = user
    article.title = "Welcome to the help center"
    article.summary = "Learn where to find answers and how to contact support."
    article.body = "Browse categories, search for a topic, or send a support request. Our team will reply by email."
    article.status = :published
  end
  puts "Demo: demo@answerloop.local / #{ENV.fetch('DEMO_PASSWORD', 'ChangeMe12345!')}"
end
