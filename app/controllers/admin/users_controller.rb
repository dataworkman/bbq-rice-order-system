module Admin
  class UsersController < BaseController
    before_action :set_admin_user, only: :reset_password

    def index
      @admins = User.admin.order(:email)
    end

    def new
      @admin = User.new(role: :admin)
    end

    def create
      password = InitialPassword.generate
      @admin = User.new(admin_params.merge(role: :admin, password: password, password_confirmation: password))

      if @admin.save
        redirect_to admin_users_path, notice: t("app.flash.admin_created", email: @admin.email, password: password)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def reset_password
      if @admin_user.id == current_user.id
        redirect_to admin_users_path, alert: t("app.flash.cannot_reset_own_password_here")
        return
      end

      password = PasswordResetter.reset!(@admin_user)
      redirect_to admin_users_path,
                  notice: t("app.flash.admin_password_reset", email: @admin_user.email, password: password)
    end

    private

    def set_admin_user
      @admin_user = User.admin.find_by(id: params[:id])
      redirect_to admin_users_path, alert: t("app.errors.admin.not_found") if @admin_user.nil?
    end

    def admin_params
      params.require(:user).permit(:email)
    end
  end
end
