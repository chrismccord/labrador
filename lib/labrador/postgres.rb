require 'postgres-pr/connection'

module Labrador
  class Postgres
    extend Configuration
    include RelationalStore
    include ViewHelper
    
    attr_accessor :host, :port, :database, :session

    DEFAULT_PORT = 5432
    DEFAULT_HOST = 'localhost'
    
    def initialize(params = {})      
      @host     = params[:host] || DEFAULT_HOST
      @port     = params[:port] || DEFAULT_PORT
      @database = params[:database]
      @user     = params[:user] || `whoami`.strip
      password  = params[:password]
     
      @session = PostgresPR::Connection.new(
        @database,
        @user,
        password,
        "tcp://#{@host}:#{@port}"
      )
    end

    # Parse postegres-pr Result into array of key value records. Force utf-8 encoding
    def parse_results(results)
      results.rows.collect do |row|
        record = {}
        row.each_with_index{|val, i| 
          val = val.force_encoding('utf-8') if val
          record[results.fields[i].name] = val
        }
        
        record
      end
    end

    def collections
      session.query("
        SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';
      ").rows.flatten.sort
    end

    def find(collection_name, options = {})
      order_by     = options[:order_by] || primary_key_for(collection_name)
      limit        = (options[:limit] || Postgres.default_limit).to_i
      skip         = (options[:skip] || 0).to_i
      direction    = options[:direction] || 'ASC'
      where_clause = options[:conditions]

      parse_results(session.query("
        SELECT * FROM #{collection_name}
        #{"WHERE #{where_clause}" if where_clause}
        #{"ORDER BY #{order_by} #{direction}" if order_by}
        LIMIT #{limit}
        OFFSET #{skip}
      "))
    end

    # Escape string for SQL and force US-ASCII encoding as workaround
    # For postgres-pr unicode limitations
    # TODO: Handle propper encoding
    #
    def escape(str)
      str.to_s.gsub(/\\/, '\&\&').gsub(/'/, "''").force_encoding('US-ASCII')
    end

    def create(collection_name, data = {})
      primary_key_name = primary_key_for(collection_name)
      values = data.collect{|key, val| "'#{escape(val.to_s)}'" }.join(", ")
      fields = data.collect{|key, val| key.to_s }.join(", ")
      session.query("
        INSERT INTO #{collection_name}
        (#{ fields })
        VALUES (#{ values })
      ")
    end

    def update(collection_name, id, data = {})
      primary_key_name = primary_key_for(collection_name)
      key_values = data.collect{|key, val| %Q{#{key}='#{escape(val.to_s)}'} }.join(",")
      session.query("
        UPDATE #{collection_name}
        SET #{ key_values }
        WHERE #{primary_key_name}=#{id}
      ")
    end

    def delete(collection_name, id)
      primary_key_name = primary_key_for(collection_name)
      session.query("DELETE FROM #{collection_name} WHERE #{primary_key_name}=#{id}")
    end

    def schema(collection_name)
      parse_results(session.query(%Q{
        SELECT
          a.attname AS Field,
          t.typname || '(' || a.atttypmod || ')' AS Type,
          CASE WHEN a.attnotnull = 't' THEN 'YES' ELSE 'NO' END AS Null,
          CASE WHEN r.contype = 'p' THEN 'PRI' ELSE '' END AS Key,
          (SELECT substring(pg_catalog.pg_get_expr(d.adbin, d.adrelid), \'(.*)\')
            FROM
              pg_catalog.pg_attrdef d
            WHERE
              d.adrelid = a.attrelid
              AND d.adnum = a.attnum
              AND a.atthasdef) AS Default,
          '' as Extras
        FROM
          pg_class c 
          JOIN pg_attribute a ON a.attrelid = c.oid
          JOIN pg_type t ON a.atttypid = t.oid
          LEFT JOIN pg_catalog.pg_constraint r ON c.oid = r.conrelid 
          AND r.conname = a.attname
        WHERE
          c.relname = '#{collection_name}'
          AND a.attnum > 0        
        ORDER BY a.attnum
      }))
    end

    def primary_key_for(collection_name)
      result = session.query("
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
      ").rows.first
      result && result.first
    end

    def connected?
      !session.instance_variable_get("@conn").nil?
    end

    def close
      session.close
    end

    def id
      "postgresql"
    end

    def name
      I18n.t('adapters.postgresql.title')
    end

    def as_json(options = nil)
      {
        id: self.id,
        name: self.name
      }
    end  
  end
end
