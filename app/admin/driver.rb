ActiveAdmin.register User, :as => 'Driver' do
  permit_params :email,
                :password,
                :password_confirmation,
                :name,
                :role,
                :phone,
                :avatar,
                :approved_driver,
                :certified_driver,
                :car_type,
                :plate_number,
                :driver_license,
                :insurance_name,
                :insurance_number,
                :active_driver,
                :quickblox_user_id

  menu label: 'Drivers', priority: 3, parent: 'Users'

  scope :active_driver do |users|
    users.where(active_driver: true)
  end
  scope :certified_drivers
  scope :regular_drivers

  scope :approved_drivers do |users|
    users.where(approved_driver: true)
  end



  config.comments = false

  filter :email
  filter :name

  batch_action :destroy, false

  batch_action :approve do |ids|
    change_driver(ids, :approved_driver, true)
  end

  batch_action :disapprove do |ids|
    change_driver(ids, :approved_driver, false)
  end

  batch_action :certify do |ids|
    change_driver(ids, :certified_driver, true)
  end

  batch_action :uncertify do |ids|
    change_driver(ids, :certified_driver, false)
  end

  controller do
    def scoped_collection
      User.where(role: 'driver')
    end

    def change_driver(ids, field, value)
      User.find(ids).each do |driver|
        driver.update_attribute(field, value)
      end
      redirect_to admin_drivers_path, notice: 'Changed!'
    end


  end

  index :download_links => false do
    selectable_column
    id_column
    column :name
    column :phone
    column :email
    column :approved_driver, :as => :checkbox
    column :certified_driver, :as => :checkbox
    column :created_at, :sortable => :created_at
    column :active_driver, :sortable => :active_driver
    # do |obj|
    #   obj.created_at.localtime.strftime("%B %d, %Y %H:%M")
    # end

    actions dropdown: true do |driver|
      item driver.approved_driver ? 'Disapprove' : 'Approve', url_for(:action => :approve_driver, :id => driver.id), :method => :put
      item driver.certified_driver? ? 'Uncertify' : 'Certify', url_for(:action => :certify_driver, :id => driver.id), :method => :put
    end

  end


  member_action :approve_driver, method: :put do
    driver = User.find(params[:id])
    driver.toggle!(:approved_driver)
    redirect_to admin_drivers_path, notice: 'Changed!'
  end

  member_action :certify_driver, :method => :put do
    driver = User.find(params[:id])
    driver.toggle!(:certified_driver)
    redirect_to admin_drivers_path, notice: 'Changed!'
  end

  show do
    attributes_table do
      row :id
      row :name
      row :phone
      row :email
      row :quickblox_user_id
      row :approved_driver
      row :certified_driver
      row :active_driver
      row :car_type
      row :plate_number
      row :driver_license
      row :insurance_name
      row :insurance_number
      row 'avatar', class: 'active_admin_image_thumb_150' do |user|
        user&.avatar&.url&.present? ? image_tag(user.avatar.url) : ''
      end
      panel 'Current Orders' do
        table_for driver.orders.active do
          column 'Id' do |order|
            link_to(order.id, admin_order_path(order))
          end
          column :status
          column 'Seller' do |order|
            link_to(order.seller.name, admin_seller_path(order.seller))
          end
          column 'Buyer' do |order|
            link_to(order.buyer.name, admin_buyer_path(order.buyer))
          end
        end
      end
    end
  end


  controller do
    def update
      model = :user
      if params[model][:password].blank?
        %w(password password_confirmation).each { |p| params[model].delete(p) }
      end
      super
    end

    def destroy
      destroy! do |success, failure|
        failure.html do
          flash[:error] = 'The deletion failed because: ' + resource.errors.full_messages.to_sentence
          render action: :index
        end
      end
    end
  end


  form do |f|
    f.semantic_errors # shows errors on :base
    f.inputs do
      f.input :name
      f.input :email
      f.input :phone
      f.input :role, :as => :hidden
      f.input :password
      f.input :password_confirmation
      f.input :avatar, :as => :file, :hint => image_tag(f.object.avatar.url)
      f.input :approved_driver
      f.input :certified_driver
      f.input :quickblox_user_id
      f.input :car_type
      f.input :plate_number
      f.input :driver_license
      f.input :insurance_name
      f.input :insurance_number
      f.input :active_driver
    end
    f.actions
  end

end
