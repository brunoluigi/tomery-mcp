# frozen_string_literal: true

class RemovePantryItemsService < ApplicationTool
  def self.call(user:, ids:)
    user.pantry_items.where(id: ids).destroy_all
  end
end
