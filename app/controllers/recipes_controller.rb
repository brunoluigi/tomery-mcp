class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[ show ]

  # GET /recipes - RPG-style recipe browsing
  def index
    @recipes = current_user.recipes.order(title: :asc)
  end

  # GET /recipes/1 - RPG-style recipe detail
  def show
  end

  private
    def set_recipe
      @recipe = current_user.recipes.find(params.expect(:id))
    end
end
