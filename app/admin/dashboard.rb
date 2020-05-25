ActiveAdmin.register_page "Dashboard" do


  menu false


  content title: proc { I18n.t("active_admin.dashboard") } do
    div class: 'blank_slate_container left', id: 'dashboard_default_message' do
      span class: 'blank_slate' do
        link_to('Categories', admin_categories_path)
      end
    end


    div class: 'blank_slate_container', id: 'dashboard_default_message' do
      span class: 'blank_slate' do
        link_to('SubCategories', admin_sub_categories_path)
      end
    end


    div class: 'blank_slate_container left', id: 'dashboard_default_message' do
      span class: 'blank_slate' do
        link_to('Drivers', admin_drivers_path)
      end
    end

    div class: 'blank_slate_container', id: 'dashboard_default_message' do
      span class: 'blank_slate' do
        link_to('Sellers', admin_sellers_path)
      end
    end




    # Here is an example of a simple dashboard with columns and panels.
    #



    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
  end # content
end
