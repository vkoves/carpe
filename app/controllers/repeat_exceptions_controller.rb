class RepeatExceptionsController < ApplicationController
  before_action :authorize_signed_in!
  respond_to :json

  def create
    repeat_exception = RepeatException.new(create_repeat_exception_params)
    repeat_exception.user = current_user
    repeat_exception.save

    render json: repeat_exception
  end

  def update
    repeat_exception = RepeatException.find(params[:id])
    repeat_exception.update(update_repeat_exception_params)
    head :ok
  end

  def destroy
    repeat_exception = RepeatException.find(params[:id])
    repeat_exception.destroy
    head :ok
  end

  private

  def create_repeat_exception_params
    params.permit(:name, :start, :end, :group_id)
  end

  def update_repeat_exception_params
    params.require(:repeat_exception).permit(:name, :start, :end)
  end
end
