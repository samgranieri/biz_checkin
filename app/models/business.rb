class Business < ActiveRecord::Base
  include Napa::FilterByHash

  validates_presence_of :name, :address, :city, :state, :zip, :website, :phone
  validates :waiting_period, numericality: { greater_than: 0, only_integer: true }

  has_many :checkins
end
