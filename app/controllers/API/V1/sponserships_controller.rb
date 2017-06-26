class Api::V1::SponsershipsController < ApplicationController

  def index
    principal = Principal.find(params['principal_id'])
    sponserships = principal.sponserships.map{|s|Agent.find(s.agent_id)}

    render json: sponserships
  end
end
