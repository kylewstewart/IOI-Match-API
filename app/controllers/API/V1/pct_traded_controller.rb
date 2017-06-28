class Api::V1::PctTradedController < ApplicationController

  def principals_index
    principal = Principal.find(params['principal_id'])
    pct_traded = principal.negotiations.where(traded: true).count / principal.negotiations.count.to_f
    render json: {pct_traded: '%.2f' % (pct_traded * 100) + "%"}
  end

  def agents_index
    agent = Agent.find(params['agent_id'])
    pct_traded = agent.negotiations.where(traded: true).count / agent.negotiations.count.to_f
    render json: {pct_traded: '%.2f' % (pct_traded * 100) + "%"}
  end
end
