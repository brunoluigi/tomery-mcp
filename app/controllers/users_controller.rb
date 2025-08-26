class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  before_action :set_user, only: %i[ toggle_activate destroy ]
  before_action :require_admin_access, only: %i[ index toggle_activate destroy ]

  # GET /users or /users.json
  def index
    @users = User.all
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # POST /users or /users.json
  def create
    @user = User.new(**user_params, password: SecureRandom.alphanumeric(16))

    respond_to do |format|
      @user.save

      format.html { redirect_to users_path, notice: "Email added to waiting list." }
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    @user.destroy!

    respond_to do |format|
      format.html { redirect_to users_path, notice: "User was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def toggle_activate
    @user.toggle(:active).save!

    respond_to do |format|
      format.html { redirect_to users_path, notice: "User was successfully #{ @user.active? ? "activated" : "deactivated" }.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.fetch(:user, {}).permit(:email_address)
    end
end
