module Labrador
  class AdapterError
    
    attr_accessor :attributes, :message, :adapter, :dump

    def initialize(attributes = {})
      @message = attributes.fetch :message
      @adapter = attributes.fetch :adapter
      @dump    = attributes.fetch :dump
    end

    def to_s
      message
    end
  end
end