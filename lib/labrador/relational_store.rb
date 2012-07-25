module Labrador
  module RelationalStore

    # Find all field names for array of records when driver is relational
    #
    # results - The array of key => val results from database driver
    # 
    # Returns the array of field (keys) name found from results
    def fields_for(results = [])
      if results.any?
        results.first.keys
      else
        []
      end
    end
  end
end