FactoryGirl.define do
  sequence :email do
    Faker::Internet.email
  end

  sequence :password do
    Faker::Internet.password
  end

  sequence :number do
    Faker::Number.number 3
  end

  sequence :float do
    Faker::Number.decimal(2)
  end

  sequence :title do
    Faker::Name.title
  end

  sequence :name do
    Faker::Name.name
  end

  sequence :first_name do
    Faker::Name.first_name
  end

  sequence :last_name do
    Faker::Name.last_name
  end

  sequence :username do
    Faker::Internet.user_name
  end

  sequence :country do
    Faker::Address.country
  end

  sequence :state do
    Faker::Address.state
  end

  sequence :domain_word do
    Faker::Internet.domain_word
  end

  sequence :address do
    Faker::Address.street_address
  end

  sequence :zip do
    Faker::Address.zip
  end

  sequence :city do
    Faker::Address.city
  end

  sequence :latitude do
    Faker::Number.decimal(2, 6)
  end

  sequence :longitude do
    Faker::Number.decimal(2, 6)
  end

  sequence :url do
    Faker::Internet.url
  end

  sequence :word do
    Faker::Lorem.word
  end

  sequence :text do
    Faker::Lorem.sentence
  end

  sequence :phone do
    Faker::PhoneNumber.cell_phone
  end

  sequence :boolean do
    Faker::Boolean.boolean
  end

  sequence :date_forward do
    Faker::Date.between(1.year.from_now, 2.years.from_now)
  end

  sequence :date_backward do
    Faker::Date.between(1.year.ago, 2.years.ago)
  end

  sequence :credit_card_number do
    Faker::Business.credit_card_number
  end

  sequence :credit_card_number_masked do
    card = Faker::Business.credit_card_number.tr('-','')
    card.gsub(card[4..11], '*' *6)
  end

  sequence :merchant_reference do
    Array.new(16) { rand(36).to_s(36) }.join
  end


  sequence :cvv do
    rand(000..999).to_s.rjust(3, '0')
  end

  sequence :file do
    Rack::Test::UploadedFile.new(Rails.root.join('spec', 'files', 'image.jpg'), 'image/jpg')
  end

  sequence :video do
    Rack::Test::UploadedFile.new(Rails.root.join('spec', 'files', 'video.mov'))
  end

  sequence :food do
    Faker::Food.ingredient
  end

  sequence :token do
    SecureRandom.uuid
  end

  sequence :iban do
    Array.new(8) { rand(36).to_s(36) }.join
  end

  sequence :bank_name do
    Faker::Bank.name
  end

  sequence :car_type do
    Faker::Vehicle.manufacture
  end

  sequence :plate_number do
    Faker::Vehicle.vin
  end

  sequence :driver_license do
    Array.new(8) { rand(36).to_s(36) }.join
  end

  sequence :insurance_name do
    Faker::Company.name
  end

  sequence :insurance_number do
    Faker::Company.ein
  end
end
