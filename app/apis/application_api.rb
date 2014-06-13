class ApplicationApi < Grape::API
  format :json
  extend Napa::GrapeExtenders

  mount BusinessesApi => '/businesses'
  mount ApiKeysApi => '/api_keys'
  mount AuthApi => '/auth'
  mount UsersApi => '/users'

  add_swagger_documentation
end
