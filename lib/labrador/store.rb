module Labrador
  module Store
    
    def fields_for(documents = [])
      fields = []
      documents.each do |document|
        document.keys.each{|key| fields << key unless fields.include?(key) }
      end

      fields.sort
    end
  end
end