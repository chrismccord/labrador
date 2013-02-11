module Labrador
  class App
    attr_accessor :name, :connected, :path, :session, :virtual, :adapters, :adapter_errors

    @@supported_files = [
      "config/database.yml",
      "config/mongoid.yml"
    ]

    POW_PATH = "~/.pow"

    # Find and instantiate all applications from given directory path
    #
    # path - The String path to the directory containing the applications
    # 
    # Returns the Array of App instances found in path
    def self.find_all_from_path(path)
      return [] unless path

      path = File.expand_path(path)
      apps = []
      directories = Dir.entries(path).select{|entry| ![".", ".."].include?(entry) }
      directories.each do |dir|
        current_path = "#{path}/#{dir}"
        next unless is_supported_app?(current_path)
        apps << self.new(name: dir, path: current_path)
      end

      apps
    end

    # Find and instantiate all applications from active Sessions
    #
    # sessions - The Session Array. Defaults to active Sessions
    # 
    # Returns the Array of App instances
    def self.find_all_from_sessions(sessions = Session.active)
      sessions.collect do |session|
        self.new session: session,
                 virtual: true,
                 name: session.name,
                 host: session.host,
                 user: session.username,
                 database: session.database,
                 password: session.password,
                 socket: session.socket
      end
    end

    def self.supports_pow?
      File.exist? File.expand_path(POW_PATH)
    end

    # Check if given directory contains a supported application
    #
    # directory - The String path to the application's directory
    # 
    # Returns true if application in directory contains any supported files
    def self.is_supported_app?(directory)
      directory = File.expand_path(directory)
      @@supported_files.select{|file| File.exists?("#{directory}/#{file}") }.any?
    end

    # Initialize App instance
    # 
    # attributes
    #   name - The required String name of the application
    #   path - The required String path to the application
    #   virtual - The optional Boolean inidicating a manually created connection for the app
    #   session - The optional Session for the Application's connection. Required if virtual
    #
    def initialize(attributes = {})
      @name     = attributes[:name] || (raise ArgumentError.new('Missing attribute :name'))
      @path     = attributes[:path]
      @session  = attributes[:session]
      @virtual  = attributes[:virtual]
      @adapter_errors = []
      @adapters = []
      @connected = false

      if is_virtual?
        find_adapters_from_session
      else
        find_adapters_from_path
      end
    end

    def is_virtual?
      self.virtual
    end

    # Find all adapters for application's supported configuration files
    #
    # Returns the array of valid adapters found
    def find_adapters_from_path
      @@supported_files.each do |file|
        path = File.expand_path("#{self.path}/#{file}")
        if File.exists?(path)
          adapter = Adapter.new(path, self)
          self.adapters << adapter if adapter.valid?
        end
      end
      
      self.adapters
    end

    def find_adapters_from_session
      adapter = Adapter.new(session.to_hash, self)
      self.adapters << adapter if adapter.valid?

      self.adapters
    end

    def adapter_names
      self.adapters.collect(&:name)
    end

    def connected?
      self.connected
    end

    # Establish connection to each of application's adapters
    def connect
      return if connected?
      self.adapters.each{|adapter| adapter.connect }
      self.connected = true
    end

    def errors
      self.adapters.collect(&:errors).flatten
    end
    
    def to_s
      name.to_s
    end

    def as_json(options = nil)
      {
        name: name,
        path: path
      }
    end
  end
end
