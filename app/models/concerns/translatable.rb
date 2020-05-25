module Translatable
  extend ActiveSupport::Concern

  def name
    self[I18n.locale] || self[I18n.default_locale]
  end
end
