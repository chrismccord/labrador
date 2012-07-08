module Labrador
  class Postgres
    extend Configuration
    include RelationalStore

    attr_accessor :host, :port, :database, :session

    DEFAULT_PORT = 5432

    def initialize(params = {})      
      @host     = params[:host]
      @port     = params[:port] || DEFAULT_PORT
      @database = params[:database]
      @user     = params[:user]
      password  = params[:password]
     
      @session = PG::Connection.open(
        host: @host, 
        port: @port, 
        dbname: @database,  
        user: @user,
        password: password
      )
    end

    def collections
      session.exec("
        SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';
      ").collect{|row| row["table_name"] }.sort
    end

    def find(collection_name, options = {})
      order_by     = options[:order_by] || primary_key_for(collection_name)
      limit        = (options[:limit] || Postgres.default_limit).to_i
      skip         = (options[:skip] || 0).to_i
      direction    = options[:direction] || 'ASC'
      where_clause = options[:conditions]

      session.exec("
        SELECT * FROM #{collection_name}
        #{"WHERE #{where_clause}" if where_clause}
        #{"ORDER BY #{order_by} #{direction}" if order_by}
        LIMIT #{limit}
        OFFSET #{skip}
      ").as_json
    end

    def primary_key_for(collection_name)
      result = session.exec("
        SELECT               
          pg_attribute.attname, 
          format_type(pg_attribute.atttypid, pg_attribute.atttypmod) 
        FROM pg_index, pg_class, pg_attribute 
        WHERE 
          pg_class.oid = '#{collection_name}'::regclass AND
          indrelid = pg_class.oid AND
          pg_attribute.attrelid = pg_class.oid AND 
          pg_attribute.attnum = any(pg_index.indkey)
          AND indisprimary
      ").first
      result && result["attname"]
    end   
  end
end