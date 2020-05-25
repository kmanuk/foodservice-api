module Filterable
  extend ActiveSupport::Concern


  module ClassMethods

    def filter(params)
      params ||= {}
      scope = self.all
      params.each do |filter, value|
        scope = scope.send("with_#{filter}", value) if valid_filters.include?(filter) && value.present?
      end
      scope
    end

  end
end
