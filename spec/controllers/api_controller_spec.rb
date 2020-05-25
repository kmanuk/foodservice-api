require 'rails_helper'

RSpec.describe ApiController, type: :controller do
  json

  describe '#pagination' do
    controller do
      def index
        pagination(1, 2, 3, 4)
      end
    end

    it 'should create pagination object' do
      get :index
      expect(assigns(:pagination)).to eq(OpenStruct.new(
        page: 1,
        limit: 2,
        total: 3,
        total_pages: 4
      ))
    end
  end

  describe '#sanitize_params' do
    controller do
      def index
        @p = sanitize_params
        render nothing: true
      end
    end

    it 'should return underscored params' do
      get :index, someKey: { someNewKey: 'value' }, arrayKey: [{valueOne: '1'}]
      params = {
        'array_key' => [{ 'value_one' => '1' }],
        'some_key' => { 'some_new_key' => 'value' },
        'controller' => 'api',
        'action' => 'index'
      }
      expect(assigns(:p).to_hash).to eq params
    end
  end

  describe '#render_errors' do
    before do
      allow_any_instance_of(Item).to receive_message_chain(:errors, :full_messages).and_return(['Error', 'Error2'])
    end

    controller do
      def index
        object = Item.new
        if params[:errors]
          render_errors nil, params[:errors]
        elsif params[:status]
          render_errors object, nil, params[:status]
        else
          render_errors object
        end
      end
    end

    it 'should return JSON with object errors' do
      get :index
      expect(json['errors']).to eq ['Error', 'Error2']
    end

    it 'should return JSON with errors from arguments' do
      get :index, errors: ['One', 'Two']
      expect(json['errors']).to eq ['One', 'Two']
    end

    it 'should wrap errors from params' do
      get :index, errors: 'One'
      expect(json['errors']).to eq ['One']
    end

    it 'should return status' do
      get :index, status: 201
      expect(response).to have_http_status(:created)
    end

    it 'should return status 422 by default' do
      get :index
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe '#render_success' do
    controller do
      def index
        if params[:status]
          render_success params[:data], params[:status]
        elsif params[:data]
          render_success params[:data]
        else
          render_success
        end
      end
    end

    it 'should return JSON with data' do
      get :index, data: 'data text'
      expect(json['data']).to eq 'data text'
    end

    it 'should return status' do
      get :index, data: 'data text', status: 201
      expect(response).to have_http_status(:created)
    end

    it 'should return status 200 by default' do
      get :index, data: 'data text'
      expect(response).to have_http_status(:ok)
    end

    it 'should return empty data by default' do
      get :index
      expect_json(data: {})
    end
  end
end
