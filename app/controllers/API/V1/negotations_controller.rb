class Api::V1::NegotationsController < ApplicationController

  def principals_index
    principal = Principal.find(params['principal_id'])
    negotiations = principal.negotiations
    render json: negotiations
  end

  def principals_show
    principal = Principal.find(params['principal_id'])
    negotation = principal.negotiations.where(id: params['id']).first
    render json: negotation
  end

  def agents_index
    agent = Agent.find(params['agent_id'])
    negotations = agent.negotiations
    render json: negotations
  end

end
