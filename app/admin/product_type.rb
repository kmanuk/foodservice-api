ActiveAdmin.register ProductType do

  menu :label => 'Product Types', :priority => 5

  permit_params :en, :ar, image_attributes: [:data, :imageable_id]

  config.comments = false
  config.filters = false
  batch_action  :destroy, false

  index :download_links => false do
    id_column
    column :en
    column :ar

    column 'Image', class: 'active_admin_image_thumb_50'  do |product_type|
      product_type.image ? image_tag(product_type.image.data.url) : ''
    end

    actions defaults: false, dropdown: true do |product_type|
      item 'View', admin_product_type_path(product_type)
      item 'Edit', edit_admin_product_type_path(product_type)
      item 'Delete', admin_product_type_path(product_type), method: :delete, data: {confirm: "Are you sure you want to delete this Product Type?\nAlso will be deleted #{product_type.categories.count} categories, all related sub-categories and items, with this Product Type." }
    end

  end

  controller do
    def scoped_collection
      super.includes :image
    end

    def update
      model = :product_type
      if params[model][:image_attributes][:data].blank?
        %w(image_attributes).each { |p| params[model].delete(p) }
      end
      super
    end

  end

  form do |f|
    f.semantic_errors # shows errors on :base
    f.inputs do
      f.input :en
      f.input :ar

      f.inputs :for => [:image, f.object.image || Image.new], :class => 'has_many_fields active_admin_image_thumb_150'  do |image|
        image.input :imageable_id, :as => :hidden, :value => f
        image.input :data,  label: 'Image', :as => :file, hint: f.object.image ? f.image_tag(f.object.image.data.url) : ''
      end
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :en
      row :ar

      row 'image', class: 'active_admin_image_thumb_150' do |category|
        category.image ? image_tag(category.image.data.url) : ''
      end

      panel 'Categories' do
        table_for product_type.categories do
          column 'Id' do |category|
            link_to(category.id, admin_category_path(category))
          end
          column 'Category (Eng)'  do |category|
            category.en ? link_to(category.en, admin_category_path(category)) : ''
          end
          column 'Category (Ar)'  do |category|
            category.ar ? link_to(category.ar, admin_category_path(category)) : ''
          end
          column 'Image', class: 'active_admin_image_thumb_50' do |category|
            category.image ? image_tag(category.image.data.url) : ''
          end
        end
      end
    end
  end
end
