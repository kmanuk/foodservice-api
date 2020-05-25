class Api::V1::ReviewsController < ApiController
  resource_description do
    formats [:json]
    api_version 'v1'
  end
  include Docs::V1::Reviews

  before_action :authenticate_user!, :find_user
  before_action :find_review, only: [:show]

  def index
    @reviews = @user.reviews
  end

  def show
  end

  def create
    @review = @user.reviews.build(review_params)
    @review.reviewer = current_user
    @review.status = @user.role

    if @review.save
      render :show, status: :created
    else
      render_errors @review
    end
  end

  private

  def find_user
    @user = User.find_by!(id: params[:user_id])
  end

  def find_review
    @review = @user.reviews.find_by!(id:params[:id])
  end

  def review_params
    params.require(:review).permit(:rate, :message, :order_id)
  end
end
