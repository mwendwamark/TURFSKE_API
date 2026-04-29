module Managers
  class PasswordsController < Devise::PasswordsController
    include ActionController::MimeResponds
    respond_to :json

    # POST /managers/password (send reset instructions)
    def create
      self.resource = resource_class.send_reset_password_instructions(resource_params)
      if successfully_sent?(resource)
        render json: { message: "Password reset instructions sent to your email." }, status: :ok
      else
        render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PUT /managers/password (reset password)
    def update
      self.resource = resource_class.reset_password_by_token(resource_params)
      if resource.errors.empty?
        render json: { message: "Password has been reset successfully. You can now log in." }, status: :ok
      else
        render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
