module Labrador
  class MongoDB
    extend Configuration
    include Store
    include ViewHelper
    
    attr_accessor :host, :port, :user, :database, :session, :connection

    DEFAULT_PORT = 27017

    def initialize(params = {})      
      @host     = params[:host]
      @port     = params[:port] || DEFAULT_PORT
      @database = params[:database]
      @user     = params[:user]
      password  = params[:password]
      
      @connection = Mongo::Connection.new(@host, @port)
      @session = connection.db(@database)
      @session.authenticate(@user, password) if @user && password
      collections
    end

    def collections
      session.collection_names.sort
    end

    def find(collection_name, options = {})
      order_by   = options[:order_by] || "_id"
      limit      = (options[:limit] || MongoDB.default_limit).to_i
      skip       = (options[:skip] || 0).to_i
      direction  = options[:direction] == "desc" ? -1 : 1
      conditions = options[:conditions] || {}

      session[collection_name].find(conditions)
        .limit(limit)
        .skip(skip)
        .sort("#{order_by}" => direction)
        .as_json
    end

    def create(collection_name, data = {})
      session[collection_name].insert(data, safe: true)
    end

    def update(collection_name, id, data = {})
      session[collection_name].update({_id: BSON::ObjectId(id)}, {:"$set" => data}, {safe: true})
    end

    def delete(collection_name, id)
      session[collection_name].remove({_id: BSON::ObjectId(id)}, {safe: true})
    end

    def primary_key_for(collection_name)
      "_id"
    end

    def connected?
      connection.connected?
    end

    def close
      connection.close
    end

    def id
      "mongodb"
    end

    def name
      I18n.t('adapters.mongodb.title')
    end

    def schema
      []
    end

    def as_json(options = nil)
      {
        id: self.id,
        name: self.name
      }
    end
  end
end

module BSON
  class ObjectId
    def as_json(options = nil)
      to_s
    end
  end
end
