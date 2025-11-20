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
  rescue AiService::ApiKeyError => e
    flash.now[:alert] = "AI search is not configured. Please contact support."
    @recipes = current_user.recipes.none
    render :index, status: :ok
  rescue AiService::RateLimitError => e
    flash.now[:alert] = "AI service is temporarily unavailable due to rate limits. Please try again in a moment."
    @recipes = current_user.recipes.none
    render :index, status: :ok
  rescue AiService::NetworkError => e
    flash.now[:alert] = "Unable to connect to AI service. Please check your connection and try again."
    @recipes = current_user.recipes.none
    render :index, status: :ok
  rescue AiService::Error => e
    Rails.logger.error("AI search error: #{e.message}")
    flash.now[:alert] = "Search temporarily unavailable. Please try again later."
    @recipes = current_user.recipes.none
    render :index, status: :ok
  end

  # GET /recipes/1 - RPG-style recipe detail
  def show
  end

  private
    def set_recipe
      @recipe = current_user.recipes.find(params.expect(:id))
    end
end
