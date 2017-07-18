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
    id = params['id'].to_i
    matches = Negotiation.get_matches
    match = matches.select{|stock_id| stock_id == id}[id]
    render json: match, each_serializer: MatchSerializer
  end

  def common
    binding.pry
    iois = params['matchStocks'].map{|ioi| ioi.id}
    common = Negotiation.get_common_broker(iois)
  end

end
