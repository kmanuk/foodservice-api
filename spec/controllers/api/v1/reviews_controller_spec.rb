require 'rails_helper'

RSpec.describe Api::V1::ReviewsController, type: :controller do
  render_views
  json

  let(:review_keys) do
    {id: :integer,
     rate: :float,
     message: :string,
     order_id: :integer,
     created_at: :string}
  end

  let(:seller) { create(:seller) }

  context 'when authorized user' do
    login

    describe 'GET #index' do

      before do
        create(:review, reviewer: @user, ratable: seller)
        create_list(:review, 3, ratable: seller)
      end

      it 'returns all reviews for the user' do
        get :index, params: {user_id: seller.id}
        expect(response).to have_http_status(:success)
        expect_json_sizes('data.reviews', 4)
        expect_json_types('data.reviews.*', review_keys)
      end

      it 'returns not found if user does not exist' do
        get :index, params: {user_id: 0}
        expect(response).to have_http_status(404)
      end


    end

    describe 'GET #show' do


      let(:review) { create(:review, reviewer: @user, ratable: seller) }

      it 'returns review for the user' do
        get :show,  params: {user_id: seller.id , id: review.id}
        expect(response).to have_http_status(:success)
        expect_json_types('data.review', review_keys)
        expect_json('data.review', rate: review[:rate], message: review[:message])
        expect_json('data.review.user',
                    name: seller[:name],
                    email: seller[:email]
        )
        expect_json('data.review.reviewer',
                    name: @user[:name],
                    email: @user[:email]
        )
      end

      it 'returns not found if user does not exist' do
        get :show, params: {user_id: 999, id: review.id}
        expect(response).to have_http_status(404)
      end

      it 'returns not found if review does not exist' do
        get :show, params: {user_id: seller.id, id: 999}
        expect(response).to have_http_status(404)
      end
    end

    describe 'POST #create' do
      let(:order) { create(:order) }

      it 'should create review of seller by buyer' do
        post :create, params: {user_id: seller.id, review: {rate: 5, message: 'Nice', order_id: order.id}}
        expect(response).to have_http_status(201)
        expect(seller.reviews.last[:status]).to eq(seller.role)
        expect(seller.reviews.last[:status]).to eq('seller')
        expect_json_types('data.review', review_keys)
        expect_json('data.review', rate: 5, message: 'Nice', order_id: order.id)
        expect_json('data.review.user',
                    name: seller[:name],
                    email: seller[:email]
        )
        expect_json('data.review.reviewer',
                    name: @user[:name],
                    email: @user[:email]
        )
      end

      it 'should create review and set correct associations' do
        expectation = expect {
          post :create, params: {user_id: seller.id, review: {rate: 5, message: 'Nice', order_id: order.id}}
        }
        expectation.to change(seller.reviews, :count)
        expectation.to change(@user.reviews_written, :count)
      end

      it 'should not create review if user not found' do
        post :create, params: {user_id: 999, review: {rate: 5, message: 'Nice'}}
        expect(response).to have_http_status(404)
      end

      it 'should not create review with wrong params' do
        post :create, params: {user_id: seller.id, review: {rate: 10, message: 'Super Nice'}}
        expect(response).to have_http_status(422)
        expect(json['errors']).to include 'Rate must be less than or equal to 5'
      end
    end
  end
end
