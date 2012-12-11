module ApplicationHelper
  def app_url(app)
    if request.subdomain.present? || request.port == 80
      "http://#{app.name}.#{request.domain}#{request.port == 80 ? "" : ":#{request.port}"}"
    else
      "http://#{request.domain}#{request.port == 80 ? "" : ":#{request.port}"}/#{app.path}"
    end
  end
end
