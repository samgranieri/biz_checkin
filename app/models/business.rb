class Business < ActiveRecord::Base
  include Napa::FilterByHash
  validates_presence_of :name, :address, :city, :state, :zip, :website, :phone
end
