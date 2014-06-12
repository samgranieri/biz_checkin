class ApiKeyRepresenter < Napa::Representer
  property :access_token, type: String, desc: 'api key for user'
end
