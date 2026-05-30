module Admin
  class FranchisesController < BaseController
    before_action :set_franchise, only: %i[show edit update reset_password]

    def index
      @franchises = Franchise.order(:name)
    end

    def show
      @orders = @franchise.orders.recent.limit(20)
    end

    def new
      @franchise = Franchise.new
    end

    def create
      result = FranchiseCreator.call(**franchise_params.to_h.symbolize_keys)

      if result.success?
        redirect_to admin_franchise_path(result.franchise),
                    notice: t("app.flash.franchise_created", password: result.initial_password)
      else
        @franchise = result.franchise.is_a?(Franchise) ? result.franchise : Franchise.new(franchise_params)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @franchise.update(franchise_params)
        redirect_to admin_franchise_path(@franchise), notice: t("app.flash.franchise_updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def reset_password
      owner = @franchise.owner
      if owner.nil?
        redirect_to admin_franchise_path(@franchise), alert: t("app.flash.owner_account_missing")
        return
      end

      password = PasswordResetter.reset!(owner)
      redirect_to admin_franchise_path(@franchise),
                  notice: t("app.flash.owner_password_reset", email: owner.email, password: password)
    end

    private

    def set_franchise
      @franchise = Franchise.find_by(id: params[:id])
      redirect_to admin_franchises_path, alert: t("app.errors.owner.not_found") if @franchise.nil?
    end

    def franchise_params
      params.require(:franchise).permit(:name, :address, :owner_email)
    end
  end
end
