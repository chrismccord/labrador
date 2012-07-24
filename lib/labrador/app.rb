module Labrador
  class App
    attr_accessor :name, :path, :adapters, :adapter_errors

    @@supported_files = [
      "config/database.yml",
      "config/mongoid.yml"
    ]

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

    def self.is_supported_app?(directory)
      directory = File.expand_path(directory)
      @@supported_files.select{|file| File.exists?("#{directory}/#{file}") }.any?
    end

    def initialize(attributes = {})
      @name = attributes[:name]
      @path = attributes[:path]
      @adapter_errors = []
      @adapters = []
      @connected = false

      find_adapters
    end

    def find_adapters
      @@supported_files.each do |file|
        path = File.expand_path("#{@path}/#{file}")
        if File.exists?(path)
          adapter = Adapter.new(path) 
          @adapters << adapter if adapter.valid?
        end
      end
      
      @adapters
    end

    def adapter_names
      @adapters.collect(&:name)
    end

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
