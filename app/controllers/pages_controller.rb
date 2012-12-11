class PagesController < ApplicationController

  layout 'bare', only: [:unauthorized, :error]

  before_filter :find_applications, except: [:error, :unauthorized]  
  before_filter :find_adapters, except: [:error, :unauthorized]

  def home
    exports.app = current_app.as_json
    exports.databases = @adapters.collect(&:database).as_json      
    redirect_to new_session_url(subdomain: false) unless current_app
  end

  def unauthorized    
  end

  def error
  end
end