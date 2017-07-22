class Api::V1::SponsorshipsController < ApplicationController

  def index
    agent = Agent.find(params['agent_id'])
    sponsorships = agent.sponsorships
    render json: sponsorships
  end


end
