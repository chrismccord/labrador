module Labrador
  module Store
    
    # Find all field names for array of documents when driver is not relational
    #
    # documents - The array of key => val documents from database driver
    # 
    # Returns the array of field (keys) name found from documents
    def fields_for(documents = [])
      fields = []
      documents.each do |document|
        document.keys.each{|key| fields << key unless fields.include?(key) }
      end

      fields.sort
    end
  end
end