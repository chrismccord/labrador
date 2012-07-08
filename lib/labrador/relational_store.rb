module Labrador
  module RelationalStore

    def fields_for(results = [])
      if results.any?
        results.first.keys
      else
        []
      end
    end
  end
end