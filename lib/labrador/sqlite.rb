module Labrador
  class Sqlite
    extend Configuration
    include RelationalStore

    attr_accessor :host, :port, :database, :socket, :session

    DEFAULT_PORT = 3306

    def initialize(params = {})      
      @database = params[:database]
      @session = SQLite3::Database.new(@database)
      @session.results_as_hash = true
    end

    def collections
      session.execute("SELECT name FROM sqlite_master WHERE type = 'table'")
        .collect{|r| r["name"] }
        .sort
    end

    def find(collection_name, options = {})
      order_by     = options[:order_by] || primary_key_for(collection_name)
      limit        = (options[:limit] || Sqlite.default_limit).to_i
      skip         = (options[:skip] || 0).to_i
      direction    = options[:direction] || 'ASC'
      where_clause = options[:conditions]

      session.execute("
        SELECT * FROM #{collection_name}
        #{"WHERE #{where_clause}" if where_clause}
        #{"ORDER BY #{order_by} #{direction}" if order_by}
        LIMIT #{limit}
        OFFSET #{skip}
      ").map{|record| record.delete_if{|key, val| key.is_a?(Integer) } }
    end

    def primary_key_for(collection_name)
      result = session.table_info(collection_name).select{|field| field["pk"] == 1 }.first
      result && result["name"]
    end
  end
end