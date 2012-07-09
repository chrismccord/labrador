class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :http_authenticate, except: [:unauthorized]

  @@connections = {
    "mongodb" => {},
    "postgresql" => {},
    "mysql" => {},
    "mysql2" => {},
    "sqlite" => {},
    "sqlite2" => {},
    "sqlite3" => {}
  }

  helper_method :exports, :current_app

  private

  def exports
    gon
  end

  def parse_options
    params.slice(:limit, :order_by, :direction, :conditions, :skip)
  end
  
  def find_adapters
    @adapters = []
    if current_app
      current_app.adapter_configruations.each do |conf|
        begin
          @adapters << case conf["adapter"]
          when "mongodb"
            @@connections[conf["adapter"]][conf["database"]] ||= Labrador::MongoDB.new(credentials)
          when "postgresql"
            @@connections[conf["adapter"]][conf["database"]] ||= Labrador::Postgres.new(credentials)
          when "mysql", "mysql2"
            @@connections[conf["adapter"]][conf["database"]] ||= Labrador::Mysql.new(credentials)
          when "sqlite", "sqlite2", "sqlite3"
            @@connections[conf["adapter"]][conf["database"]] ||= Labrador::Sqlite.new(credentials)
          else
            raise t('adapters.unsupported_adapter', adapter: conf["adapter"])
          end
        rescue Exception => e
          flash[:dump] = conf
          flash[:notice] = t('flash.notice.invalid_adapter', 
            adapter: conf["adapter"], 
            app: current_app.name)
          flash[:error] = e.to_s
          return redirect_to error_path
        end
      end
    end

    @adapters
  end

  def current_app
    return unless app_name_from_url
    @applications.select{|app| app.name == app_name_from_url }.first
  end

  def current_adapter
    @adapters.select{|a| a.id == params[:adapter] }.first
  end

  def find_applications
    @applications = Labrador::App.find_all_from_path(apps_path)
  end

  def apps_path
    if request.subdomain.present?
      path = "~/.pow"
    else
      path = File.expand_path("#{path_param}/../")
    end

    path
  end

  def path_param
    path = "#{params[:path]}"
    path += ".#{params[:format].to_s}" if params[:format]
    path = "/#{path}" if path[0] != '~'

    path
  end

  def app_name_from_url
    (request.subdomain.present? && request.subdomain) || path_param.split("/").last
  end

  def authenticated?
    session[:authenticated]
  end

  def http_authenticate
    unless ENV['LABRADOR_USER'].present? && ENV['LABRADOR_PASS'].present?
      return redirect_to unauthorized_path
    end
    return if authenticated?

    authenticate_or_request_with_http_basic do |username, password|
      authenticated = (username == ENV['LABRADOR_USER'] && password == ENV['LABRADOR_PASS'])
      session[:authenticated] = true if authenticated

      authenticated
    end
  end
end
