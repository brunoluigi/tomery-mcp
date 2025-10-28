class MealPlansController < ApplicationController
  before_action :set_meal_plan, only: %i[ show destroy ]

  # GET /meal_plans - RPG-style meal planning
  def index
    @meal_plans = current_user.meal_plans.order(date: :asc)
  end

  # GET /meal_plans/1
  def show
  end

  # GET /meal_plans/new
  def new
    @meal_plan = current_user.meal_plans.new
  end

  # POST /meal_plans
  def create
    @meal_plan = current_user.meal_plans.new(meal_plan_params)

    if @meal_plan.save
      redirect_to meal_plans_path, notice: "Meal plan was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /meal_plans/1
  def destroy
    @meal_plan.destroy!
    redirect_to meal_plans_path, notice: "Meal plan was successfully destroyed.", status: :see_other
  end

  private
    def set_meal_plan
      @meal_plan = current_user.meal_plans.find(params.expect(:id))
    end

    def meal_plan_params
      params.require(:meal_plan).permit(:date, :recipe_id, :meal_type)
    end
end
