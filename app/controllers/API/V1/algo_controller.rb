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
    iois = params['match'].map{|ioi| Ioi.find(ioi['id'])}
    common = Negotiation.get_common_broker(iois).map{|id| Agent.find(id)}
    render json: common
  end

  private

  def match_params
    params.require(:match).permit(:id)

  end

end
