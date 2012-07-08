class DataController < ApplicationController

  before_filter :find_applications  
  before_filter :find_adapters

  def index    
    items = current_adapter.find(params[:collection], parse_options)
    render json: {
      fields: current_adapter.fields_for(items),
      items: items
    }
  end

  def collections
    render json: current_adapter.collections
  end
end