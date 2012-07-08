class DataController < ApplicationController

  before_filter :find_adapter

  def index    
    items = @adapter.find(params[:collection], parse_options)
    render json: {
      fields: @adapter.fields_for(items),
      items: items
    }
  end

  def collections
    render json: @adapter.collections
  end
end