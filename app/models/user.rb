class User < ActiveRecord::Base
  include Napa::FilterByHash
  has_secure_password

  validates_presence_of :name, :email
  validates_presence_of :password, on: :create
end
