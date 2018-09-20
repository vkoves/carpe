class RepeatExceptionsController < ApplicationController
  def create
    @repeat_exception = current_user.repeat_exceptions.new(create_params)

    authorize! :create, @repeat_exception
    @repeat_exception.save

    render json: @repeat_exception
  end

  def update
    @repeat_exception = RepeatExceptions.find(params[:id])

    authorize! :update, @repeat_exception
    @repeat_exception.update(update_params)

    render json: @repeat_exception
  end

  def destroy
    @repeat_exception = RepeatExceptions.find(params[:id])

    authorize! :destroy, @repeat_exception
    @repeat_exception.destroy

    render json: @repeat_exception
  end

  private

  def create_params
    params.permit(:name, :start, :end, :group_id)
  end

  def update_params
    params.require(:repeat_exception).permit(:name, :start, :end)
  end
end
