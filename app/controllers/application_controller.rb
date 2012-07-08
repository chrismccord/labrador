class ApplicationController < ActionController::Base
  protect_from_forgery

  @@connections = {
    "mongodb" => {},
    "postgresql" => {},
    "mysql" => {},
    "mysql2" => {},
    "sqlite"=>  {}
  }

  helper_method :exports, :current_application

  private

  def exports
    gon
  end

  def parse_options
    params.slice(:limit, :order_by, :direction, :conditions, :skip)
  end
  
  def find_adapter
    if request.subdomain.present?
      conf = database_yml_config || mongoid_yml_config || {}
      credentials = {
        host: conf["host"],
        user: conf["username"],
        database: conf["database"],
        password: conf["password"]
      }
      @adapter = case conf["adapter"]
      when "mongodb"
        @@connections[conf["adapter"]][conf["database"]] ||= Labrador::MongoDB.new(credentials)
      when "postgresql"
        @@connections[conf["adapter"]][conf["database"]] ||= Labrador::Postgres.new(credentials)
      when "mysql", "mysql2"
        @@connections[conf["adapter"]][conf["database"]] ||= Labrador::Mysql.new(credentials)
      when "sqlite"
        @@connections[conf["adapter"]][conf["database"]] ||= Labrador::Sqlite.new(credentials)
      else
        raise 'Invalid adapter'
      end   
    end
  end

  def database_yml_config
    path = File.expand_path("~/.pow/#{request.subdomain}/config/database.yml")
    config = YAML.load(File.open(path))["development"] rescue nil
  end

  def mongoid_yml_config
    path = File.expand_path("~/.pow/#{request.subdomain}/config/mongoid.yml")
    config = begin
      config = YAML.load(File.open(path))["development"]
      # support mongoid 3
      config = config["sessions"]["default"] if config["sessions"]
      config["adapter"] ||= "mongodb"
      config
    rescue 
      nil
    end
  end

  def current_application
    request.subdomain
  end

  def find_applications
    @applications = Dir.entries(File.expand_path("~/.pow")).select{|entry| 
      ![".", ".."].include?(entry) 
    }
  end
end
