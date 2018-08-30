class CategoriesController < ApplicationController
  def create
    @category = current_user.categories.new(create_params)

    authorize! :create, @category
    @category.save

    render json: @category
  end

  def update
    @category = Category.find(params[:id])

    authorize! :update, @category
    @category.update(update_params)

    render json: @category
  end

  def destroy
    @category = Category.find(params[:id])

    authorize! :destroy, @category
    @category.destroy

    render plain: "Category destroyed"
  end

  private

  def create_params
    params.permit(:name, :color, :privacy, :group_id)
  end

  def update_params
    params.require(:category).permit(:name, :color, :privacy, repeat_exception_ids: [])
  end
end
