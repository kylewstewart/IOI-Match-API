class Api::V1::SponsorsController < ApplicationController

  def index
    principal = Principal.find(params['principal_id'])
    sponsors = principal.sponsorships.map{|s|Agent.find(s.agent_id)}
    data = sponsors.map do |sponsor|
      sponsorship = Sponsorship.where(principal_id: principal.id, agent_id: sponsor.id).first
      { sponsorship_id: sponsorship.id,
        agent_id: sponsor.id,
        name: sponsor.name,
        pct_traded: agent_pct_traded(sponsor.id),
        satisfaction: satisfaction(sponsor.id)
      }
    end
    render json: data
  end

  def agent_pct_traded(id)
    agent = Agent.find(id)
    if !agent.negotiations.first
      return nil
    else
      trade_count = agent.negotiations.where(traded: true, active: false).count
      negotiation_count = agent.negotiations.where(active: false).count
      return 'N/A' if negotiation_count == 0
      return "0.00%" if trade_count == 0
      pct_traded = trade_count / negotiation_count.to_f
      return '%.2f' % (pct_traded * 100) + "%"
    end
  end

  def satisfaction(id)
    agent = Agent.find(id)
    if !agent.negotiations.first
      return nil
    else
      negotiations = agent.negotiations.map{|n| n.negotiation_principals}.flatten
      satisfactions = negotiations.map{|np| np.satisfaction}.compact
      return 'N/A' if satisfactions.length == 0
      satisfactions.inject{|sum, sat| sum + sat }.to_f / satisfactions.length
    end
  end

end
