ActiveAdmin.register User, :as => 'Buyer' do
  permit_params :name,
                :email,
                :password,
                :password_confirmation,
                :role,
                :phone,
                :avatar,
                :quickblox_user_id

  menu label: 'Buyers', priority: 2, parent: 'Users'

  config.comments = false

  filter :email
  filter :name


  batch_action :destroy, false

  controller do
    def scoped_collection
      User.where(role: 'buyer')
    end
  end

  index :download_links => false do
    selectable_column
    id_column
    column :name
    column :phone
    column :email
    column :created_at, :sortable => :created_at
    actions dropdown: true
  end

  show do
    attributes_table do
      row :id
      row :name
      row :phone
      row :email
      row 'avatar', class: 'active_admin_image_thumb_150' do |user|
        user&.avatar&.url&.present? ? image_tag(user.avatar.url) : ''
      end
      row :quickblox_user_id
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
      f.input :quickblox_user_id
    end
    f.actions
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


end
