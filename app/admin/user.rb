ActiveAdmin.register_page "Users" do

  menu priority: 2, label: 'Users'


  content title: 'Users' do

    div class: 'blank_slate_container three-columns', id: 'dashboard_default_message' do
      span class: 'blank_slate' do
        link_to('Drivers', admin_drivers_path)
      end
    end

    div class: 'blank_slate_container three-columns', id: 'dashboard_default_message' do
      span class: 'blank_slate' do
        link_to('Buyers', admin_buyers_path)
      end
    end

    div class: 'blank_slate_container three-columns', id: 'dashboard_default_message' do
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
