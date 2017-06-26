class Api::V1::IoisController < ApplicationController

  def index
    principal = Principal.find(params['principal_id'])
    iois = principal.iois
    render json: iois
  end

  def show
    principal = Principal.find(params['principal_id'])
    ioi =  principal.iois.find(params['id'])
    render json: ioi

  end
end
