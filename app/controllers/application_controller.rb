class ApplicationController < ActionController::API
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Call this in any controller action that requires a logged-in user
  def authenticate_manager!
    authenticate_user!
    unless current_user&.manager?
      render json: { error: "Access denied. Manager account required." }, status: :forbidden
    end
  end

  def authenticate_player!
    authenticate_user!
    unless current_user&.player?
      render json: { error: "Access denied. Player account required." }, status: :forbidden
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :phone_number ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :phone_number ])
  end
end
