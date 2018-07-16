class CategoriesController < ApplicationController
  before_action :authorize_signed_in!
  respond_to :json

  def create
    category = Category.new(create_category_params)
    category.user = current_user
    category.save

    render json: category
  end

  def update
    category = Category.find(params[:id])
    category.update(update_category_params)
    head :ok
  end

  def destroy
    category = Category.find(params[:id])
    category.destroy
    head :ok
  end

  private

  def create_category_params
    params.permit(:name, :color, :privacy, :group_id)
  end

  def update_category_params
    params.require(:category).permit(:name, :color, :privacy, repeat_exception_ids: [])
  end
end

# category.repeat_exception_ids = params[:breaks] if params[:breaks]

#    @cat.repeat_exceptions = RepeatException.find(params[:breaks])

# def create_category
#   cat = params[:id] ? Category.find(params[:id]) : Category.new
#   cat.user = User.find(params[:user_id]) if params[:user_id]
#   cat.group = Group.find(params[:group_id]) unless params[:group_id].empty?
#   cat.name = params[:name]
#   cat.color = params[:color]
#   cat.privacy = params[:privacy] if params[:privacy]
#   cat.repeat_exception_ids = params[:breaks] if params[:breaks]
#   cat.save
#
#   render json: cat
# end