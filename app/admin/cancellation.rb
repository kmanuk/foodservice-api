ActiveAdmin.register Cancellation do
#  actions :all, except: [:destroy]
  menu :label => 'Cancellation', :priority => 10
  actions :all, :except => [:new, :create, :edit]
  batch_action :destroy, false
  filter :id
  config.comments = false
  filter :created_at
  filter :who, label: 'Who', as: :select, collection: Cancellation.whos

  index :download_links => false do
    id_column
    column :order, :sortable => :order_id
    column 'Who Canceled', :sortable => :who do |cancel|
      if cancel.user
        path = if cancel.who == 'driver'
                 admin_driver_path(cancel.user)
               else
                 admin_seller_path(cancel.user)
               end
        link_to(cancel.who, path)
      else
        cancel.who
      end
    end

    column 'Order had status', :status, :sortable => :status
    column :reason
    column :created_at, :sortable => :created_at

    actions dropdown: true
  end


  show do
    attributes_table do
      row :id
      row :order
      row :reason

      row 'Who Canceled' do |cancel|
        if cancel.user
          path = if cancel.who == 'driver'
                   admin_driver_path(cancel.user)
                 else
                   admin_seller_path(cancel.user)
                 end
          link_to(cancel.who, path)
        else
          cancel.who
        end
      end
      row :created_at

    end
  end

end
