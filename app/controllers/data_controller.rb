class DataController < ApplicationController

  before_filter :find_applications  
  around_filter :catch_errors, only: [:index, :create, :update, :destroy]

  def index    
    items = database.find(collection, finder_params)
    render json: {
      primary_key: database.primary_key_for(collection),
      collection: collection,
      fields: database.fields_for(items),
      items: items
    }
  end

  def schema
    items = database.schema(collection)
    render json: {
      collection: collection,
      fields: database.fields_for(items),
      items: items
    }
  end

  def create
    database.create(collection, data)
    render json: { success: true }
  end

  def update
    database.update(collection, params[:id], data)
    render json: { success: true }
  end

  def destroy
    database.delete(collection, params[:id])
    render json: { success: true }
  end

  def collections
    render json: database.collections
  end

  
  private

  def database
    current_adapter.database
  end

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