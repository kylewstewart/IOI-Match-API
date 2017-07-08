class Api::V1::PrincipalsController < ApplicationController

  def index
    principals = Principal.all
    render json: principals
  end

  def negotiation_principals
    negotiation = Negotiation.find(params['negotiation_id'])
    negotiation_principals = negotiation.negotiation_principals
    render json: negotiation_principals
  end
end
