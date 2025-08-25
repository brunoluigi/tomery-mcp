# frozen_string_literal: true

class ListMealPlansService < ApplicationTool
  def self.call(user:, start_date:, end_date:)
    user.meal_plans.where(date: start_date..end_date)
  end
end
