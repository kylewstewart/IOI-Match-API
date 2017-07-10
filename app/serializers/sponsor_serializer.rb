class SponsorSerializer < ActiveModel::Serializer
  attributes :id, :agent_id, :agent_name, :pct_traded, :rating

  def agent_id
    agent.id
  end

  def agent_name
    agent.name
  end

  def pct_traded
    negotiations = agent.negotiations.where(active: false)
    neg_prins = negotiations.map{|neg| neg.negotiation_principals}.flatten
    return 'n/a' if neg_prins.count == 0
    trade_count = neg_prins.select{|np| !!np.traded}.count
    return "0%" if trade_count == 0
    pct_traded = trade_count / neg_prins.count.to_f
    '%.0f' % (pct_traded * 100) + "%"
  end

  def rating
    negotiations = agent.negotiations.map{|n| n.negotiation_principals}.flatten
    ratings = negotiations.map{|np| np.rating}.compact
    return 'n/a' if ratings.length == 0
    rating = ratings.inject{|sum, sat| sum + sat }.to_f / ratings.length
    '%.2f' % (rating.round(2))
  end


  def agent
    agent ||= Agent.find(object.agent_id)
  end

end
