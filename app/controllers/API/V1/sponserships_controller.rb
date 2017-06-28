class Api::V1::SponsershipsController < ApplicationController

  def principals_index
    principal = Principal.find(params['principal_id'])
    sponserships = principal.sponserships.map{|s|Agent.find(s.agent_id)}
    render json: sponserships
  end

  def agents_index
    agent = Agent.find(params['agent_id'])
    sponserships = agent.sponserships.map{|s|Principal.find(s.principal_id)}
    render json: sponserships
  end

end
