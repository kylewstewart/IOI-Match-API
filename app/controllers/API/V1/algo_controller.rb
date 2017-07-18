class Api::V1::AlgoController < ApplicationController

  def match_stocks
    matches = Negotiation.get_matches
    if !matches
      stocks = nil
    else
      stocks = matches.keys.map{|key| Stock.find(key)}
    end
    render json: stocks
  end

  def match
    matches = Negotiation.get_matches
    match = matches.select{|id| id == params['id'].to_i}
    render json: match, each_serializer: IoiSerializer
  end

end
