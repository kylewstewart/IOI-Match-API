class Api::V1::NegotiationsController < ApplicationController

  def principals_index
    principal = Principal.find(params['principal_id'])
    negotiations = principal.negotiations
    render json: negotiations
  end

  def agents_index
    agent = Agent.find(params['agent_id'])
    negotations = agent.negotiations
    render json: negotations
  end

  def update
    negotiation = Negotiation.find(params['id'])
    negotiation.update(active: params['active'], traded: params['traded'])
    render json: negotiation
  end

end
