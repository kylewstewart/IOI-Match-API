class Api::V1::NegotiationPrincipalsController < ApplicationController

  def index
    negotiation = Negotiation.find(params['negotiation_id'])
    negotiation_principals = negotiation.negotiation_principals
    render json: negotiation_principals
  end


  def update
    neg_prin = NegotiationPrincipal.find(params['id'])
    neg_prin.update(update_params)
    ioi = Ioi.where(principal_id: neg_prin.principal_id, side: neg_prin.side, active: false)[0]
    ioi.destroy unless !ioi
    # Deletes IOI so, algo controller can search active and non-active IOIs for matches.
    render json: neg_prin
  end

  private

  def update_params
    params.require(:update).permit(:rating, :traded)

  end

end
