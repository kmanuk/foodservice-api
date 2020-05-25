ActiveAdmin.register Order do
  menu :label => 'Orders', :priority => 8

  actions :all, :except => [:new, :create, :destroy]
  config.clear_action_items!
  batch_action  :destroy, false

  permit_params :status

  config.comments = false

  filter :id
  filter :type, as: :select, collection: Order.types
  filter :status, as: :select, collection: Order.statuses
  filter :delivery_type, label: 'Delivery', as: :select, collection: Order.delivery_types
  filter :payment_type, label: 'Payment', as: :select, collection: Order.payment_types
  filter :payment_status, label: 'Payment Status', as: :select, collection: proc { Payment.statuses }

#  filter :driver, label: 'Driver', as: :select, collection: proc { User.drivers.pluck :name, :id }
#  filter :seller, label: 'Seller', as: :select, collection: proc { User.sellers.pluck :name, :id }

  index :download_links => false do
    selectable_column
    id_column
    column 'Seller' do |order|
      link_to order.seller.name, admin_seller_path(order.seller)
    end

    column 'Buyer' do |order|
      link_to order.buyer.name, admin_buyer_path(order.buyer)
    end

    column 'Driver' do |order|
      link_to order.driver.name, admin_driver_path(order.driver) if order.driver
    end

    column :status
    column :type

    column 'Delivery' do |order|
      order.delivery_type
    end


    column :price

    column :fee_price

    column :service_fee

    column :delivery_price

    column :global_price

    column 'Payment Type' do |order|
      if order.payment_type == 'card'
        order.payment ? link_to(order.payment_type, admin_payment_path(order.payment.id)) : order.payment_type
      else
        order.payment_type
      end
    end

    column :paid

    column 'Payment Status' do |order|
      order.payment.status if order.payment
    end

    actions dropdown: true


#    actions
  end

  show do
    attributes_table do
      row :id

      row 'Seller' do |order|
        link_to order.seller.name, admin_seller_path(order.seller)
      end

      row 'Buyer' do |order|
        link_to order.buyer.name, admin_buyer_path(order.buyer)
      end

      row 'Driver' do |order|
        link_to order.driver.name, admin_driver_path(order.driver) if order.driver
      end

      row :status

      row :type

      row 'Delivery' do |order|
        order.delivery_type
      end


      row :price
      row :fee_price
      row :service_fee
      row :delivery_price
      row :global_price
      row :address do |order|
        order.address.location if order.address
      end

      row 'Payment Type' do |order|
        if order.payment_type == 'card'
          order.payment ? link_to(order.payment_type, admin_payment_path(order.payment.id)) : order.payment_type
        else
          order.payment_type
        end
      end

      row :paid


      row 'Payment Status' do |order|
        order.payment.status if order.payment
      end

      row :created_at
      # do |obj|
      #   obj.created_at.localtime.strftime("%B %d, %Y %H:%M")
      # end


    end
  end

  form do |f|
    f.semantic_errors # shows errors on :base
    f.inputs do
      f.input :status, include_blank: false, as: :select, collection: f.object.possible_statuses_with_cancel
    end
    f.actions
  end

  controller do
    def scoped_collection
      super.includes :driver, :seller, :buyer
    end
  end
end
