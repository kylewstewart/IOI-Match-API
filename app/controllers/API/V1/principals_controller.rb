class Api::V1::PrincipalsController < ApplicationController

  def index
    principals = Principal.all
    render json: principals

  end
end
