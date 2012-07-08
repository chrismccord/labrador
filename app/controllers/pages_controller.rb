class PagesController < ApplicationController

  layout 'bare', only: [:results]
  
  before_filter :find_adapter
  before_filter :find_applications

  def home
    @collections = @adapter.collections
    exports.database = @adapter.as_json
  end

  def results
  end
end