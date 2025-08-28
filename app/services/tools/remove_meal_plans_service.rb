# frozen_string_literal: true

class Tools::RemoveMealPlansService
  def self.call(user:, ids:)
    user.meal_plans.where(id: ids).destroy_all
  end
end
