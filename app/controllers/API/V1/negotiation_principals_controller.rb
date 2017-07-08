class Api::V1::NegotiationPrincipalsController < ApplicationController

  def index
    negotiation = Negotiation.find(params['negotiation_id'])
    negotiation_principals = negotiation.negotiation_principals
    render json: negotiation_principals
  end

  def update
    negotiation_principal = NegotiationPrincipal.find(params['id'])
    negotiation_principal.update(params['key'].to_sym => params['value'])
    render json: negotiation_principal
  end


end
