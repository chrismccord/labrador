module Labrador
  module ViewHelper

    def name
      I18n.t("adapters.#{self.id}.title")
    end

    def collection_name(count = 1)
      I18n.t("adapters.#{self.id}.collection", count: count)
    end
  end
end