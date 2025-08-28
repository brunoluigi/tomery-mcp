# frozen_string_literal: true

class Tools::AddPantryItemsService
  def self.call!(user:, pantry_items:)
    user.pantry_items.create!(pantry_items)
  end
end
