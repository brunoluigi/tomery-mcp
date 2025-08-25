# frozen_string_literal: true

class RemoveMealPlansService < ApplicationTool
  def self.call(user:, ids:)
    user.meal_plans.where(id: ids).destroy_all
  end
end
