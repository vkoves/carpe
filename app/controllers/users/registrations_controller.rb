class Users::RegistrationsController < Devise::RegistrationsController

  # Overwrite update_resource to let users to update their user without giving their password
  def update_resource(resource, params)
    if params[:image_url] and false
      begin
        url = URI.parse(params[:image_url])
        Net::HTTP.start(url.host, url.port, :use_ssl => true) do |http|
          if(!http.head(url.request_uri)['Content-Type'].include? 'image')
            flash[:notice] = nil
            flash[:alert] = "That image isn't valid, please check your URL!"
            params[:image_url] = current_user.image_url
            #return
          end
        end
      rescue URI::InvalidURIError, Exception => e
          flash[:alert] = "That image isn't valid, please check your URL!"
          flash[:notice] = nil
          params[:image_url] = current_user.image_url
          #return
      end
    end
    
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
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :image_url)
  end

  def account_update_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :current_password, :image_url)
  end
end