class Api::V1::SponsorshipsController < ApplicationController

  def principals_index
    principal = Principal.find(params['principal_id'])
    sponsorships = principal.sponsorships.map{|s|Agent.find(s.agent_id)}
    render json: sponsorships
  end


end
