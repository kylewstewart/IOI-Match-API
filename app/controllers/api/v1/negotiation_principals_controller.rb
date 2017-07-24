class Api::V1::NegotiationPrincipalsController < ApplicationController

  def index
    negotiation = Negotiation.find(params['negotiation_id'])
    negotiation_principals = negotiation.negotiation_principals
    render json: negotiation_principals
  end

  # def show
  #   negotiation_principal = NegotiationPrincipal.where(negotiation_id: params['negotiation_id'],
  #     principal_id: params['principal_id']).first
  #   render json: {
  #     neg_id: negotiation_principal.negotiation_id,
  #     rating: negotiation_principal.rating,
  #     traded: negotiation_principal.traded
  #   }
  # end

  def update
    neg_prin = NegotiationPrincipal.find(params['id'])
    neg_prin.update(update_params)
    render json: neg_prin
  end

  private

  def update_params
    params.require(:update).permit(:rating, :traded)

  end

end
