require 'rails_helper'

RSpec.describe Api::V1::OrdersController, type: :controller do
  render_views
  json

  let(:order_keys) do
    {
        id: :integer,
        status: :string,
        delivery_type: :string,
        type: :string,
        payment_type: :string,
        distance: :integer,
        duration: :integer,
        price: :float,
        fee_price: :float,
        total_price: :float,
        service_fee: :float,
        delivery_price: :float,
        global_price: :float,
        polyline: :string,
        created_at: :string,
        possible_statuses: :array,
        review: :boolean
    }
  end


  let(:users_keys) do
    {
        id: :integer,
        email: :string,
        name: :string,
        quickblox_user_id: :integer,
        avatar_url: :string,
        avatar_thumb: :string,
        role: :string
    }
  end

  let(:payment_keys) do
    {

        "3ds_url" => :string
    }
  end


  let(:drivers_keys) do
    users_keys.merge({active_driver: :boolean})
  end

  let(:address_keys) do
    {id: :integer, location: :string, latitude: :float, longitude: :float}
  end


  context 'when unauthorized user' do
    it_behaves_like 'render 401', :get, [:index, :show, :waiting_for_driver, :calculate, :change_status, :cancel], id: 1
    it_behaves_like 'render 401', :post, :create
  end


  context 'when authorized user' do
    login

    let(:seller) { create(:seller) }
    let(:driver) { create(:driver) }
    let(:buyer_2) { create(:user) }


    let(:item1) { create(:item, user_id: seller.id, name: 'Soup', price: 3.0, time_to_cook: 50) }
    let(:item2) { create(:item, user_id: seller.id, name: 'Chicken', price: 5.0, time_to_cook: 20) }
    let(:address) { attributes_for(:address) }
    let(:payment_data) { {card_number: '400555******0001',
                          expiry_date: 1705,
                          merchant_reference: 't1cxek7lmxphhttn',
                          token_name: '4CD11754C2DD6B70E053321E320A24D4',
                          card_holder_name: 'Jonh Test',
                          ip_address: '8.8.8.8'} }

    describe 'GET #index' do
      context 'when authorized user buyer' do
        before do
          create_list(:order, 2, :with_payment_paid, buyer: @user, seller: seller, driver: driver)
          create(:order, :by_cash, buyer: @user, seller: seller, driver: driver, status: 'delivered', paid: true)
          create_list(:order, 2, buyer: buyer_2, seller: @user, driver: driver)
        end

        it 'returns his orders as buyer' do
          get :index
          expect(response).to have_http_status(:success)
          expect_json_sizes('data.orders', 3)
          expect_json_types('data.orders.*', order_keys)
          expect_json_types('data.orders.*.seller', users_keys)
          expect_json_types('data.orders.*.buyer', users_keys)
          expect_json_types('data.orders.*.address', address_keys)
        end

        it 'does not return unpaid orders' do
          create(:order, :with_payment_canceled, seller: seller, buyer: @user)
          create(:order, :with_payment_3ds_required, seller: seller, buyer: @user)
          create(:order, :with_payment, seller: seller, buyer: @user)
          get :index
          expect(response).to have_http_status(:success)
          expect_json_sizes('data.orders', 3)
        end

        it 'should add pagination' do
          get :index, params: {page: 2, limit: 2}
          expect(response).to have_http_status(:success)
          expect_json_sizes('data.orders', 1)
          expect_json('data.pagination', page: 2, limit: 2, total: 3, total_pages: 2)
        end

        context 'with filter[active]' do
          it 'returns his active orders' do
            create(:order, :with_payment_paid, buyer: @user, seller: seller, driver: driver, status: 'ready')
            create(:order, buyer: @user, seller: seller, driver: driver, status: 'canceled')
            create(:order, buyer: @user, seller: seller, driver: driver, status: 'delivered')
            get :index, params: {filter: {active: true}}
            expect(response).to have_http_status(:ok)
            expect_json_sizes('data.orders', 1)
          end
        end
      end

      context 'when authorized user driver' do
        login_driver

        before do
          create_list(:order, 4, :with_payment_paid, driver: @user)
          create_list(:order, 2, :with_payment_paid, driver: driver, buyer: @user)
        end

        it 'returns his orders as driver' do
          get :index
          expect(response).to have_http_status(:success)
          expect_json_sizes('data.orders', 4)
          expect_json_types('data.orders.*.driver', drivers_keys)
          expect_json_types('data.orders.*.address', address_keys)
        end

        it 'does not return unpaid orders' do
          create(:order, :with_payment_canceled, driver: @user, seller: seller, buyer: buyer_2)
          create(:order, :with_payment_3ds_required, driver: @user, seller: seller, buyer: buyer_2)
          create(:order, :with_payment, driver: @user, seller: seller, buyer: buyer_2)
          get :index
          expect(response).to have_http_status(:success)
          expect_json_sizes('data.orders', 4)
        end

        it 'should add pagination' do
          get :index, params: {page: 1, limit: 2}
          expect(response).to have_http_status(:success)
          expect_json_sizes('data.orders', 2)
          expect_json('data.pagination', page: 1, limit: 2, total: 4, total_pages: 2)
        end

        context 'with filter[active]' do
          it 'returns his active orders' do
            create(:order, :with_payment_paid, driver: @user, status: 'ready')
            create(:order, driver: @user, status: 'canceled')
            create(:order, driver: @user, status: 'delivered')
            get :index, params: {filter: {active: true}}
            expect(response).to have_http_status(:ok)
            expect_json_sizes('data.orders', 1)
          end
        end

      end

      context 'when authorized user seller' do
        login_seller

        before do
          create_list(:order, 2, :with_payment_paid, :on_the_way, seller: @user, created_at: Time.now - 2.days)
          create_list(:order, 3, :with_payment_paid, buyer: @user, seller: seller)
        end

        it 'returns his orders as seller' do
          get :index
          expect(response).to have_http_status(:success)
          expect_json_sizes('data.orders', 2)
        end

        it 'does not return unpaid orders' do
          create(:order, :with_payment_canceled, seller: @user, buyer: buyer_2)
          create(:order, :with_payment_3ds_required, seller: @user, buyer: buyer_2)
          create(:order, :with_payment, seller: @user, buyer: buyer_2)

          get :index
          expect(response).to have_http_status(:success)
          expect_json_sizes('data.orders', 2)
        end


        it 'should add pagination' do
          get :index, params: {page: 1, limit: 2}
          expect(response).to have_http_status(:success)
          expect_json_sizes('data.orders', 2)
          expect_json('data.pagination', page: 1, limit: 2, total: 2, total_pages: 1)
        end

        context 'with filter[active]' do
          it 'returns his active orders' do
            create(:order, seller: @user, status: 'canceled')
            create(:order, seller: @user, status: 'delivered')
            get :index, params: {filter: {active: true}}
            expect(response).to have_http_status(:ok)
            expect_json_sizes('data.orders', 2)
          end
        end

        context 'with filter[current]' do

          before(:each) do
            create(:order, :with_payment_paid, seller: @user, created_at: Time.now - 14.hours)
          end

          it 'returns his orders for the last 24 hours' do
            get :index, params: {filter: {current: 'true'}}
            expect(response).to have_http_status(:ok)
            expect_json_sizes('data.orders', 1)
          end


        end

        context 'with filter[status]' do
          it 'returns his orders with status = on_the_way' do
            create_list(:order, 3, :with_payment_paid, :cooking, seller: @user)
            get :index, params: {filter: {status: 'on_the_way'}}
            expect(response).to have_http_status(:ok)
            expect(@user.orders.count).to eq(5)
            expect_json_sizes('data.orders', 2)
          end
        end

        context 'with filter[sort_by_date]' do
          it 'returns orders in ascending order' do
            create_list(:order, 3, :with_payment_paid, :cooking, :preorder, seller: @user, buyer: @user)
            get :index, params: {filter: {sort_by_id: 'ASC'}}
            expect(response).to have_http_status(:ok)
            expect(json_body[:data][:orders][0][:id]).to be < json_body[:data][:orders][1][:id]
          end

          it 'returns orders in descending order' do
            create_list(:order, 3, :with_payment_paid, :cooking, :preorder, seller: @user, buyer: @user)
            get :index, params: {filter: {sort_by_id: 'DESC'}}
            expect(response).to have_http_status(:ok)
            expect(json_body[:data][:orders][0][:id]).to be > json_body[:data][:orders][1][:id]
          end
        end

        context 'with filter[in_progress]' do
          it 'returns his orders in progress' do
            create(:order, seller: @user, status: 'canceled')
            create(:order, seller: @user, status: 'delivered')
            create(:order, seller: @user)
            get :index, params: {filter: {in_progress: true}}
            expect(response).to have_http_status(:ok)
            expect_json_sizes('data.orders', 2)
            expect_json('data.orders.*', status: 'on_the_way')
          end
        end


      end
    end

    describe 'GET #show' do
      let(:order) { create(:order, buyer: @user) }
      let(:order2) { create(:order, seller: @user) }

      it 'returns order for current role' do
        get :show, params: {id: order.id}
        expect_json_types('data.order', order_keys)
        expect_json_types('data.order.seller.address', address_keys)
        expect(response).to have_http_status(:success)
      end

      it 'does not return his order for another role' do
        get :show, params: {id: order2.id}
        expect(response).to have_http_status(:not_found)
      end
    end

    describe 'GET #waiting_for_driver' do
      before do
        create_list(:order, 2, status: :looking_for_driver, delivery_type: :certified_driver)
        create_list(:order, 3, status: :looking_for_driver)
        create(:order, status: :canceled)
        create(:order, status: :delivered)
      end

      context 'As regular driver' do
        login_driver

        it 'returns only orders with status looking_for_driver and delivery_type: regular_driver' do
          get :waiting_for_driver
          expect(response).to have_http_status(:success)
          expect_json_sizes('data.orders', 3)
        end
      end

      context 'certified driver' do
        login_certified_driver

        it 'returns only orders with status: looking_for_driver' do
          get :waiting_for_driver
          expect(response).to have_http_status(:success)
          expect_json_sizes('data.orders', 5)
        end
      end

      context 'not active_driver' do
        login_driver

        it 'returns error if driver has inactive status' do
          @user.update(active_driver: false)
          get :waiting_for_driver
          expect(response).to have_http_status(:success)
          expect_json_sizes('data.orders', 0)
        end

      end

      context 'not_approved_driver' do
        login_certified_driver

        it 'returns empty array for not_approved_driver ' do
          @user.update(approved_driver: false)
          get :waiting_for_driver
          expect(response).to have_http_status(:success)
          expect_json_sizes('data.orders', 0)
        end
      end


      context 'As buyer or seller' do
        login

        it 'returns error if user is not a driver' do
          get :waiting_for_driver
          expect(response).to have_http_status(:success)
          expect_json_sizes('data.orders', 0)
        end

      end


    end

    describe 'GET #calculate' do
      it 'should call calculator' do
        expect(Orders::Calculator).to receive(:call).with(
            params: ActionController::Parameters.new(key: 'value', controller: 'api/v1/orders', action: 'calculate')
        ).and_return(InteractorStub.new(failed: true, errors: 'Some error'))

        get :calculate, params: {key: 'value'}
      end

      context 'without errors' do
        it 'should return order price' do
          price = OpenStruct.new(
              price: 10,
              total_price: 20,
              fee_price: 5,
              global_price: 25,
              delivery_price: 8,
              service_fee: 2,
              distance: 100,
              duration: 20
          )

          allow(Orders::Calculator).to receive(:call).and_return(InteractorStub.new(options: {price: price}))
          get :calculate

          expect(response).to have_http_status(:success)
          expect_json('data.order', price: 10, total_price: 20, fee_price: 5, global_price: 25, delivery_price: 8, distance: 100, duration: 20, service_fee: 2)
        end
      end

      context 'with errors' do
        it 'should render error' do
          allow(Orders::Calculator).to receive(:call).and_return(InteractorStub.new(failed: true, errors: 'Some error'))
          get :calculate

          expect(response).to have_http_status(422)
          expect(json['errors']).to include 'Some error'
        end
      end
    end

    describe 'GET #change_status' do

      let(:order) { create(:order) }

      before do
        allow(Orders::ChangeStatus).to receive(:call).and_return(InteractorStub.new(options: {order: order}))
      end


      login

      it 'should call Orders::ChangeStatus service with correct params' do
        expect(Orders::ChangeStatus).to receive(:call).with({user: @user, order: order, cooking_time: '60'})
        get :change_status, params: {id: order.id, cooking_time: 60}
        expect(response).to have_http_status(:success)
        expect_json_types('data.order', order_keys)
      end

      it 'returns not found if order doest not exist' do
        get :change_status, params: {id: 9999}
        expect(response).to have_http_status(:not_found)
      end


    end

    describe 'GET #cancel' do

      login

      let(:order) { create(:order) }

      before do
        allow(Orders::Cancel).to receive(:call).and_return(InteractorStub.new(options: {order: order}))
      end

      it 'should call Orders::Cancel service' do
        expect(Orders::Cancel).to receive(:call).with({user: @user, order: order})
        get :cancel, params: {id: order.id}
        expect(response).to have_http_status(:success)
        expect_json_types('data.order', order_keys)
      end

      it 'returns not found if order doest not exist' do
        get :cancel, params: {id: 9999}
        expect(response).to have_http_status(:not_found)
      end


    end

    describe 'POST #create' do

      before(:each) do
        stub_request(:post, 'https://sbpaymentservices.payfort.com/FortAPI/paymentApi').to_return(
            body: D_SECURE_REQUESTED.to_json
        )
      end

      let(:line_items_attributes) { [{item_id: item1.id,
                                      quantity: 1},
                                     {item_id: item2.id,
                                      quantity: 2}] }

      let(:valid_attributes) { {address_attributes: address,
                                payment_attributes: payment_data,
                                line_items: line_items_attributes,
                                delivery_type: 'regular_driver',
                                type: 'live',
                                payment_type: 'card'
      } }

      it 'should call Orders::Create service' do
        order = create(:order)
        payment_result = OpenStruct.new(D_SECURE_REQUESTED)

        expect(Orders::Create).to receive(:call).and_return(InteractorStub.new(options: {order: order, payment_result: payment_result}))
        post :create, params: {order: valid_attributes}
        expect(response).to have_http_status(:success)
        expect_json_types('data.order', order_keys)
      end


      it 'should create order' do
        post :create, params: {order: valid_attributes}
        expect(response).to have_http_status(201)
        expect(@user.orders.count).to eq 1
        expect(@user.orders.first.line_items.count).to eq 2
        expect(@user.orders.first.seller).to eq(seller)
        expect(@user.orders.first.address.location).to eq(address[:location])
        expect(@user.orders.first.address.latitude).to eq(address[:latitude])
        expect(@user.orders.first.address.longitude).to eq(address[:longitude])
      end


      it 'should render correct data after creating' do
        post :create, params: {order: valid_attributes}
        expect_json('data.order', price: 13.0)
        expect_json('data.order', status: 'pending')
        expect_json_types('data.order.seller', users_keys)
        expect_json_types('data.order.buyer', users_keys)
        expect_json_types('data.order', order_keys)
        expect_json('data.order', delivery_type: 'regular_driver', type: 'live')
        expect_json('data.order.line_items.0',
                    name: 'Soup',
                    total_price: '3.3',
                    price: '3.0',
                    time_to_cook: 50.0,
                    url: item1.image.data.url)
        expect_json('data.order.line_items.1',
                    name: 'Chicken',
                    price: '5.0',
                    total_price: '11.0',
                    time_to_cook: 40.0,
                    url: item2.image.data.url)
        expect_json('data.order.address',
                    location: address[:location],
                    latitude: address[:latitude],
                    longitude: address[:longitude]
        )
        expect_json('data.order.driver', nil)

      end

      it 'should retrun 3ds secure URL if payment by card' do
        post :create, params: {order: valid_attributes}
        expect_json('data.payment_result', "3ds_url": 'https://testfort.payfort.com/secure3dsSimulator?FORTSESSIONID=hfsjpjbkhbueu9g6e8a1hfg675&paymentId=5740559166725965820&DOID=C70BAA4D83511CCADAEC071226C925FB&o=pt&action=retry')
      end


      it 'should not create order without items' do
        post :create, params: {order: {address_attributes: address}}
        expect(response).to have_http_status(422)
        expect(json['errors']).to include "Line items can't be blank"
      end


      it 'gives error if cannot save order' do
        allow_any_instance_of(Order).to receive(:save).and_return(false)
        post :create, params: {order: valid_attributes}
        expect(response).to have_http_status(422)
      end

      it 'should not create order without address' do
        post :create, params: {order: {line_items: line_items_attributes
        }}
        expect(response).to have_http_status(422)
        expect(json['errors']).to include 'Address must exist'
      end

    end

  end
end
