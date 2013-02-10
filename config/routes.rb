Labrador::Application.routes.draw do

  root to: 'pages#home'

  get '401', to: 'pages#unauthorized', as: 'unauthorized'
  get 'error', to: 'pages#error', as: 'error'
  
  scope "data" do
    Labrador::Constants::ADAPTER_KEYS.each do |adapter|
      resources adapter, controller: 'data', adapter: adapter do
        collection do
          get :collections, action: 'collections'
          get :schema, action: 'schema'
        end
      end
    end 
  end

  resources :sessions
  get '/*path', to: 'pages#home'
end
