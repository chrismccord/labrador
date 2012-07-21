module Labrador
  class Sqlite
    extend Configuration
    include RelationalStore
    include ViewHelper

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

    def create(collection_name, data = {})
      primary_key_name = primary_key_for(collection_name)
      values = data.collect{|key, val| val }
      fields = data.collect{|key, val| key.to_s }.join(", ")
      prepared_values = (["?"]* data.keys.length).join(", ")      
      query = session.prepare("
        INSERT INTO #{collection_name}
        (#{ fields })
        VALUES (#{ prepared_values })
      ")
      query.execute(values)
    end

    def update(collection_name, id, data = {})
      primary_key_name = primary_key_for(collection_name)
      prepared_key_values = data.collect{|key, val| "#{key}=?" }.join(",")
      values = data.values
      values << id
      query = session.prepare("
        UPDATE #{collection_name}
        SET #{ prepared_key_values }
        WHERE #{primary_key_name}= ?
      ")
      query.execute(values)
    end

    def delete(collection_name, id)
      primary_key_name = primary_key_for(collection_name)
      query = session.prepare("DELETE FROM #{collection_name} WHERE #{primary_key_name}=?")
      query.execute(id)
    end

    def schema(collection_name)
      session.execute("PRAGMA table_info(#{collection_name})").as_json
    end

    def primary_key_for(collection_name)
      result = session.table_info(collection_name).select{|field| field["pk"] == 1 }.first
      result && result["name"]
    end

    def id
      "sqlite"
    end

    def name
      I18n.t('adapters.sqlite.title')
    end

    def as_json(options = nil)
      {
        id: self.id,
        name: self.name
      }
    end
  end
end