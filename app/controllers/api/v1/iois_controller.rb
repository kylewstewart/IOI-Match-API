class Api::V1::IoisController < ApplicationController

  def index
    principal = Principal.find(params['principal_id'])
    iois = principal.iois.where(active: true)
    render json: iois
  end

  def create
    ranked_agent_ids = params['IOI']['rankedAgents']
      .map{|name| Agent.find_by(name: name).id}
    stock_id = Stock.find_by(exch_code: params['IOI']['stock']).id
    side = params['IOI']['side']
    principal_id = params['principal_id']
    ioi = Ioi.create(principal_id: principal_id, ranked_agent_ids: ranked_agent_ids,
        stock_id: stock_id, side: params['IOI']['side'], active: true)
    Negotiation.match
    render json: ioi
  end

  def update
    ioi = Ioi.find(params['IOI']['id'])
    ranked_agent_ids = params['IOI']['rankedAgents']
      .map{|name| Agent.find_by(name: name).id}
    stock_id = Stock.find_by(exch_code: params['IOI']['stock']).id
    side = params['IOI']['side']
    ioi.update(ranked_agent_ids: ranked_agent_ids, stock_id: stock_id, side: side)
    Negotiation.match
    render json: ioi
  end

  def destroy
    ioi = Ioi.find(params['id'])
    ioi.update(active: false)
    render json: ioi
  end

end
