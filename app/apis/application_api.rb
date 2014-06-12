class ApplicationApi < Grape::API
  format :json
  extend Napa::GrapeExtenders

  mount BusinessesApi => '/businesses'
  mount ApiKeysApi => '/api_keys'
  mount AuthApi => '/auth'

  add_swagger_documentation
end
