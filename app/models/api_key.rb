class ApiKey < ActiveRecord::Base
  include Napa::FilterByHash
  belongs_to :user
  before_create :create_access_token
  before_create :set_expires_at

  def expired?
    DateTime.now >= expires_at
  end

  private

  def create_access_token
    begin
      self.access_token = SecureRandom.hex
    end while self.class.exists?(access_token: access_token)
  end

  def set_expires_at
    self.expires_at = DateTime.now + 30.days
  end
end
