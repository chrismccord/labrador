module Labrador
  class Session
    
    attr_accessor :adapter, :name, :host, :username, :database, :password, :socket

    def self.active
      (Rails.cache.read(:sessions) || []).collect{|session_hash| self.new(session_hash) }
    end   

    def self.add(new_session)
      new_session = self.new(new_session) if new_session.kind_of? Hash
      existing_sessions = self.active.select{|s| s.name != new_session.name }
      existing_sessions << new_session
      Rails.cache.write :sessions, existing_sessions.collect(&:to_hash)
    end

    def self.clear_all
      Rails.cache.delete(:sessions)
    end

    def initialize(attributes = {})
      @adapter  = attributes["adapter"]
      @name     = attributes["name"]
      @host     = attributes["host"]
      @username = attributes["username"]
      @database = attributes["database"]
      @password = attributes["password"]
      @socket   = attributes["socket"]
    end

    def to_hash
      {
        "adapter" => @adapter,
        "name" => @name,
        "host" => @host,
        "username" => @username,
        "database" => @database,
        "password" => @password,
        "socket" => @socket
      }
    end
  end
end