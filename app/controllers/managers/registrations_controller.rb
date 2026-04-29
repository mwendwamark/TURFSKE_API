module Managers
  class RegistrationsController < Devise::RegistrationsController
    include ActionController::MimeResponds
    respond_to :json

    # POST /managers/signup
    def create
      build_resource(sign_up_params.merge(roles: ["manager"]))

      if resource.save
        render json: {
          message: "Signup successful. You can now log in.",
          user: user_json(resource)
        }, status: :created
      else
        render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def sign_up_params
      params.require(:user).permit(:first_name, :last_name, :phone_number, :email, :password)
    end

    def user_json(user)
      {
        id: user.id,
        first_name: user.first_name,
        last_name: user.last_name,
        phone_number: user.phone_number,
        email: user.email,
        roles: Array(user.roles),
        created_at: user.created_at,
        updated_at: user.updated_at,
      }
    end
  end
end
