class BusinessRepresenter < Napa::Representer
  property :id, type: String
  property :name, type: String
  property :address, type: String
  property :city, type: String
  property :state, type: String
  property :zip, type: String
  property :website, type: String
  property :phone, type: String
end
