class Api::V1::NegotiationsController < ApplicationController

  def principals_index
    principal = Principal.find(params['principal_id'])
    negotiations = principal.negotiations
    principal_negotiations = []
    negotiations.map do |negotiation|
      negotiation_principal = NegotiationPrincipal.where(negotiation_id: negotiation.id, principal_id: principal.id).first
      time = DateTime.parse(negotiation.updated_at.to_s).strftime('%H:%M:%S')
      principal_negotiation = {
        neg_id: negotiation.id,
        exch_code: Stock.find(negotiation.stock_id).exch_code,
        agent_name: Agent.find(negotiation.agent_id).name,
        active: negotiation.active,
        time: time,
        rating: negotiation_principal.rating,
        traded: !negotiation_principal.traded ? 'No Trade' : 'Traded',
        neg_prin_id: negotiation_principal.id
      }
      principal_negotiations << principal_negotiation
    end
    render json: principal_negotiations
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
