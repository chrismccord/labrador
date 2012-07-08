class PagesController < ApplicationController

  before_filter :find_applications  
  before_filter :find_adapters

  def home
    exports.app = current_app.as_json
    exports.databases = @adapters.as_json
  end
end