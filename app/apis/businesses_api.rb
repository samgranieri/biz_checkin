class BusinessesApi < Grape::API
  helpers Authentication
  desc 'Get a list of businesses'
  params do
    optional :ids, type: String, desc: 'comma separated business ids'
  end
  get do
    businesses = Business.filter(declared(params, include_missing: false))
    represent businesses, with: BusinessRepresenter
  end

  desc 'Create an business'
  params do
    requires :name, type: String, desc: 'Business name'
    requires :address, type: String, desc: 'Business address'
    requires :city, type: String, desc: 'Business city'
    requires :state, type: String, desc: 'Business state'
    requires :zip, type: String, desc: 'Business zip'
    requires :website, type: String, desc: 'Business website'
    requires :phone, type: String, desc: 'Business phone'
    requires :waiting_period, type: String, desc: 'Business waiting_period'
  end

  post do
    authenticate!
    business = Business.create(declared(params, include_missing: false))
    error!(present_error(:record_invalid, business.errors.full_messages)) unless business.errors.empty?
    represent business, with: BusinessRepresenter
  end

  params do
    requires :id, desc: 'ID of the business'
  end
  route_param :id do
    desc 'Get an business'
    get do
      business = Business.find(params[:id])
      represent business, with: BusinessRepresenter
    end
    desc 'Update an business'
    params do
      optional :name, type: String, desc: 'Business name'
      optional :address, type: String, desc: 'Business address'
      optional :city, type: String, desc: 'Business city'
      optional :state, type: String, desc: 'Business state'
      optional :zip, type: String, desc: 'Business zip'
      optional :website, type: String, desc: 'Business website'
      optional :phone, type: String, desc: 'Business phone'
      optional :waiting_period, type: String, desc: 'Business waiting_period'
    end
    put do
      authenticate!
      # fetch business record and update attributes.  exceptions caught in app.rb
      business = Business.find(params[:id])
      business.update_attributes!(declared(params, include_missing: false))
      represent business, with: BusinessRepresenter
    end
    namespace :checkins do
      desc 'Get the number of checkins to business'
      params do
        requires :api_key, type: String, desc: "User's api key"
      end
      get do
        authenticate!
        business = Business.find_by!(id: params[:id])
        checkins = business.checkins.where(user_id: current_user.id)
        paginate checkins, with: CheckinRepresenter
      end

      desc 'Check into a business'
      params do
        requires :api_key, type: String, desc: "User's api key"
      end
      post do
        authenticate!
        business = Business.find_by!(id: params['id'])
        checkin = Checkin.create(business: business, user: current_user)
        if checkin.valid?
          $STATS.increment('successful_checkin')
          $STATS.increment("successful_checkin_for_business:#{business.id}")
          $STATS.increment("successful_checkin_for_zip:#{business.zip}")
        else
          if checkin.errors.full_messages_for(:base).include?("user checked in too soon")
            $STATS.increment('premature_checkin')
            $STATS.increment("premature_checkin_for_business:#{business.id}")
            $STATS.increment("premature_checkin_for_zip:#{business.zip}")
            error!(present_error(:record_invalid, checkin.errors.full_messages), 422)
          else
            error!(present_error(:record_invalid, checkin.errors.full_messages))
          end
        end
        represent checkin, with: CheckinRepresenter
      end
    end
  end
end
