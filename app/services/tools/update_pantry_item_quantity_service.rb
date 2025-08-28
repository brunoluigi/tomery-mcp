# frozen_string_literal: true

class Tools::UpdatePantryItemQuantityService
  def self.call!(user:, name:, quantity:)
    pantry_item = user.pantry_items.find_or_create_by!(name:)
    pantry_item.update!(quantity:)
  end
end
