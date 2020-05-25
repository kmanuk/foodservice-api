module Authentication
  def login
    before(:each) do
      @user = create(:user)
      request.env["devise.mapping"] = Devise.mappings[:user]
      auth_headers = @user.create_new_auth_token
      request.headers.merge! auth_headers
    end
  end

  def login_driver
    before(:each) do
      @user = create(:driver)
      request.env["devise.mapping"] = Devise.mappings[:user]
      auth_headers = @user.create_new_auth_token
      request.headers.merge! auth_headers
    end
  end


  def login_certified_driver
    before(:each) do
      @user = create(:driver, :certified)
      request.env["devise.mapping"] = Devise.mappings[:user]
      auth_headers = @user.create_new_auth_token
      request.headers.merge! auth_headers
    end
  end


  def login_seller
    before(:each) do
      @user = create(:seller)
      request.env["devise.mapping"] = Devise.mappings[:user]
      auth_headers = @user.create_new_auth_token
      request.headers.merge! auth_headers
    end
  end

  def login_admin
    before :each do
      @user = create(:admin_user)
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in @user
    end
  end
end
