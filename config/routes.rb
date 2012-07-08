Labrador::Application.routes.draw do

  root to: 'pages#home'
  
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
