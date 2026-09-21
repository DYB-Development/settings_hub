SettingsHub::Engine.routes.draw do
  get "/", to: "settings#show", as: :settings
  namespace :api do
    resources :sections, only: :index
    patch "sections/:key/:action_name", to: "sections#update"
  end

  get "/:key", to: "sections#show", as: :section
  patch "/:key", to: "sections#update"
  patch "/:key/:action_name", to: "sections#update", as: :section_action
end
