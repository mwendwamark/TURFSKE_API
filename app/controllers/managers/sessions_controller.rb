module Managers
  class SessionsController < Devise::SessionsController
    include ActionController::MimeResponds
    respond_to :json
    before_action :authenticate_user!, only: :destroy

    # POST /managers/login
    def create
      normalize_login_param!
      self.resource = warden.authenticate(auth_options)

      if resource.nil?
        return render json: { error: "Please confirm your email before logging in." }, status: :unauthorized if unconfirmed_login_attempt?
        return render json: { error: "Invalid login credentials" }, status: :unauthorized
      end

      unless resource.manager?
        return render json: { error: "Role mismatch. Use the correct portal for your role." }, status: :forbidden
      end

      sign_in(resource_name, resource)

      token = request.env["warden-jwt_auth.token"] || response.headers["Authorization"]&.split(" ")&.last
      render json: {
        message: "Login successful",
        user: user_json(resource),
        token: token,
      }, status: :ok
    end

    # DELETE /managers/logout
    def destroy
      sign_out(resource_name)
      render json: { message: "Logout successful" }, status: :ok
    end

    private

    def normalize_login_param!
      return unless params[:user].is_a?(ActionController::Parameters)
      params[:user][:login] ||= params[:user][:email] || params[:user][:phone_number]
    end

    def unconfirmed_login_attempt?
      user = user_for_login_identifier
      user.present? && !user.confirmed? && user.valid_password?(params.dig(:user, :password).to_s)
    end

    def user_for_login_identifier
      login = params.dig(:user, :login).to_s.strip
      return nil if login.blank?

      User.find_for_database_authentication(login: login)
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
