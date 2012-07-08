module Labrador
  class App
    attr_accessor :name, :path

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
      File.exists?("#{directory}/config/database.yml") ||
      File.exists?("#{directory}/config/mongoid.yml")
    end

    def initialize(attributes = {})
      @name = attributes[:name]
      @path = attributes[:path]
    end

    def database_yml_config
      path = File.expand_path("#{@path}/config/database.yml")
      config = YAML.load(File.open(path))["development"] rescue nil
    end

    def mongoid_yml_config
      path = File.expand_path("#{@path}/config/mongoid.yml")
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

    def adapters
      [database_yml_config, mongoid_yml_config].collect do |config|
        config["adapter"]
      end
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