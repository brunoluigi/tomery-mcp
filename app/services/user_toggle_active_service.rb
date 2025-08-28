# frozen_string_literal: true

class UserToggleActiveService
  def self.call!(user:)
    user.toggle(:active).save!

    if user.active?
      UserMailer.activated(user).deliver_later
    else
      user.sessions.destroy_all
    end

    user
  end
end
