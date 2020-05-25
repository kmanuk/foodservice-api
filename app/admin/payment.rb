ActiveAdmin.register Payment do
  menu :label => 'Payments', :priority => 9

  actions :all, :except => [:new, :create]
  config.clear_action_items!

  permit_params :status

  config.comments = false
  config.filters = false


  index :download_links => false do
    selectable_column
    id_column

    column 'Order' do |payment|
      link_to payment.order.id, admin_order_path(payment.order)
    end

    column :card_number
    column :card_bin
    column :card_holder_name

    column :merchant_reference
    column :status

    actions defaults: false, dropdown: true do |payment|
      item 'View', admin_payment_path(payment)
    end
  end



  form do |f|
    f.semantic_errors # shows errors on :base
    f.actions
  end


end
