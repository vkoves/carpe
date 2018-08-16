class CategoriesController < ApplicationController
  before_action :authorize_signed_in!
  respond_to :json

  def create
    category = Category.new(create_category_params)
    category.user = current_user
    authorize! :create, category
    category.save

    render json: category
  end

  def update
    category = Category.find(params[:id])
    authorize! :update, category
    category.update(update_category_params)

    render json: category
  end

  def destroy
    category = Category.find(params[:id])
    authorize! :destroy, category
    category.destroy

    render json: category
  end

  private

  def create_category_params
    params.permit(:name, :color, :privacy, :group_id)
  end

  def update_category_params
    params.require(:category).permit(:name, :color, :privacy, repeat_exception_ids: [])
  end
end
