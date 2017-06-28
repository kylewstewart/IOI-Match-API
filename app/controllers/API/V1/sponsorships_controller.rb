class Api::V1::SponsorshipsController < ApplicationController

  def principals_index
    principal = Principal.find(params['principal_id'])
    sponsorships = principal.sponsorships.map{|s|Agent.find(s.agent_id)}
    render json: sponsorships
  end

  def agents_index
    agent = Agent.find(params['agent_id'])
    sponsorships = agent.sponsorships.map{|s|Principal.find(s.principal_id)}
    render json: sponsorships
  end

end
