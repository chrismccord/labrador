require 'rethinkdb'

module Labrador
  class RethinkDB
    extend Configuration
    include ::RethinkDB::Shortcuts

    include Store
    include ViewHelper
    
    attr_accessor :host, :port, :database, :connection

    DEFAULT_PORT = 28015

    def initialize(params = {})
      @host     = params.fetch :host
      @port     = params.fetch :port, DEFAULT_PORT
      @database = params.fetch :database

      @connection = r.connect(host, port, database)
      connection.use database
    end

    def session
      r
    end

    def db_session
      session.db(database)
    end

    def collections
      session.db(database).table_list.run
    end

    def fields_for(documents)
      fields = super documents
      if fields.include?("id")
        ["id"] + fields.reject{|field| field == "id" }
      else
        fields
      end
    end

    def find(collection_name, options = {})
      order_by   = options.fetch :order_by, primary_key_for(collection_name)
      limit      = (options.fetch :limit, RethinkDB.default_limit).to_i
      skip       = (options.fetch :skip,  0).to_i
      direction  = options[:direction] == "desc" ? "desc" : "asc"

      db_session.table(collection_name)
        .order_by(r.send(direction, order_by))
        .skip(skip)
        .limit(limit)
        .run
        .to_a
    end

    def create(collection_name, data = {})
      db_session.table(collection_name).insert(data).run
    end

    def update(collection_name, id, data = {})
      db_session.table(collection_name).get(id).update{ data }.run
    end

    def delete(collection_name, id)
      db_session.table(collection_name).get(id).delete.run
    end

    def primary_key_for(collection_name)
      "id"
    end

    def connected?
      !connection.debug_socket.nil?
    end

    def close
      connection.close
    end

    def id
      "rethinkdb"
    end

    def name
      I18n.t('adapters.rethinkdb.title')
    end

    def schema(collection)
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
