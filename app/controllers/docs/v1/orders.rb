module Docs::V1::Orders
  extend Apipie::DSL::Concern

  def_param_group :id do
    param :id, Integer, 'Order ID', required: true
  end

  def_param_group :order do
    param :order, Hash, required: true do
      param :type, [0, 'free', 1, 'live', 2, 'preorder'], '0 -> free, 1 -> live, 2 ->preorder', required: true
      param :payment_type, [0, 'card', 1, 'cash'], required: true
      param :delivery_type, [0, 'self_delivery', 1, 'regular_driver', 2, 'certified_driver'], '0 -> self_delivery, 1 -> regular_driver, 2 -> certified_driver', required: true
      param :line_items_attributes, Array, of: Hash, required: true, desc: 'Array of Items' do
        param :item_id, Integer, desc: "Item's ID", required: true
        param :quantity, Integer
      end
      param :address_attributes, Hash, required: true do
        param :location, String, required: true
        param :latitude, String, required: true
        param :longitude, String, required: true
      end

      param :payment_attributes, Hash do
        param :card_number, String
        param :card_holder_name, String
        param :token_name, String
        param :merchant_reference, String
        param :expiry_date, String
        param :card_bin, String
        param :ip_address, String
      end
    end
  end

  api! 'List of orders'
  param :filter, Hash, 'Search and sort params' do
    param :current, [true, false], "Search by all user's orders where created date not older then 24h ago"
    param :sort_by_id, ['asc', 'desc'], 'Sort by ID (descending order, ascending order)'
    param :active, [true, false], 'Filter users orders where status NOT canceled or delivered'
    param :in_progress, [true, false], 'Filter users orders where status (canceled || delivered || pending)'
    param :status, [0, 1, 2, 3, 4, 5, 6, 7], 'Filter by status
                    0 = pending,
                    1 = canceled,
                    2 = looking_for_driver,
                    3 = cooking,
                    4 = ready,
                    5 = picking_up,
                    6 = on_the_way,
                    7 = delivered'
  end

  def index;
  end

  api! 'Create order'
  param_group :order

  def create;
  end

  api! 'Change status of the order, for the seller and driver'
  param_group :id
  param :cooking_time, Integer, 'Cooking time for the order in minutes (for seller only)'

  def change_status;
  end

  api! 'All orders with status looking_for_driver (for drivers only)'

  def waiting_for_driver;
  end

  api! 'Calculate order price'
  param_group :order

  def calculate;
  end

  api! 'Cancel the order, for the seller and driver'
  param_group :id

  def cancel;
  end

  api! 'Show order'
  param_group :id

  def show;
  end
end
