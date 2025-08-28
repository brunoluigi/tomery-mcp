require 'rails_helper'

RSpec.describe UserToggleActiveService do
  subject(:tool) { described_class.new }
  let(:user) { FactoryBot.create(:user, active: false) }

  it 'should toggle user active state' do
    expect {
      UserToggleActiveService.call!(user:)
    }.to change { user.reload.active }
  end

  it 'should queue user activation mailer' do
    expect {
      UserToggleActiveService.call!(user:)
    }.to enqueue_mail(UserMailer, :activated)
  end

  it 'should destroy user sessions' do
    user.update(active: true)
    user.sessions.create!

    expect {
      UserToggleActiveService.call!(user:)
    }.to change(user.sessions, :count).from(1).to(0)
  end
end
