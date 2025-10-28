class PantryItemsController < ApplicationController
  before_action :set_pantry_item, only: %i[ update destroy ]

  # GET /pantry_items - RPG-style pantry management
  def index
    @pantry_items = current_user.pantry_items.order(name: :asc)
  end

  # GET /pantry_items/new
  def new
    @pantry_item = current_user.pantry_items.new
  end

  # POST /pantry_items
  def create
    @pantry_item = current_user.pantry_items.new(pantry_item_params)

    if @pantry_item.save
      redirect_to pantry_items_path, notice: "Pantry item was successfully added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /pantry_items/1
  def update
    if @pantry_item.update(pantry_item_params)
      redirect_to pantry_items_path, notice: "Pantry item was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /pantry_items/1
  def destroy
    @pantry_item.destroy!
    redirect_to pantry_items_path, notice: "Pantry item was successfully removed.", status: :see_other
  end

  private
    def set_pantry_item
      @pantry_item = current_user.pantry_items.find(params.expect(:id))
    end

    def pantry_item_params
      params.require(:pantry_item).permit(:name, :quantity)
    end
end
