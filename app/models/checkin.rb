class Checkin < ActiveRecord::Base
  include Napa::FilterByHash

  belongs_to :user
  belongs_to :business
  validates :business, presence: true
  validates :user, presence: true
  validate :user_needs_to_wait, on: :create

  scope :since, -> (current_time) {where('created_at > ?', current_time) }

  private

  def user_needs_to_wait
    if user && business
      if Checkin.filter(user: user, business: business).since(business.waiting_period.minutes.ago).any?
        errors.add(:base, 'user checked in too soon')
      end
    end
  end
end
