require 'rails_helper'

RSpec.describe Api::V1::PushNotificationsController, type: :controller do
  context 'when unauthorized user' do
    it_behaves_like 'render 401', :post, :index
    it_behaves_like 'render 401', :get, :reset
  end

  context 'when authorized user' do
    login

    describe 'POST #index' do
      let(:user) { create(:user) }
      let(:order) { create(:order) }

      context 'without errors' do
        let(:order) { create(:order, seller: user, driver: @user) }

        it 'should send push notification' do
          params = {
              alert: 'Hello',
              category: '55',
              unpermitted: 123
          }

          expect(Push::Send).to receive(:call).with({
                                                        user: user,
                                                        options: {
                                                            alert: 'Hello',
                                                            category: '55'
                                                        }
                                                    }).once
          post :index, params: {user_id: user.id, order_id: order.id, notification: params}
          expect(response).to have_http_status(200)
          expect_json(data: {})
        end

        it 'should permit keys in custom_data' do
          params = {
              alert: 'Hello',
              category: '55',
              unpermitted: 123,
              custom_data: {
                  key: 'value'
              }
          }

          expect(Push::Send).to receive(:call).with({
                                                        user: user,
                                                        options: {
                                                            alert: 'Hello',
                                                            category: '55',
                                                            custom_data: {
                                                                key: 'value'
                                                            }
                                                        }
                                                    }).once
          post :index, params: {user_id: user.id, order_id: order.id, notification: params}
          expect(response).to have_http_status(200)
        end
      end

      context 'with errors' do
        it 'should render 404 if can not find user' do
          post :index, params: {user_id: 1}
          expect(response).to have_http_status(404)
        end

        it 'should render 404 if can not find order' do
          post :index, params: {user_id: user.id, order_id: 1}
          expect(response).to have_http_status(404)
        end

        it 'should render 404 if can not find current user in order' do
          post :index, params: {user_id: user.id, order_id: order.id}
          expect(response).to have_http_status(404)
        end

        it 'should render 404 if can not find selected user in order' do
          order = create(:order, seller: @user)
          post :index, params: {user_id: user.id, order_id: order.id}
          expect(response).to have_http_status(404)
        end
      end
    end


    describe 'GET #reset' do

      before do
        @user.update(push_count_orders: 2, push_count_messages: 4)
      end

      it 'should change push_count_orders and push_count_messages for user' do
        get :reset
        expect(response).to have_http_status(200)
        expect(@user.reload.push_count_orders).to eq(0)
        expect(@user.reload.push_count_messages).to eq(0)
      end

      it 'should change push_count_orders for user' do
        expect { get :reset, {type: 'push_count_orders'} }.to change { @user.push_count_orders }.by(0)
      end

      it 'should change push_count_messages for user' do
        expect { get :reset, {type: 'push_count_messages'} }.to change { @user.push_count_messages }.by(0)
      end

      it 'should return success' do
        get :reset, {type: 'push_count_messages'}
        expect(response).to have_http_status(200)
      end

      it 'should return error if cannot save user' do
        allow_any_instance_of(User).to receive(:update).and_return(false)
        get :reset, {type: 'push_count_messages'}
        expect(response).to have_http_status(:unprocessable_entity)
      end

    end
  end
end
