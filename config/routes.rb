Rails.application.routes.draw do
  root "dashboard#index"
  resource :contact, only: :create
  resource :session, only: %i[new create destroy]
  resource :registration, only: %i[new create]
  resources :workspaces, only: %i[index new create show] do
    resources :memberships, only: %i[index]
    resources :invitations, only: %i[new create]
    resources :categories, only: %i[index create destroy]
    resources :articles, only: %i[index new create show edit update destroy] do
      member { get :preview }
    end
    resources :customer_contacts, only: %i[index show update]
    resources :tickets, only: %i[index new create show update] do
      resources :ticket_messages, only: :create
    end
    resource :analytics, only: :show
  end
  get "help/:workspace_slug", to: "help#index", as: :help
  get "help/:workspace_slug/search", to: "help#search", as: :help_search
  get "help/:workspace_slug/articles/:slug", to: "help#article", as: :help_article
  resources :public_tickets, only: %i[new create show], path: "help/:workspace_slug/tickets", as: :help_tickets
  post "help/:workspace_slug/tickets/:id/access", to: "public_tickets#request_access", as: :request_help_ticket_access
  post "help/:workspace_slug/tickets/:id/replies", to: "public_tickets#reply", as: :help_ticket_replies
  get "help/ticket-access/:token", to: "public_tickets#exchange", as: :exchange_help_ticket_access
  get "accept-invitation/:token", to: "invitation_acceptances#show", as: :accept_invitation
  post "accept-invitation/:token", to: "invitation_acceptances#create"
  namespace :api do
    namespace :v1 do
      resource :me, only: :show, controller: "me"
      resources :workspaces, only: %i[index show create], param: :slug do
        resources :memberships, only: :index
      end
    end
  end
  get "up", to: "rails/health#show", as: :rails_health_check
end
