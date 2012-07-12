Labrador::Application.routes.draw do

  root to: 'pages#home'

  get '401', to: 'pages#unauthorized', as: 'unauthorized'
  get 'error', to: 'pages#error', as: 'error'
  
  namespace :data do
    ['mongodb', 'postgresql', 'mysql', 'mysql2', 'sqlite', 'sqlite2', 'sqlite3'].each do |adapter|
      resources adapter, controller: 'data', adapter: adapter do
        collection do
          get :collections, action: 'collections'
        end
      end
    end 
  end

  get '/*path', to: 'pages#home'
end
