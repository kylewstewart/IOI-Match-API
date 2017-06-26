class Api::V1::NegotationsController < ApplicationController

  def index
    principal = Principal.find(params['principal_id'])
    negotiations = principal.negotiations
    render json: negotiations
  end

end
