class PagesController < ApplicationController

  layout 'bare', only: [:unauthorized, :error]

  before_filter :find_applications, except: [:error, :unauthorized]  
  before_filter :find_adapters, except: [:error, :unauthorized]

  def home
    exports.app = current_app.as_json
    exports.databases = @adapters.as_json
  end

  def unauthorized    
  end

  def error
  end
end