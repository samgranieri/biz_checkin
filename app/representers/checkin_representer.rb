class CheckinRepresenter < Napa::Representer
  property :id, type: String
  property :created_at, type: DateTime
  property :business_id, type: String
  property :user_id, type: String
end
