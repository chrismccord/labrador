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

    attr_accessor :configuration_path, :configuration, :errors, :database

    def initialize(configuration_path, options = {})
      @configuration_path = File.expand_path(configuration_path)
      @errors = []
    end

    def configuration
      @configuration ||= case configuration_path.split("/").last
        when "database.yml" then database_yml_config
        when "mongoid.yml"  then mongoid_yml_config
      end
    end

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

    def database_yml_config
      path = File.expand_path(configuration_path)      
      return unless File.exists?(path)       
      config = YAML.load(File.open(path))

      config["development"] rescue nil
    end

    def mongoid_yml_config
      path = File.expand_path(configuration_path)
      return unless File.exists?(path)

      config = YAML.load(File.open(path))
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

    def connect
      return unless configuration
      @database = @@connections[name][db_name]    
      return true if connected?

      begin
        @database = case name
        when "mongodb"        then MongoDB.new(credentials)
        when "postgresql"     then Postgres.new(credentials)
        when /^mysql(2)?$/    then Mysql.new(credentials)
        when /^sqlite(2|3)?$/ then Sqlite.new(credentials)
        else
          add_error(I18n.t('adapters.unsupported_adapter'))
          nil
        end
      rescue Exception => e
        add_error(e.to_s)
      end

      @@connections[name][db_name] = @database
    end

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

