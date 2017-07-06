class SponsorSerializer < ActiveModel::Serializer
  attributes :id, :agent_id, :agent_name, :pct_traded, :satisfaction

  def agent_id
    agent.id
  end

  def agent_name
    agent.name
  end

  def pct_traded
    negotiation_count = agent.negotiations.where(active: false).count
    return 'N/A' if negotiation_count == 0
    trade_count = agent.negotiations.where(traded: true, active: false).count
    return "0.00%" if trade_count == 0
    pct_traded = trade_count / negotiation_count.to_f
    '%.2f' % (pct_traded * 100) + "%"
  end

  def satisfaction
    negotiations = agent.negotiations.map{|n| n.negotiation_principals}.flatten
    satisfactions = negotiations.map{|np| np.satisfaction}.compact
    return 'N/A' if satisfactions.length == 0
    satisfactions.inject{|sum, sat| sum + sat }.to_f / satisfactions.length
  end


  def agent
    agent ||= Agent.find(object.agent_id)
  end

end
