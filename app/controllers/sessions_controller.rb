class SessionsController < ApplicationController
  include ApplicationHelper

  before_filter :find_applications, only: [:new]
  around_filter :catch_errors, only: [:create, :destroy]

  def new
  end

  def create
    app = Labrador::App.new(session_params)
    Labrador::Session.add session_params
    redirect_to app_url(app)
  end

  def destroy
    Labrador::Session.clear_all
    redirect_to root_url(subdomain: false)
  end


  private

  def session_params
    params[:session] ||= {}
    params[:session].each{|key, value| session[key] = nil if value.blank? }
    
    params[:session]
  end
end