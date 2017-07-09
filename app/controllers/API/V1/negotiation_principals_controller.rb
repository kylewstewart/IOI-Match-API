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
      rating: negotiation_principal.rating
    }


  end

  def update_traded
    negotiation_principal = NegotiationPrincipal.find(params['id'])
    negotiation_principal.update(traded: params['traded'])
    render json: negotiation_principal
  end

  def update_rating
    negotiation_principal = NegotiationPrincipal.where(negotiation_id: params['negotiation_id'],
      principal_id: params['principal_id']).first
    negotiation_principal.update(rating: params['rating'])
    render json: negotiation_principal

  end


end
