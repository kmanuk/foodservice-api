ActiveAdmin.register Category do
#  actions :all, except: [:destroy]
  menu :label => 'Categories', :priority => 6

  permit_params :en, :ar, :description, :product_type_id, image_attributes: [:data, :imageable_id]

  config.comments = false
  batch_action  :destroy, false


  filter :product_type
  filter :en
  filter :ar

  index :download_links => false do
    id_column
    column :en
    column :ar

    column 'Product Type (Eng)' do |category|
      category.product_type.en ? link_to(category.product_type.en, admin_product_type_path(category.product_type)) : ''
    end
    column 'Product Type (Ar)' do |category|
      category.product_type.ar ? link_to(category.product_type.ar, admin_product_type_path(category.product_type)) : ''
    end

    column 'Image', class: 'active_admin_image_thumb_50' do |category|
      category.image ? image_tag(category.image.data.url) : ''
    end

    actions defaults: false, dropdown: true do |category|
      item 'View', admin_category_path(category)
      item 'Edit', edit_admin_category_path(category)
      item 'Delete', admin_category_path(category), method: :delete, data: {confirm: "Are you sure you want to delete this Category?\nAlso will be deleted #{category.sub_categories.count} sub-categories, all related items, with this Category." }
    end
  end

  controller do
    def scoped_collection
      super.includes :product_type, :image
    end

    def update
      model = :category
      if params[model][:image_attributes][:data].blank?
        %w(image_attributes).each { |p| params[model].delete(p) }
      end
      super
    end

  end

  form multipart: true do |f|
    f.semantic_errors # shows errors on :base
    f.inputs do
      f.input :en
      f.input :ar
      f.input :description
      f.input :product_type, as: :select, collection: ProductType.all.map { |c| [c.name, c.id] }

      f.inputs :for => [:image, f.object.image || Image.new], :class => 'has_many_fields active_admin_image_thumb_150' do |image|
        image.input :imageable_id, :as => :hidden, :value => f
        image.input :data, label: 'Image', :as => :file, hint: f.object.image ? f.image_tag(f.object.image.data.url) : ''
      end

    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :en
      row :ar
      row :description
      row :product_type


      row 'image', class: 'active_admin_image_thumb_150' do |category|
        category.image ? image_tag(category.image.data.url) : ''
      end

      panel 'SubCategories' do
        table_for category.sub_categories do
          column 'Id' do |sub_category|
            link_to(sub_category.id, admin_sub_category_path(sub_category))
          end
          column 'sub_category (Eng)'  do |sub_category|
            sub_category.en ? link_to(sub_category.en, admin_sub_category_path(sub_category)) : ''
          end
          column 'Category (Ar)'  do |sub_category|
            sub_category.ar ? link_to(sub_category.ar, admin_sub_category_path(sub_category)) : ''
          end
          column 'Image', class: 'active_admin_image_thumb_50' do |sub_category|
            sub_category.image ? image_tag(sub_category.image.data.url) : ''
          end
        end
      end

    end
  end
end
