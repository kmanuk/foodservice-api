ActiveAdmin.register SubCategory do
  menu :label => 'Sub Categories', :priority => 7
  permit_params :en, :ar, :description, :category_id, image_attributes: [:data, :imageable_id]


  config.comments = false
  batch_action  :destroy, false

  filter :category
  filter :en
  filter :ar

  index :download_links => false do
    id_column
    column :en
    column :ar
    column :description

    column 'Category (Eng)'  do |sub_category|
      sub_category.category.en ? link_to(sub_category.category.en, admin_category_path(sub_category.category)) : ''
    end
    column 'Category (Ar)'  do |sub_category|
      sub_category.category.ar ? link_to(sub_category.category.ar, admin_category_path(sub_category.category)) : ''
    end

    column 'Image', class: 'active_admin_image_thumb_50'  do |sub_category|
      sub_category.image ? image_tag(sub_category.image.data.url) : ''
    end

    actions defaults: false, dropdown: true do |sub_category|
      item 'View', admin_sub_category_path(sub_category)
      item 'Edit', edit_admin_sub_category_path(sub_category)
      item 'Delete', admin_sub_category_path(sub_category), method: :delete, data: {confirm: "Are you sure you want to delete this Sub-Category?\nAlso will be deleted #{sub_category.items.count} items with this Sub-Category. " }
    end
  end

  controller do
    def scoped_collection
      super.includes :category, :image
#      end_of_association_chain.includes(:category)
    end

    def update
      model = :sub_category
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
      f.input :description
      f.input :category, as: :select, collection: Category.all.map{|c| [c.name, c.id]}
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
      row :description
      row :category
      row 'image', class: 'active_admin_image_thumb_150' do |sub_category|
        sub_category.image ? image_tag(sub_category.image.data.url) : ''
      end

    end
  end
end
