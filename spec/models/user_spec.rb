require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'macros' do
    it { is_expected.to have_attached_file(:avatar) }
    it { is_expected.to have_attached_file(:video) }
    it { is_expected.to have_attached_file(:video_snapshot) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:address) }
    it { is_expected.to have_many(:items) }
  end

  context 'validations' do
    subject { build(:user) }

    it { is_expected.to allow_values('driver', 'seller', 'buyer', 1, 2, 0).for(:role) }
    it { is_expected.to validate_attachment_content_type(:avatar).allowing('image/png', 'image/gif').rejecting('text/plain', 'video/mpeg') }
    it { is_expected.to validate_attachment_size(:avatar).less_than(10.megabytes) }

    it { is_expected.to validate_attachment_content_type(:video_snapshot).allowing('image/png', 'image/gif').rejecting('text/plain', 'video/mpeg') }
    it { is_expected.to validate_attachment_size(:video_snapshot).less_than(10.megabytes) }

    it { is_expected.to validate_attachment_content_type(:video).allowing('video/mp4', 'video/mpeg').rejecting('text/plain', 'image/gif') }
    it { is_expected.to validate_attachment_size(:video).less_than(100.megabytes) }

    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_uniqueness_of(:uid).scoped_to(:provider).case_insensitive }

    describe '#active_orders' do
      let(:user) { create(:user, role: :seller) }

      context 'with active paid orders' do
        it 'cannot change role' do
          create(:order, :with_payment_paid, seller: user, status: :ready)
          user.role = :driver
          expect(user).to be_invalid
          expect(user.errors[:role]).to include "can't be switched with active orders"
        end
      end

      context 'with active unpaid orders' do
        it 'can change role' do
          create(:order, :with_payment, seller: user, status: :ready)
          user.role = :driver
          expect(user).to be_valid
          expect(user).to be_driver

        end
      end

      context 'without active orders' do
        it 'can change role' do
          create(:order, :with_payment, seller: user, status: :ready)
          create(:order, :with_payment, seller: user, status: :delivered)
          expect(user).to be_valid
        end
      end
    end

    # context 'if driver' do
    #   before { allow(subject).to receive(:driver?).and_return(true) }

    #   it { is_expected.to validate_presence_of(:phone) }
    #   it { is_expected.to validate_presence_of(:car_type) }
    #   it { is_expected.to validate_presence_of(:plate_number) }
    #   it { is_expected.to validate_presence_of(:driver_license) }
    #   it { is_expected.to validate_presence_of(:insurance_name) }
    #   it { is_expected.to validate_presence_of(:insurance_number) }
    # end

    # context 'if not driver' do
    #   before { allow(subject).to receive(:driver?).and_return(false) }

    #   it { is_expected.not_to validate_presence_of(:phone) }
    #   it { is_expected.not_to validate_presence_of(:car_type) }
    #   it { is_expected.not_to validate_presence_of(:plate_number) }
    #   it { is_expected.not_to validate_presence_of(:driver_license) }
    #   it { is_expected.not_to validate_presence_of(:insurance_name) }
    #   it { is_expected.not_to validate_presence_of(:insurance_number) }
    # end
  end

  context 'scopes' do
    describe '.regular_drivers' do
      it 'should return only regular drivers' do
        create(:driver, certified_driver: true)
        driver = create(:driver, certified_driver: false)

        expect(User.regular_drivers.count).to eq 1
        expect(User.regular_drivers.first).to eq driver
      end
    end

    describe '.certified_drivers' do
      it 'should return only certified drivers' do
        driver = create(:driver, certified_driver: true)
        create(:driver, certified_driver: false)

        expect(User.certified_drivers.count).to eq 1
        expect(User.certified_drivers.first).to eq driver
      end
    end
  end

  context 'callbacks' do

    describe 'before_delete' do
      let(:user) { create(:user) }

      it 'raise error if user has orders' do
        create(:fast_created_order, seller: user)
        expect{user.destroy}.to raise_error
      end

      it 'allows to delete user without orders' do
        expect(user.destroy).to be_truthy
      end

    end

    describe '#set_locale' do
      let(:user) { build(:user) }

      it 'should set locale' do
        I18n.locale = :en
        user.save
        expect(user.locale).to eq I18n.default_locale.to_s

        I18n.locale = :ar
        user.save
        expect(user.locale).to eq 'ar'
      end
    end
  end

  describe '#inactive!' do
    it 'should deactivate user' do
      user = create(:user, active: true, active_driver: true)
      user.inactive!
      expect(user.active).to be false
      expect(user.active_driver).to be false
    end
  end

  describe '#as_json' do
    let(:user) { create(:user, address: create(:address)) }

    let(:except_user_attributes) { %w(avatar_file_name avatar_content_type avatar_file_size avatar_updated_at created_at updated_at video_file_name video_content_type video_file_size video_updated_at) }

    context 'without options' do
      it 'should return user json' do
        expect(except_user_attributes - user.as_json.keys).to eq except_user_attributes
        expect(user.as_json['avatar_url']).not_to be nil
        expect(user.as_json['video_url']).not_to be nil
        expect(user.as_json['avatar_thumb']).not_to be nil
        expect(user.as_json['address']).not_to be nil
      end
    end

    context 'with options' do
      it 'should return user json' do
        expect(except_user_attributes - user.as_json.keys).to eq except_user_attributes
        expect(user.as_json({except: [:id]}).keys).not_to include 'id'
        expect(user.as_json['avatar_url']).not_to be nil
        expect(user.as_json['avatar_thumb']).not_to be nil
        expect(user.as_json['video_url']).not_to be nil
        expect(user.as_json['address']).not_to be nil
      end
    end
  end


  describe '#address_params' do
    let(:user) { create(:user, address: create(:address)) }

    it 'returns address in json format' do
      expect(user.address_params['id']).not_to be nil
      expect(user.address_params['location']).not_to be nil
      expect(user.address_params['latitude']).not_to be nil
      expect(user.address_params['longitude']).not_to be nil
    end
  end


  describe '#has_active_orders?' do
    let(:user) { create(:user, role: :seller) }
    let!(:order) { create(:order, :with_payment_paid, seller: user, status: :ready) }


    context 'without arguments' do
      it 'should check current role' do
        expect(user.has_active_orders?).to be true
      end
    end

    context 'with arguments' do
      it 'should check orders for role' do
        expect(user.has_active_orders?('buyer')).to be false
      end
    end
  end

  describe '#av_rate' do
    context 'User with reviews' do
      let(:user_with_reviews) { create(:user, :with_reviews) }

      it 'has average rate' do
        expect(user_with_reviews.av_rate).not_to be(nil)
      end

      it 'average rate equal all rates / amount of reviews' do
        user_with_reviews.reviews.update_all(rate: 5)
        expect(user_with_reviews.av_rate).to eq(5)
      end
    end

    context 'User without reviews' do
      let(:user) { create(:user) }

      it 'has average rate' do
        expect(user.av_rate).to be(nil)
      end
    end
  end

  describe '#send_password_change_notification' do
    let(:user) { create(:user, role: :seller) }

    it 'call send_devise_notification' do
      expect(user).to receive(:send_devise_notification).with(:password_change, {password: '123456'})
      user.send_password_change_notification({password: '123456'})
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
