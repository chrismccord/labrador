module Labrador
  class Adapter

    @@connections = {
      "mongodb" => {},
      "postgresql" => {},
      "mysql" => {},
      "mysql2" => {},
      "sqlite" => {},
      "sqlite2" => {},
      "sqlite3" => {}
    }

    attr_accessor :configuration_path, :configuration, :errors, :database, :app


    # initialize new Adapter from configuration path
    #
    # configuration_path - The string path to the adapter's configuration file
    #
    def initialize(configuration_path, app)
      if configuration_path.kind_of? String
        @configuration_path = File.expand_path(configuration_path)
      elsif configuration_path.kind_of? Hash
        @configuration = configuration_path
      else
        raise ArgumentError.new("Invalid configuration_path type, #{configuration_path.class}")
      end
      @app = app
      @errors = []
    end

    # Lazy load adapter's configuration from configuration_path
    #
    # Two configuration files are supported
    #   - database.yml (active record, datamapper)
    #   - mongoid.yml (mongoid)
    #
    # Returns the Hash configuration
    def configuration
      @configuration ||= case configuration_path.split("/").last
        when "database.yml" then database_yml_config
        when "mongoid.yml"  then mongoid_yml_config
      end
    end

    # Returns the hash of connection credentials extracted from configuration file
    def credentials
      return unless configuration
      {
        host: configuration["host"],
        user: configuration["username"],
        database: configuration["database"],
        password: configuration["password"],
        socket: configuration["socket"]
      }
    end

    def sqlite_credentials
      return unless configuration

      if configuration["database"].chars.first == "/"
        db_path = configuration["database"]
      else
        db_path = File.expand_path("#{app.path}/#{configuration["database"]}")
      end

      {
        host: configuration["host"],
        user: configuration["username"],
        database: db_path,
        password: configuration["password"],
        socket: configuration["socket"]
      }
    end

    # Attempt to load database.yml hash configuration
    def database_yml_config
      path = File.expand_path(configuration_path)      
      return unless File.exists?(path)       
      config = YAML.load(ERB.new(File.read(path)).result)

      config["development"] rescue nil
    end

    # Attempt to load mongoid.yml hash configuration
    def mongoid_yml_config
      path = File.expand_path(configuration_path)
      return unless File.exists?(path)

      config = YAML.load(ERB.new(File.read(path)).result)
      config = config["development"] || return
      # support mongoid 3
      config = config["sessions"]["default"] if config["sessions"]
      config["adapter"] = "mongodb"

      config
    end

    def valid?
      !configuration.nil?
    end

    def connected?
      database && database.connected?
    end

    # Create database connection for adapter based on adapter name from configuration
    # 
    # - Connection errors are caught and appended to errors collection
    # - The connection is 'persisted' in a class instance variable if successful
    #   and returned for subsequent connection attempts
    #
    def connect
      return unless configuration
      @database = @@connections[name][db_name]    
      return true if connected?

      begin
        @database = case name
        when "mongodb"        then MongoDB.new(credentials)
        when "postgresql"     then Postgres.new(credentials)
        when /^mysql(2)?$/    then Mysql.new(credentials)
        when /^sqlite(2|3)?$/ then Sqlite.new(sqlite_credentials)
        else
          add_error(I18n.t('adapters.unsupported_adapter'))
          nil
        end
      rescue Exception => e
        add_error(e.to_s)
      end

      @@connections[name][db_name] = @database
    end

    # Remove persistent connection from class instance and close database connection
    def disconnect
      database.close if connected?
      @@connections[name][db_name] = nil
    end

    def name
      configuration["adapter"] if configuration
    end

    def db_name
      configuration["database"] if configuration
    end

    def add_error(message)
      @errors << {
        message: message,
        adapter: name,
        dump: configuration
      }
    end
  end
end

