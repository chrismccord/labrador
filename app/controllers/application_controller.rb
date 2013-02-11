class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :http_authenticate, except: [:unauthorized]

  helper_method :exports, :current_app

  
  def catch_errors
    begin
      yield
    rescue Exception => exception
      current_adapter.disconnect if current_adapter
      if request.xhr?
        return render_json_error(exception)
      else
        flash[:dump] = exception.to_s
        return redirect_to error_path
      end
    end
  end

  def render_json_error(error)
    render json: {
      error: error.to_s
    }
  end

  private

  def exports
    gon
  end
  
  def find_adapters
    @adapters = []
    return unless current_app
    current_app.connect
    if current_app.errors.any?
      return render_adapter_error(current_app.errors.first)
    end

    @adapters = current_app.adapters
  end

  def current_app
    return unless app_name_from_url
    @applications.select{|app| app.name.downcase == app_name_from_url }.first
  end

  def current_adapter
    @adapters && @adapters.select{|a| a.name == params[:adapter] }.first
  end

  def find_applications
    begin
      @applications = Labrador::App.find_all_from_path(apps_path) + 
                      Labrador::App.find_all_from_sessions
    rescue Exception => exception
      if request.xhr?
        return render_json_error(exception)
      else
        flash[:dump] = exception.to_s
        return redirect_to error_path
      end
    end
  end

  def apps_path
    if path_param
      File.expand_path("#{path_param}/../")
    elsif Labrador::App.supports_pow?
      Labrador::App::POW_PATH
    end
  end

  def path_param
    return unless params[:path].present?
    path = "#{params[:path]}"
    path += ".#{params[:format].to_s}" if params[:format]
    path = "/#{path}" if path[0] != '~'

    path
  end

  def app_name_from_url
    if request.subdomain.present?
      request.subdomain
    else
      path_param.to_s.split("/").last
    end
  end

  def authenticated?
    session[:authenticated]
  end

  # Handle redirecting to error page from an AdapterError
  #
  # adapter_error - The AdapterError generated from the current application
  #
  # Redirects to error_path with flash populated from error context
  def render_adapter_error(adapter_error)
    flash[:dump] = adapter_error.dump
    flash[:notice] = t('flash.notice.invalid_adapter', 
      adapter: adapter_error.adapter, 
      app: current_app.name
    )
    flash[:error] = adapter_error.message
    return redirect_to error_path
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
