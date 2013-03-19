class PagesController < ApplicationController

  layout 'bare', only: [:unauthorized, :error]

  before_filter :find_applications, except: [:error, :unauthorized]  

  def home
    exports.app = current_app.as_json
    exports.databases = current_app.adapters.collect(&:database).as_json      
    redirect_to new_session_url(subdomain: false) unless current_app.connected?
  end

  def unauthorized    
  end

  def error
  end
end