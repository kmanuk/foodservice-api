ActiveAdmin.register AdminUser do
  permit_params :email, :password, :password_confirmation
  actions :all, :except => [:show]

  menu label: 'Admins', priority: 1, parent: 'Users'
  batch_action :destroy, false

  config.comments = false
  config.filters = false

  index :download_links => false do
    column :id
    column :email
    actions defaults: false do |admin_user|
      item 'Edit', edit_admin_admin_user_path(admin_user)
    end

  end



  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

end
