class Api::V1::SponsorsController < ApplicationController

  def index
    principal = Principal.find(params['principal_id'])
    sponsors = principal.sponsorships
    render json: sponsors, each_serializer: SponsorSerializer
  end

end
