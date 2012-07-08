module Labrador
  class MongoDB
    extend Configuration
    include Store
    
    attr_accessor :host, :port, :user, :database, :session

    DEFAULT_PORT = 27017

    def initialize(params = {})      
      @host     = params[:host]
      @port     = params[:port] || DEFAULT_PORT
      @database = params[:database]
      @user     = params[:user]
      password  = params[:password]
      
      @session = Mongo::Connection.new(@host, @port).db(@database)
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
  end
end

module BSON
  class ObjectId
    def as_json(options = nil)
      to_s
    end
  end
end
