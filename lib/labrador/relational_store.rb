module Labrador
  module RelationalStore

    # Find all field names for array of records when driver is relational
    #
    # results - The array of key => val results from database driver
    # 
    # Returns the array of field (keys) name found from results
    def fields_for(results = [])
      return [] if results.empty?

      if results.first.kind_of?(Hash)
        results.first.keys
      elsif results.first.kind_of?(Array)
        results.first.collect{|field| field && field.first.to_s }
      end
    end
  end
end