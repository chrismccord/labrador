class DataController < ApplicationController

  before_filter :find_applications  
  before_filter :find_adapters
  around_filter :catch_errors, only: [:index, :create, :update, :destroy]

  def index    
    items = current_adapter.database.find(collection, finder_params)
    render json: {
      primary_key: current_adapter.database.primary_key_for(collection),
      collection: collection,
      fields: current_adapter.database.fields_for(items),
      items: items
    }
  end

  def schema
    items = current_adapter.database.schema(collection)
    render json: {
      collection: collection,
      fields: current_adapter.database.fields_for(items),
      items: items
    }
  end

  def create
    current_adapter.database.create(collection, data)
    render json: { success: true }
  end

  def update
    current_adapter.database.update(collection, params[:id], data)
    render json: { success: true }
  end

  def destroy
    current_adapter.database.delete(collection, params[:id])
    render json: { success: true }
  end

  def collections
    render json: current_adapter.databse.collections
  end

  
  private

  def finder_params
    params.slice :limit, :order_by, :direction, :conditions, :skip
  end

  def collection
    params[:collection]
  end

  def data
    params[:data].to_hash
  end
end