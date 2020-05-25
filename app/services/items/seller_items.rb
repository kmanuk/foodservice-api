class Items::SellerItems < Items::Base
  include Interactor

  before do
    @params = context[:params]
    @user = context[:user]
  end

  def call

    context.fail!(errors: I18n.t('errors.base.validate_role_seller')) unless @user.seller?

    @items = @user.items
    add_image_and_filter
    paginate_items

  end

  after do
    context.items = @items
    context.result_paginations = @pagination
  end
end
