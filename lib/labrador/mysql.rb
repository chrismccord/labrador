module Labrador
  class Mysql
    extend Configuration
    include RelationalStore
    include ViewHelper
    
    attr_accessor :host, :port, :database, :socket, :session

    DEFAULT_PORT = 3306

    def initialize(params = {})      
      @host     = params[:host]
      @port     = params[:port] || DEFAULT_PORT
      @database = params[:database]
      @user     = params[:user]
      password  = params[:password]
      @socket   = params[:socket]

      @session  = Mysql2::Client.new(
        host: @host, 
        port: @port, 
        database: @database,  
        username: @user,
        password: password,
        socket: @socket
      )
    end

    def collections
      session.query("SHOW TABLES").collect{|row| row.reduce.last }.sort
    end

    def find(collection_name, options = {})
      order_by     = options[:order_by] || primary_key_for(collection_name)
      limit        = (options[:limit] || Mysql.default_limit).to_i
      skip         = (options[:skip] || 0).to_i
      direction    = options[:direction] || 'ASC'
      where_clause = options[:conditions]

      session.query("
        SELECT * FROM #{collection_name}
        #{"WHERE #{where_clause}" if where_clause}
        #{"ORDER BY #{order_by} #{direction}" if order_by}
        LIMIT #{limit}
        OFFSET #{skip}
      ").as_json
    end

    def primary_key_for(collection_name)
      result = session.query("SHOW INDEX FROM #{collection_name}").first
      result && result["Column_name"]
    end

    def id
      "mysql"
    end

    def name
      I18n.t('adapters.mysql.title')
    end

    def as_json(options = nil)
      {
        id: self.id,
        name: self.name
      }
    end
  end
end