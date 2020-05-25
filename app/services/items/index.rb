class Items::Index < Items::Base
  include Interactor

  before do
    @params = context[:params]
    @user = context[:user]
  end

  def call
    @items = available_items
    add_image_and_filter
    @items = @items.without_user(@user) if @user
    paginate_items
  end

  after do
    context.items = @items
    context.result_paginations = @pagination
  end
end
