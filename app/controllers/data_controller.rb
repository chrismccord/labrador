class DataController < ApplicationController

  before_filter :find_applications  
  before_filter :find_adapters

  def index    
    items = current_adapter.database.find(params[:collection], parse_options)
    render json: {
      fields: current_adapter.database.fields_for(items),
      items: items
    }
  end

  def collections
    render json: current_adapter.databse.collections
  end
end