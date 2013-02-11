class DataController < ApplicationController

  before_filter :find_applications  
  before_filter :find_adapters
  around_filter :catch_errors, only: [:index, :create, :update, :destroy]

  def index    
    items = current_adapter.database.find(params[:collection], parse_options)
    render json: {
      primary_key: current_adapter.database.primary_key_for(params[:collection]),
      collection: params[:collection],
      fields: current_adapter.database.fields_for(items),
      items: items
    }
  end

  def schema
    items = current_adapter.database.schema(params[:collection])
    render json: {
      collection: params[:collection],
      fields: current_adapter.database.fields_for(items),
      items: items
    }
  end

  def create
    current_adapter.database.create(params[:collection], params[:data])
    render json: { success: true }
  end

  def update
    current_adapter.database.update(params[:collection], params[:id], params[:data].to_hash)
    render json: { success: true }
  end

  def destroy
    current_adapter.database.delete(params[:collection], params[:id])
    render json: { success: true }
  end

  def collections
    render json: current_adapter.databse.collections
  end 
end