class RepeatExceptionController < ApplicationController
  before_action :authorize_signed_in!
  respond_to :json

  def create
    repeat_exception = RepeatException.create(repeat_exception_params)
    render json: repeat_exception
  end

  def update
    repeat_exception = RepeatException.find(params[:id])
    repeat_exception.update(repeat_exception_params)
  end

  def destroy
    repeat_exception = RepeatException.find(params[:id])
    repeat_exception.destroy
  end

  private

  def repeat_exception_params
    params.permit(:name, :start, :end, :user_id, :group_id)
  end
end
