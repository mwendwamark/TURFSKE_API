module Auth
  class ConfirmationsController < Devise::ConfirmationsController
    include ActionController::MimeResponds
    respond_to :json

    # POST /auth/confirmation
    def create
      email = confirmation_email
      token = confirmation_token

      if email.blank? || token.blank?
        return render json: { error: "Email and confirmation token are required." }, status: :bad_request
      end

      user = User.find_by(email: email)

      unless user && valid_confirmation_token?(user, token)
        return render json: { error: "Invalid or expired confirmation token." }, status: :unprocessable_entity
      end

      if user.confirmed?
        return render json: { message: "Email is already confirmed. You can log in." }, status: :ok
      end

      if user.confirm
        render json: { message: "Email confirmed successfully. You can now log in." }, status: :ok
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # POST /auth/confirmation/resend
    def resend
      email = confirmation_email

      if email.blank?
        return render json: { error: "Email is required." }, status: :bad_request
      end

      user = User.find_by(email: email)
      user.resend_confirmation_instructions if user.present? && !user.confirmed?

      render json: {
        message: "If your account exists and is awaiting confirmation, a new confirmation token has been sent."
      }, status: :ok
    end

    # GET /auth/confirmation?confirmation_token=...
    def show
      token = params[:confirmation_token]
      
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

    private

    def confirmation_email
      params.dig(:user, :email).to_s.strip.downcase
    end

    def confirmation_token
      params.dig(:user, :confirmation_token).to_s.strip
    end

    def valid_confirmation_token?(user, raw_token)
      stored_token = user.confirmation_token.to_s
      digested_token = Devise.token_generator.digest(User, :confirmation_token, raw_token)

      secure_token_match?(stored_token, raw_token) || secure_token_match?(stored_token, digested_token)
    end

    def secure_token_match?(stored_token, candidate_token)
      return false if stored_token.blank? || candidate_token.blank?
      return false unless stored_token.bytesize == candidate_token.bytesize

      ActiveSupport::SecurityUtils.secure_compare(stored_token, candidate_token)
    end
  end
end
