require 'rails_helper'

RSpec.describe Api::V1::ItemsController, type: :controller do
  render_views
  json

  let(:item_keys) do
    {id: :integer, sub_category_id: :integer, category_id: :integer, product_type_id: :integer, information: :string, price: :float, amount: :integer, time_to_cook: :float, type: :string, name: :string, total_price: :float, sub_category_title: :string}
  end

  let(:address_keys) do
    {id: :integer, location: :string, latitude: :float, longitude: :float}
  end

  let(:users_keys) do
    {id: :integer, email: :string, name: :string, quickblox_user_id: :integer}
  end

  let(:sellers_keys) do
    users_keys.merge({recommended_seller: :boolean, av_rate: :float_or_null, reviews: :integer, business_name: :string_or_null, video_snapshot_url: :string_or_null, video_url: :string_or_null})
  end


  let!(:kitchen) { create(:product_type, en: 'Kitchen') }
  let!(:farms) { create(:product_type, en: 'Farms') }

  let!(:drinks) { create(:category, en: 'Drinks', product_type: kitchen) }
  let!(:breakfast) { create(:category, en: 'Breakfast', product_type: kitchen) }
  let!(:soups_and_salads) { create(:category, en: 'Soups and Salads', product_type: farms) }

  let!(:cold_drinks) { create(:sub_category, en: 'Cold Drink', category: drinks) }
  let!(:egg_dishes) { create(:sub_category, en: 'Egg dishes', category: breakfast) }
  let!(:vegetarian) { create(:sub_category, en: 'Vegetarian salads', category: soups_and_salads) }

  def expect_filter(params_value, expected_amount, controll_param)
    expect(response).to have_http_status(:ok)
    expect_json_sizes('data.items', expected_amount)
    expect_json('data.items.*', controll_param => params_value)
  end

  context 'when unauthorized user' do

    it_behaves_like 'render 401', :post, :create
    it_behaves_like 'render 401', :put, :update, params: {id: 1}
    it_behaves_like 'render 401', :delete, :destroy, params: {id: 1}


    describe 'GET #index' do

      let(:seller_1) { create(:seller) }
      let(:seller_2) { create(:seller) }



      it 'returns all items with correct fields, except items with amount 0' do
        create_list(:item, 3, user: seller_1, sub_category: cold_drinks, category: drinks, product_type: kitchen)
        create_list(:fast_created_item, 2, amount: 0, user: seller_2, sub_category: cold_drinks, category: drinks)

        get :index
        expect(response).to have_http_status(:success)
        expect_json_sizes('data.items', 3)
        expect_json_types('data.items.*', item_keys)
        expect_json_types('data.items.*.seller', users_keys)
        expect_json_types('data.items.*.seller.address', address_keys)
      end

      context 'Filters and Pagination' do
        before do
          create_list(:fast_created_item, 2, user: seller_1, sub_category: cold_drinks, category: drinks, product_type: kitchen, type: 'live')
          create_list(:fast_created_item, 2, :free_item, user: seller_1, sub_category: egg_dishes, category: breakfast, product_type: kitchen)

          create_list(:fast_created_item, 3, :preorder_item, user: seller_2, sub_category: cold_drinks, category: drinks)
          create_list(:fast_created_item, 3, user: seller_2, sub_category: egg_dishes, category: breakfast, type: 'live')
        end


        it 'should add pagination' do
          get :index, params: {page: 2, limit: 2}
          expect(response).to have_http_status(:success)
          expect_json_sizes('data.items', 2)
          expect_json('data.pagination', page: 2, limit: 2, total: 10, total_pages: 5)
        end


        context 'with filter[category]' do
          it 'returns items for selected category' do
            get :index, params: {filter: {category: drinks.id}}
            expect_filter(drinks.id, 5, :category_id)
          end
        end

        context 'with filter[search]' do
          it 'returns items whose names contain the query' do
            create(:item, name: 'ItemTestName')
            create(:item, name: 'ItemTest')
            get :index, params: {filter: {search: 'ItemTest'}}
            expect_json_sizes('data.items', 2)
          end
        end

        context 'with filter[product_type]' do
          it 'returns items for selected product_type' do
            get :index, params: {filter: {product_type: kitchen}}
            expect_filter(kitchen.id, 4, :product_type_id)
          end
        end


        context 'with filter[sub_category]' do
          it 'returns items for selected sub_category' do
            get :index, params: {filter: {sub_category: cold_drinks.id}}
            expect_filter(cold_drinks.id, 5, :sub_category_id)
          end
        end

        context 'with filter[type]' do

          it 'returns only live items' do
            get :index, params: {filter: {type: ['live']}}
            expect_filter('live', 5, :type)
          end

          it 'returns only free items' do
            get :index, params: {filter: {type: ['free']}}
            expect_filter('free', 2, :type)
          end

          it 'returns only preorder items' do
            get :index, params: {filter: {type: ['preorder']}}
            expect_filter('preorder', 3, :type)
          end

        end

        context 'with filter[sellers_rate]' do

          before do
            create(:review, ratable: seller_1, rate: 5)
            create(:review, ratable: seller_1, rate: 3)
            #average rate for seller_1 is 4.0

            create(:review, ratable: seller_2, rate: 5)
            create(:review, ratable: seller_2, rate: 3)
            create(:review, ratable: seller_2, rate: 2)
            #average rate for seller_2 is 3.3
          end

          it 'returns items of sellers with rate more or equal than 3' do
            get :index, params: {filter: {sellers_rate: 3}}
            expect(response).to have_http_status(:ok)
            expect_json_sizes('data.items', 10)
          end

          it 'returns items of sellers with rate more or equal than 4' do
            get :index, params: {filter: {sellers_rate: 4}}
            expect(response).to have_http_status(:ok)
            expect_json_sizes('data.items', 4)
            expect_json('data.items.*.seller', id: seller_1.id)
          end

        end

        context 'with filter[seller]' do
          it 'returns items for selected seller only' do
            get :index, params: {filter: {seller: seller_1.id}}
            expect(response).to have_http_status(:ok)
            expect_json_sizes('data.items', 4)
            expect_json('data.items.*.seller', id: seller_1.id)
          end
        end


        context 'with filter[location]' do
          it 'returns items by location' do
            ActionController::Parameters.permit_all_parameters = true
            params = ActionController::Parameters.new(
                bottom_left_latitude: '1', bottom_left_longitude: '2', top_right_latitude: '3', top_right_longitude: '4'
            )
            ActionController::Parameters.permit_all_parameters = false

            expect(Item).to receive(:with_location).with(params).and_return(Item.all)
            get :index, params: {filter: {location: {bottom_left_latitude: '1', bottom_left_longitude: '2', top_right_latitude: '3', top_right_longitude: '4'}}}

            expect(response).to have_http_status(:ok)
            expect_json_sizes('data.items', 10)
          end
        end

      end





    end

    describe 'GET #last_item' do

      before do
        create_list(:item, 3)
        create(:item, name: 'ItemOne')
        create_list(:item, 2)
      end

      it 'returns last item on the page' do
        get :last_item, params: {page: 2, limit: 2}
        expect(response).to have_http_status(:success)
        expect_json('data.item', name: 'ItemOne')
        expect_json_types('data.item', item_keys)
      end

    end

    describe 'GET #preorder_items' do

      let(:seller_1) { create(:seller) }
      let(:seller_2) { create(:seller, :recommended) }
      let(:seller_3) { create(:seller) }
      let(:seller_4) { create(:seller) }
      let(:seller_5) { create(:seller) }

      before do
        create_list(:item, 2, user: seller_1, sub_category: cold_drinks, category: drinks, product_type: kitchen)
        create_list(:item, 2, :free_item, user: seller_1, sub_category: egg_dishes, category: breakfast, product_type: kitchen)

        create_list(:item, 3, :preorder_item, user: seller_2, sub_category: cold_drinks, category: drinks, product_type: kitchen)
        create_list(:item, 3, user: seller_2, sub_category: egg_dishes, category: breakfast)

        create_list(:item, 2, user: seller_3, sub_category: cold_drinks, category: drinks)
        create_list(:item, 3, :preorder_item, user: seller_3, sub_category: egg_dishes, category: breakfast)

        create(:item, :preorder_item, user: seller_4, sub_category: cold_drinks, category: drinks)
        create(:item, user: seller_4, sub_category: egg_dishes, category: breakfast)
      end

      it 'returns sellers that have preorder items' do
        get :preorder_items
        expect(response).to have_http_status(:success)
        expect_json_sizes('data.sellers', 3)
        expect_json_types('data.sellers.*', sellers_keys)
        expect_json('data.sellers.0', id: seller_2.id, recommended_seller: true)

        expect_json_types('data.sellers.*.address', address_keys)
      end

      it 'should add pagination' do
        get :preorder_items, params: {page: 2, limit: 1}
        expect(response).to have_http_status(:success)
        expect_json_sizes('data.sellers', 1)
        expect_json('data.pagination', page: 2, limit: 1, total: 3, total_pages: 3)
      end

      context 'with filter[category]' do
        it 'returns items for selected category' do

          get :preorder_items, params: {filter: {category: drinks.id}}
          expect(response).to have_http_status(:ok)
          expect_json_sizes('data.sellers', 2)
          expect_json_types('data.sellers.*', users_keys)

        end
      end

      context 'with filter[product_type]' do
        it 'returns items for selected product_type' do
          get :preorder_items, params: {filter: {product_type: kitchen}}
          expect(response).to have_http_status(:ok)
          expect_json_sizes('data.sellers', 1)
          expect_json_types('data.sellers.*', users_keys)
        end
      end

      context 'with filter[sub_category]' do
        it 'returns items for selected sub_category' do
          get :preorder_items, params: {filter: {sub_category: cold_drinks.id}}
          expect(response).to have_http_status(:ok)
          expect_json_sizes('data.sellers', 2)
          expect_json_types('data.sellers.*', users_keys)
        end
      end

      context 'with filter[sellers_rate]' do

        before do
          create(:review, ratable: seller_3, rate: 5)
          create(:review, ratable: seller_3, rate: 3)
          #average rate for seller_1 is 4.0

          create(:review, ratable: seller_2, rate: 5)
          create(:review, ratable: seller_2, rate: 3)
          create(:review, ratable: seller_2, rate: 2)
          #average rate for seller_2 is 3.3
        end

        it 'returns sellers with rate more or equal than 3' do
          get :preorder_items, params: {filter: {sellers_rate: 3}}
          expect(response).to have_http_status(:ok)
          expect_json_sizes('data.sellers', 2)
        end

        it 'returns items of sellers with rate more or equal than 4' do
          get :preorder_items, params: {filter: {sellers_rate: 4}}
          expect(response).to have_http_status(:ok)
          expect_json_sizes('data.sellers', 1)
        end

      end

      context 'with filter[location]' do
        it 'returns items by location' do
          ActionController::Parameters.permit_all_parameters = true
          params = ActionController::Parameters.new(
              bottom_left_latitude: '1', bottom_left_longitude: '2', top_right_latitude: '3', top_right_longitude: '4'
          )
          ActionController::Parameters.permit_all_parameters = false

          expect(Item).to receive(:with_location).with(params).and_return(Item.all)
          get :preorder_items, params: {filter: {location: {bottom_left_latitude: '1', bottom_left_longitude: '2', top_right_latitude: '3', top_right_longitude: '4'}}}

          expect(response).to have_http_status(:ok)
          expect_json_sizes('data.sellers', 4)
          expect_json_types('data.sellers.*', users_keys)
        end
      end


    end

    describe 'GET #show' do

      let(:seller) { create(:seller) }
      let(:item) { create(:item, user: seller) }

      it 'returns item by ID ' do
        get :show, params: {id: item.id}
        expect(response).to have_http_status(:success)
        expect_json_types('data.item', item_keys)
        expect_json_types('data.item.seller', users_keys)
        expect_json_types('data.item.seller.address', address_keys)
      end

      it 'returns not found if item does not exist' do
        get :show, params: {id: 9999}
        expect(response).to have_http_status(404)
      end

    end

  end

  context 'when authorized user' do

    describe 'GET #index' do

      login

      before do
        create_list(:item, 2, user: @user)
        create_list(:item, 2)
      end

      it 'returns all items except created by current user' do
        get :index
        expect(response).to have_http_status(:success)
        expect_json_sizes('data.items', 2)
        expect(Item.count).to eq(4)
      end


    end

    describe 'GET #seller_items' do
      let(:seller) { create(:seller) }

      context 'As buyer or driver' do
        login

        it 'returns only for Sellers' do
          create_list(:item, 3, user: seller)
          get :seller_items
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json['errors']).to include 'Only for sellers'
        end
      end

      context 'As seller' do

        login_seller

        before do
          create_list(:item, 3, user: @user, sub_category: cold_drinks, category: drinks, product_type: kitchen)
          create_list(:item, 2, :free_item, user: @user, sub_category: cold_drinks, category: drinks, product_type: kitchen)

          create(:item, :preorder_item, user: @user, sub_category: egg_dishes, category: breakfast)
          create(:item, :preorder_item, user: @user, sub_category: vegetarian, category: soups_and_salads)

          create(:item, sub_category: egg_dishes, category: breakfast)
          create(:item, :free_item, sub_category: cold_drinks, category: drinks)
          create(:item, :preorder_item, sub_category: vegetarian, category: soups_and_salads)
        end

        it 'returns a list of items for the seller ' do
          get :seller_items
          expect(response).to have_http_status(200)
          expect_json_sizes('data.items', 7)
          expect_json_types('data.items.*', item_keys)
        end


        it 'returns all items including amount 0' do
          create_list(:fast_created_item, 2, amount: 0, user: @user, sub_category: cold_drinks, category: drinks)
          get :seller_items
          expect(response).to have_http_status(:success)
          expect_json_sizes('data.items', 9)
        end

        it 'should add pagination' do
          get :seller_items, params: {page: 2, limit: 2}
          expect(response).to have_http_status(:success)
          expect_json_sizes('data.items', 2)
          expect_json('data.pagination', page: 2, limit: 2, total: 7, total_pages: 4)
        end


        context 'with filter[category]' do
          it 'returns items for selected category' do
            get :seller_items, params: {filter: {category: drinks.id}}
            expect_filter(drinks.id, 5, :category_id)
          end
        end

        context 'with filter[product_type]' do
          it 'returns items for selected product_type' do
            get :seller_items, params: {filter: {product_type: kitchen}}
            expect_filter(kitchen.id, 5, :product_type_id)
          end
        end


        context 'with filter[sub_category]' do
          it 'returns items for selected sub_category' do
            get :seller_items, params: {filter: {sub_category: cold_drinks.id}}
            expect_filter(cold_drinks.id, 5, :sub_category_id)
          end
        end


        context 'with filter[type]' do

          it 'returns only live items' do
            get :seller_items, params: {filter: {type: ['live']}}
            expect_filter('live', 3, :type)
          end

          it 'returns only free items' do
            get :seller_items, params: {filter: {type: ['free']}}
            expect_filter('free', 2, :type)
          end

          it 'returns only preorder items' do
            get :seller_items, params: {filter: {type: ['preorder']}}
            expect_filter('preorder', 2, :type)
          end
        end

      end
    end

    describe 'POST #create' do
      login_seller

      it 'should create item' do
        attributes = build(:item, name: 'Chicken Soup', price: 99.99).attributes
        post :create, params: {item: attributes}

        expect(response).to have_http_status(201)
        expect(@user.items.count).to eq 1
        expect(@user.items.last.price).to eq 99.99
        expect_json_types('data.item', item_keys)
        expect_json('data.item', price: 99.99)
        expect_json('data.item', name: 'Chicken Soup')
      end

      it 'should assign image' do
        attributes = build(:item, name: 'Chicken Soup', price: 99.99).attributes.merge(image_attributes: attributes_for(:image))
        post :create, params: {item: attributes}

        item = @user.items.first
        expect(response).to have_http_status(201)
        expect_json_types('data.item', url: :string, thumb: :string)
        expect(item.image).not_to be_nil
      end

      it 'should not create item with wrong params' do
        attributes = attributes_for(:item, sub_category_id: nil)
        post :create, params: {item: attributes}

        expect(response).to have_http_status(422)
        expect(@user.items.count).to eq 0
        expect(json['errors']).to include 'Sub category must exist'
      end
    end

    describe 'PUT #update' do
      login_seller

      let(:item) { create(:item, user: @user, price: 99.99) }

      it 'should update item' do
        put :update, params: {id: item, item: {name: 'Vegetable Soup', price: 10}}

        expect(response).to have_http_status(200)
        expect(@user.items.last.price).to eq 10
        expect_json_types('data.item', item_keys)
        expect_json('data.item', price: 10)
        expect_json('data.item', name: 'Vegetable Soup')
      end

      it 'should create new image record' do
        image = item.image

        expectation = expect {
          put :update, params: {id: item, item: {image_attributes: attributes_for(:image)}}
        }
        expectation.to change(Image, :count)
        expect(item.reload.image).not_to be_nil
        expect(item.reload.image.id).not_to eq image.id
      end

      it 'should not clear old image' do
        image = item.image

        expectation = expect {
          put :update, params: {id: item, item: {name: 'Vegetable Soup'}}
        }
        expectation.not_to change(Image, :count)

        expect(response).to have_http_status(200)
        expect(item.image).not_to be_nil
        expect(item.image.id).to eq image.id
      end

      it 'should not update item with wrong params' do
        put :update, params: {id: item, item: {sub_category_id: nil}}

        expect(response).to have_http_status(422)
        expect(json['errors']).to include 'Sub category must exist'
      end

      it 'should update only user items' do
        put :update, params: {id: create(:item)}

        expect(response).to have_http_status(404)
      end
    end

    describe 'DELETE #destroy' do
      login_seller

      let!(:item) { create(:fast_created_item, user: @user) }

      it 'should delete item' do
        delete :destroy, params: {id: item}

        expect(response).to have_http_status(204)
        expect(@user.items.count).to eq 0
      end

      it 'should not delete image' do
        expectation = expect {
          delete :destroy, params: {id: item}
        }
        expectation.not_to change(Image, :count)

        expect(response).to have_http_status(204)
      end

      it 'should delete only user items' do
        delete :destroy, params: {id: create(:item)}

        expect(response).to have_http_status(404)
      end
    end
  end
end
