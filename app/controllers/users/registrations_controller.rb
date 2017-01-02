class Users::RegistrationsController < Devise::RegistrationsController

  # Overwrite update_resource to let users to update their user without giving their password
  def update_resource(resource, params)
    if current_user.provider
      params.delete("current_password")
      resource.update_without_password(params)
    else
      resource.update_with_password(params)
    end
  end


  #Add new field
  private

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :avatar, :home_time_zone)
  end

  def account_update_params
    params.require(:user).permit(:name, :email, :public_profile, :password, :password_confirmation, :current_password, :avatar, :home_time_zone)
  end
end