class SessionsController < ApplicationController

  
  def self.sessions
    Rails.cache.fetch(:sessions){ [] }
  end  
  
  def self.sessions=(sessions)
    Rails.cache.write :sessions, sessions
  end  

  def self.add_session(session)
    session.each{|key, value| session[key] = nil if value.blank? }
    Rails.cache.write :sessions, [session]
  end

  def new
  end

  def create
    SessionsController.add_session params[:session]
    redirect_to "http://#{params[:session][:name]}.labrador-dev.dev"
  end

  def destroy
  end
end