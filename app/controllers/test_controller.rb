class TestController < ApplicationController
  before_action :authenticate_user!

  def index
    render json: {
      message: "Authenticated successfully!",
      user: {
        id: current_user.id,
        email: current_user.email,
        roles: current_user.roles,
        player?: current_user.player?,
        manager?: current_user.manager?
      }
    }
  end
end
