FactoryGirl.define do
  factory :user do
    name              { generate :name }
    password          { generate :password }
    email             { generate :email }
    phone             { generate :phone }
    token             { generate :token }
    quickblox_user_id { generate :number }
    confirmed_at    Time.now
    role            'buyer'

    factory :seller do
      role            'seller'
      address
      business_name   { generate :word}
      iban            { generate :iban }
      bank_name       { generate :bank_name}

      trait :recommended do
        recommended_seller  true
      end
    end

    factory :driver do
      role            'driver'
      car_type              { generate :car_type }
      plate_number          { generate :plate_number }
      driver_license        { generate :driver_license }
      insurance_name        { generate :insurance_name }
      insurance_number      { generate :insurance_number }
      approved_driver       true

      trait :certified do
        certified_driver  true
      end

      trait :not_approved_driver do
        approved_driver  false
      end

    end

    factory :buyer do
      role            'buyer'
    end

    trait :uncofirmed do
      confirmed_at  nil
    end

    trait :with_avatar do
      avatar { generate :file }
    end

    trait :with_video do
      video { generate :video }
      video_snapshot { generate :file }
    end


    trait :with_excellent_reviews do
      after(:create) do |user|
        create_list(:review, 3, :five_rate, ratable: user)
      end
    end

    trait :with_reviews do
      after(:create) do |user|
        create_list(:review, 3, ratable: user)
      end
    end
  end
end

# == Schema Information
#
# Table name: users
#
#  id                          :integer          not null, primary key
#  provider                    :string           default("email"), not null
#  uid                         :string           default(""), not null
#  encrypted_password          :string           default(""), not null
#  reset_password_token        :string
#  reset_password_sent_at      :datetime
#  remember_created_at         :datetime
#  sign_in_count               :integer          default("0"), not null
#  current_sign_in_at          :datetime
#  last_sign_in_at             :datetime
#  current_sign_in_ip          :string
#  last_sign_in_ip             :string
#  confirmation_token          :string
#  confirmed_at                :datetime
#  confirmation_sent_at        :datetime
#  unconfirmed_email           :string
#  phone                       :string
#  email                       :string
#  tokens                      :json
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  avatar_file_name            :string
#  avatar_content_type         :string
#  avatar_file_size            :integer
#  avatar_updated_at           :datetime
#  token                       :string
#  role                        :integer
#  address_id                  :integer
#  recommended_seller          :boolean          default("false")
#  approved_driver             :boolean          default("false")
#  certified_driver            :boolean          default("false")
#  video_file_name             :string
#  video_content_type          :string
#  video_file_size             :integer
#  video_updated_at            :datetime
#  locale                      :string
#  quickblox_user_id           :integer
#  latitude                    :float
#  longitude                   :float
#  name                        :string
#  active                      :boolean          default("true")
#  video_snapshot_file_name    :string
#  video_snapshot_content_type :string
#  video_snapshot_file_size    :integer
#  video_snapshot_updated_at   :datetime
#  business_name               :string
#  active_driver               :boolean          default("true")
#  iban                        :string
#  bank_name                   :string
#  car_type                    :string
#  plate_number                :string
#  driver_license              :string
#  insurance_name              :string
#  insurance_number            :string
#  push_count_messages         :integer          default("0")
#  push_count_orders           :integer          default("0")
#
# Indexes
#
#  index_users_on_address_id            (address_id)
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email)
#  index_users_on_latitude              (latitude)
#  index_users_on_longitude             (longitude)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_role                  (role)
#  index_users_on_uid_and_provider      (uid,provider) UNIQUE
#
