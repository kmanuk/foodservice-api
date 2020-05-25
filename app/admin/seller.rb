ActiveAdmin.register User, :as => 'Seller' do
  permit_params :email, :password, :password_confirmation, :name, :role, :phone, :avatar, :recommended_seller, :quickblox_user_id

  menu label: 'Sellers', priority: 4, parent: 'Users'

  config.comments = false

  filter :email
  filter :name

  scope :recommended_seller do |users|
    users.where(recommended_seller: true)
  end

  scope :active

  batch_action :destroy, false

  batch_action :recommend do |ids|
    change_seller(ids, :recommended_seller, true)
  end

  batch_action :unrecommend do |ids|
    change_seller(ids, :recommended_seller, false)
  end


  controller do
    def scoped_collection
      User.where(role: 'seller')
    end

    def change_seller(ids, field, value)
      User.find(ids).each do |seller|
        seller.update_attribute(field, value)
      end
      redirect_to admin_sellers_path, notice: 'Changed!'
    end
  end

  index :download_links => false do
    selectable_column
    id_column
    column :name
    column :phone
    column :email
    column :business_name
    column :recommended_seller, :as => :checkbox
    column :created_at, :sortable => :created_at
    actions defaults: false, dropdown: true do |seller|
      item seller.recommended_seller? ? 'Unrecommend' : 'Recommend', url_for(:action => :recommend_seller, :id => seller.id), :method => :put
      item 'View', admin_seller_path(seller)
      item 'Edit', edit_admin_seller_path(seller)
      item 'Delete', admin_seller_path(seller), method: :delete, data: {confirm: "Are you sure you want to delete this User?\nAlso will be deleted #{seller.items.count} items. " }
    end


  end

  show do
    attributes_table do
      row :id
      row :name
      row :phone
      row :email
      row :iban
      row :bank_name
      row :quickblox_user_id
      row 'avatar', class: 'active_admin_image_thumb_150' do |user|
        user&.avatar&.url&.present? ? image_tag(user.avatar.url) : ''
      end
      panel 'Items' do
        table_for seller.items do
          column :id
          column :name
          column :amount
          column :type
          column :price
          column :total_price
          column :time_to_cook

          column 'Product Type' do |item|
            item.product_type.en ? link_to(item.product_type.en, admin_product_type_path(item.product_type)) : ''
          end

          column 'Category' do |item|
            item.category.en ? link_to(item.category.en, admin_category_path(item.category)) : ''
          end

          column 'SubCategory' do |item|
            item.sub_category.en ? link_to(item.sub_category.en, admin_sub_category_path(item.sub_category)) : ''
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
      f.input :recommended_seller
      f.input :business_name
      f.input :iban
      f.input :quickblox_user_id
      f.input :bank_name
      f.input :avatar, :as => :file, :hint => image_tag(f.object.avatar.url)
    end
    f.actions
  end

  member_action :recommend_seller, method: :put do
    seller = User.find_by(id: params[:id])
    seller.toggle!(:recommended_seller)
    redirect_to admin_sellers_path, notice: 'Changed!'
  end

end
