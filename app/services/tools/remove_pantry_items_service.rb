# frozen_string_literal: true

class Tools::RemovePantryItemsService
  def self.call(user:, ids:)
    user.pantry_items.where(id: ids).destroy_all
  end
end
