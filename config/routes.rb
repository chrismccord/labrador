Labrador::Application.routes.draw do

  root to: 'pages#home'

  get '401', to: 'pages#unauthorized', as: 'unauthorized'

  namespace :data do
    ['mongodb', 'postgres', 'mysql', 'sqlite'].each do |adapter|
      resources adapter, controller: 'data', adapter: adapter do
        collection do
          get :collections, action: 'collections'
        end
      end
    end 
  end

  get '/*path', to: 'pages#home'
end
