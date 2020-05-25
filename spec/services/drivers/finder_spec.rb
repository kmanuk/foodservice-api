require 'rails_helper'

RSpec.describe Drivers::Finder do
  describe '.call' do
    before { allow(Drivers::Finder).to receive(:call).and_call_original }

    let(:order) { create(:order) }
    let(:kiev) { create(:address, location: 'Kiev, Khreshchatyk, Ukraine', latitude: 50.447174, longitude: 30.521893) }
    let(:ny) { create(:address, location: 'New York, NY, USA', latitude: 40.701716, longitude: -73.984653) }

    context 'with address' do
      # Seller from Kiev
      let!(:s_kiev) { create(:seller, certified_driver: true, approved_driver: true, latitude: kiev.latitude, longitude: kiev.longitude) }
      # Certified and approved from Kiev
      let!(:ca_kiev) { create(:driver, name: 'Certified and approved', certified_driver: true, approved_driver: true, latitude: kiev.latitude, longitude: kiev.longitude) }
      # Certified and not approved from Kiev
      let!(:cn_kiev) { create(:driver, name: 'Certified and not approved', certified_driver: true, approved_driver: false, latitude: kiev.latitude, longitude: kiev.longitude) }
      # Certified and approved from NY
      let!(:ca_ny) { create(:driver, certified_driver: true, approved_driver: true, latitude: ny.latitude, longitude: ny.longitude) }
      # Regular and approved from Kiev
      let!(:ra_kiev) { create(:driver, certified_driver: false, approved_driver: true, latitude: kiev.latitude, longitude: kiev.longitude) }
      # Regular and not approved from Kiev
      let!(:rn_kiev) { create(:driver, certified_driver: false, approved_driver: false, latitude: kiev.latitude, longitude: kiev.longitude) }
      # Regular and approved from NY
      let!(:ra_ny) { create(:driver, certified_driver: false, approved_driver: true, latitude: ny.latitude, longitude: ny.longitude) }

      let!(:ca_kiev_inactive) { create(:driver, active_driver: false, certified_driver: true, approved_driver: true, latitude: kiev.latitude, longitude: kiev.longitude) }

      before { order.seller.update(address: kiev) }

      context 'for regular drivers' do
        it 'should find all certified & regular drivers' do
          result = Drivers::Finder.call(order: order, certified: false, distance: 100)
          expect(result).to be_a_success
          expect(result.drivers).not_to be_nil
          expect(result.drivers.size).to eq 2
          expect(result.drivers.to_a.sort).to eq [ca_kiev, ra_kiev].sort
        end

        it 'should find only free drivers (without current orders and without orders)' do
          drivers_in_kiev = create_list(:driver, 6, certified_driver: false, approved_driver: true, latitude: kiev.latitude, longitude: kiev.longitude)

          #Drivers with active orders
          create(:fast_created_order, :cooking,  driver: drivers_in_kiev[0])
          create(:fast_created_order, :ready,  driver: drivers_in_kiev[1])
          create(:fast_created_order, :picking_up,  driver: drivers_in_kiev[2])
          create(:fast_created_order, :on_the_way,  driver: drivers_in_kiev[3])

          #Drivers with finished orders
          create(:fast_created_order, :delivered,  driver: drivers_in_kiev[4])
          create(:fast_created_order, :canceled,  driver: drivers_in_kiev[5])

          #Drivers without orders
          #ca_kiev, ra_kiev

          result = Drivers::Finder.call(order: order, certified: false, distance: 100)
          expect(result).to be_a_success
          expect(result.drivers).not_to be_nil
          expect(result.drivers.size).to eq 4
          expect(result.drivers.to_a.sort).to eq [ca_kiev, ra_kiev, drivers_in_kiev[4], drivers_in_kiev[5]].sort
        end


      end

      context 'for certified drivers' do
        it 'should find only certified drivers' do
          result = Drivers::Finder.call(order: order, certified: true, distance: 100)
          expect(result).to be_a_success
          expect(result.drivers).not_to be_nil
          expect(result.drivers.size).to eq 1
          expect(result.drivers.first).to eq ca_kiev
        end
      end

      context 'with except distance' do
        context 'for certified drivers' do
          it 'should find drivers' do
            result = Drivers::Finder.call(order: order, certified: true, distance: 100000, except_distance: 100)
            expect(result).to be_a_success
            expect(result.drivers).not_to be_nil
            expect(result.drivers.size).to eq 1
            expect(result.drivers.first).to eq ca_ny
          end
        end
      end

      it 'should send push notifications' do
        expect(Push::Generator).to receive(:call).with({
          users: [ca_kiev],
          notification: :new_order,
          order: order
        }).once
        Drivers::Finder.call(order: order, certified: true, distance: 100)
      end
    end

    context 'without address' do
      it 'should return' do
        order.seller.update(address: nil)
        expect(Push::Send).not_to receive(:call)
        Drivers::Finder.call(order: order)
      end
    end
  end
end
