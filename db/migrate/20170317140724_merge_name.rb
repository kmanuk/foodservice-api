class MergeName < ActiveRecord::Migration[5.0]
  class User < ActiveRecord::Base
  end

  def up
    User.find_each do |user|
      user.update(name: [user.first_name, user.last_name].reject(&:blank?).join(' '))
    end
  end
end
