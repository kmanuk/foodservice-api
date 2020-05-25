class FillLocale < ActiveRecord::Migration[5.0]
  class User < ActiveRecord::Base
  end

  def up
    User.update_all(locale: I18n.default_locale)
  end
end
