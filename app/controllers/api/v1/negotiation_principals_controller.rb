class Api::V1::NegotiationPrincipalsController < ApplicationController

  def index
    negotiation = Negotiation.find(params['negotiation_id'])
    negotiation_principals = negotiation.negotiation_principals
    render json: negotiation_principals
  end

  def show
    negotiation_principal = NegotiationPrincipal.where(negotiation_id: params['negotiation_id'],
      principal_id: params['principal_id']).first
    render json: {
      neg_id: negotiation_principal.negotiation_id,
      rating: negotiation_principal.rating,
      traded: negotiation_principal.traded
    }
  end

  def update_traded
    neg_prin = NegotiationPrincipal.find(params['id'])
    neg_prin.update(traded: params['traded'])
    update_ioi(neg_prin)
    render json: neg_prin
  end

  def update_rating
    negotiation_principal = NegotiationPrincipal.where(negotiation_id: params['negotiation_id'],
      principal_id: params['principal_id']).first
    negotiation_principal.update(rating: params['rating'])
    render json: negotiation_principal
  end

  def update_ioi(neg_prin)
    prin_id = neg_prin.principal_id
    stock_id = neg_prin.negotiation.stock_id
    ioi = Ioi.where(principal_id: prin_id, stock_id: stock_id)[0]
    ioi.ranked_agent_ids.include?(neg_prin.negotiation.agent_id.to_s) ? ioi.update(active: false) : false
  end


end
