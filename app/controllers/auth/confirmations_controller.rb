module Auth
  class ConfirmationsController < Devise::ConfirmationsController
    include ActionController::MimeResponds
    respond_to :json

    # GET /auth/confirmation?confirmation_token=...
    def show
      token = params[:confirmation_token] || params[:confirmation_token]
      
      if token.blank?
        return render json: { error: "Confirmation token is missing" }, status: :bad_request
      end

      user = User.confirm_by_token(token)

      if user.errors.empty?
        render json: { message: "Email confirmed successfully. You can now log in." }, status: :ok
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
