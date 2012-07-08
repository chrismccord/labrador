Labrador::Application.routes.draw do

  root to: 'pages#home'
  get 'results', to: 'pages#results'
  
  namespace :data do
    ['auto', 'mongodb', 'postgres', 'mysql', 'sqlite'].each do |adapter|
      resources adapter, controller: 'data', adapter: adapter do
        collection do
          get :collections, action: 'collections'
        end
      end
    end 
  end
end
