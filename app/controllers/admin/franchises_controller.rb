module Admin
  class FranchisesController < BaseController
    before_action :set_franchise, only: %i[show edit update]

    def index
      @franchises = Franchise.order(:name)
    end

    def show
      @orders = @franchise.orders.recent.limit(20)
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
