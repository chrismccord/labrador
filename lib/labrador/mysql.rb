require 'mysql'

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

      @session  = ::Mysql.connect(@host, @user, password, @database, @port, @socket)
    end

    def collections
      names = []
      session.query("SHOW TABLES").each{|row| names << row.first }

      names
    end

    # Parse msyql-ruby Mysql::Result into array of key value records. 
    def parse_results(results)
      results.collect do |row|
        record = {}
        row.each_with_index{|val, i| record[results.fields[i].name] = val }
        
        record
      end
    end

    def find(collection_name, options = {})
      order_by     = options[:order_by] || primary_key_for(collection_name)
      limit        = (options[:limit] || Mysql.default_limit).to_i
      skip         = (options[:skip] || 0).to_i
      direction    = options[:direction] || 'ASC'
      where_clause = options[:conditions]

      results = []
      session.query("
        SELECT * FROM #{collection_name}
        #{"WHERE #{where_clause}" if where_clause}
        #{"ORDER BY #{order_by} #{direction}" if order_by}
        LIMIT #{limit}
        OFFSET #{skip}
      ").each_hash{|row| results << row }

      results
    end

    def create(collection_name, data = {})
      primary_key_name = primary_key_for(collection_name)
      values = data.collect{|key, val| "'#{session.escape_string(val.to_s)}'" }.join(", ")
      fields = data.collect{|key, val| key.to_s }.join(", ")
      session.query("
        INSERT INTO #{collection_name}
        (#{ fields })
        VALUES (#{ values })
      ")
    end

    def update(collection_name, id, data = {})
      primary_key_name = primary_key_for(collection_name)
      prepared_key_values = data.collect{|key, val| "#{key}=?" }.join(",")
      values = data.values
      values << id
      query = session.prepare("
        UPDATE #{collection_name}
        SET #{ prepared_key_values }
        WHERE #{primary_key_name}=?
      ")
      query.execute(*values)
    end

    def delete(collection_name, id)
      primary_key_name = primary_key_for(collection_name)
      query = session.prepare("DELETE FROM #{collection_name} WHERE #{primary_key_name}=?")
      query.execute(id)
    end

    def schema(collection_name)
      parse_results(session.query("DESCRIBE #{collection_name}"))
    end

    def primary_key_for(collection_name)
      result = session.query("SHOW INDEX FROM #{collection_name}").fetch_hash
      result && result["Column_name"]
    end

    def connected?
      session.ping rescue false
    end

    def close
      session.close
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