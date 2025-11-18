class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[ show ]

  # GET /recipes - RPG-style recipe browsing
  def index
    @query = nil
    @recipes = current_user.recipes.order(title: :asc)
  end

  # GET /recipes/search - Search recipes by embedding
  def search
    @query = params[:q]&.strip
    @recipes = if @query.present?
      current_user.recipes.search_by_embedding(@query)
    else
      current_user.recipes.none
    end
    render :index
  end

  # GET /recipes/1 - RPG-style recipe detail
  def show
  end

  private
    def set_recipe
      @recipe = current_user.recipes.find(params.expect(:id))
    end
end
