module Labrador
  class App
    attr_accessor :name, :path, :adapters, :adapter_errors

    @@supported_files = [
      "config/database.yml",
      "config/mongoid.yml"
    ]

    # Find and instantiate all applications from given directory path
    #
    # path - The String path to the directory containing the applications
    # 
    # Returns the Array of App instances found in path
    def self.find_all_from_path(path)
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
    #
    def initialize(attributes = {})
      @name = attributes[:name] || (raise ArgumentError.new('Missing attribute :name'))
      @path = attributes[:path] || (raise ArgumentError.new('Missing attributes :path'))
      @adapter_errors = []
      @adapters = []
      @connected = false

      find_adapters
    end

    # Find all adapters for application's supported configuration files
    #
    # Returns the array of valid adapters found
    def find_adapters
      @@supported_files.each do |file|
        path = File.expand_path("#{@path}/#{file}")
        if File.exists?(path)
          adapter = Adapter.new(path, self)
          @adapters << adapter if adapter.valid?
        end
      end
      
      @adapters
    end

    def adapter_names
      @adapters.collect(&:name)
    end

    # Establish connection to each of application's adapters
    def connect
      return if @connected
      @adapters.each{|adapter| adapter.connect }
      @connected = true
    end

    def to_s
      @name.to_s
    end

    def as_json(options = nil)
      {
        name: @name,
        path: @path        
      }
    end
  end
end
