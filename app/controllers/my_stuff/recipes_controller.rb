class MyStuff::RecipesController < ApplicationController
  before_action :set_recipe, only: %i[ show destroy ]

  # GET /my_stuff/recipes or /my_stuff/recipes.json
  def index
    @recipes = current_user.recipes.order(title: :asc)
  end

  # GET /my_stuff/recipes/1 or /my_stuff/recipes/1.json
  def show
  end

  # DELETE /my_stuff/recipes/1 or /my_stuff/recipes/1.json
  def destroy
    @recipe.destroy!

    respond_to do |format|
      format.html { redirect_to my_stuff_recipes_path, notice: "Recipe was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recipe
      @recipe = current_user.recipes.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def recipe_params
      params.fetch(:recipe, {})
    end
end
