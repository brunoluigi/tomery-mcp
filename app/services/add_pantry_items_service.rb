# frozen_string_literal: true

class AddPantryItemsService < ApplicationTool
  def self.call!(user:, pantry_items:)
    user.pantry_items.create!(pantry_items)
  end
end
