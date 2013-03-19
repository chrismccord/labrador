module Labrador
  class NullApp
    attr_accessor :name, :connected, :path, :session, :virtual, :adapters, :adapter_errors

    def initialize(attributes = {})
      self.name = "Application"
    end

    def connected?
      false
    end

    # Establish connection to each of application's adapters
    def connect
      false
    end

    def disconnect
      false
    end

    def errors
      []
    end
    
    def to_s
      name.to_s
    end

    def adapters
      []
    end

    def find_adapter_by_name(name)
    end

    def as_json(options = nil)
      {
        name: name,
        path: path
      }
    end
  end
end
