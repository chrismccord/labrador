module Labrador
  module Configuration
    
    DEFAULT_LIMIT = 10

    attr_accessor :default_limit
    
    # set all configuration options to their default values
    def self.extended(base)
      base.reset
    end
    
    def configure
      yield self
    end
    
    def reset
      self.default_limit = DEFAULT_LIMIT
    end
  end
end