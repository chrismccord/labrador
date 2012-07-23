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

      load_configuration
    end

    def load_configuration
      @configuration = case @configuration_path.split("/").last
        when "database.yml" then database_yml_config
        when "mongoid.yml"  then mongoid_yml_config
        else {}
      end
    end

    def database_yml_config
      path = File.expand_path(@configuration_path)      
      return unless File.exists?(path)       
      config = YAML.load(File.open(path))

      config["development"] rescue nil
    end

    def mongoid_yml_config
      path = File.expand_path(@configuration_path)
      return unless File.exists?(path)

      config = YAML.load(File.open(path))
      config = config["development"] || return
      # support mongoid 3
      config = config["sessions"]["default"] if config["sessions"]
      config["adapter"] = "mongodb"

      config
    end

    def is_valid?
      @configuration
    end

    def connect
      return unless @configuration
      conf = @configuration
      credentials = {
        host: conf["host"],
        user: conf["username"],
        database: conf["database"],
        password: conf["password"],
        socket: conf["socket"]
      }
      begin
        @database = case conf["adapter"]
        when "mongodb"
          @@connections[conf["adapter"]][conf["database"]] ||= Labrador::MongoDB.new(credentials)
        when "postgresql"
          @@connections[conf["adapter"]][conf["database"]] ||= Labrador::Postgres.new(credentials)
        when "mysql", "mysql2"
          @@connections[conf["adapter"]][conf["database"]] ||= Labrador::Mysql.new(credentials)
        when "sqlite", "sqlite2", "sqlite3"
          @@connections[conf["adapter"]][conf["database"]] ||= Labrador::Sqlite.new(credentials)
        else
          @errors << {
            message: I18n.t('adapters.unsupported_adapter', adapter: conf["adapter"]),
            adapter: conf["adapter"],
            dump: conf
          }
        end
      rescue Exception => e
        @errors << {
          message: e.to_s,
          adapter: conf["adapter"],
          dump: conf
        }
      end

      @errors.empty?
    end

    def name
      @configuration["adapter"]
    end
  end
end