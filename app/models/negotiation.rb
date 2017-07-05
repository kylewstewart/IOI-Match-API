class Negotiation < ApplicationRecord
  belongs_to :agent
  has_many :negotiation_principals
  has_many :principals, through: :negotiation_principals


  def self.match
    matches = get_matches
    return false if !matches
    negotiations = self.get_negotiations(matches)
    return false if !negotiations
    negotiations
  end

  def self.get_matches
    iois_by_stk = Ioi.where(active: true).group_by(&:stock_id)
    matches = iois_by_stk.select{|stk_id, iois|iois.select{|ioi|ioi.side=="Buy"}
      .count!=0 && iois.select{|ioi|ioi.side=="Sell"}.count!=0}
    matches.empty? ? false : matches
  end

  def self.get_negotiations(matches)
    negotiations = []
    matches.each do |stock_id, iois|
      agent_id = self.get_pref_broker(iois)
      next if !agent_id
      negotiation = Negotiation.create(agent_id: agent_id, stock_id: stock_id, active: true)
      self.add_particitpants(iois, negotiation)
      negotiations << negotiation
    end
    !negotiations.empty? ? negotiations : false
  end

  def self.get_pref_broker(iois)
    common = self.get_common_brokers(iois)
    return false if !common
    ranked_agents = iois.map{|ioi| ioi.ranked_agent_ids}
    self.ranked_voting(ranked_agents, common)
  end

  def self.get_common_brokers(iois)
    freq = iois.map{|ioi|ioi.ranked_agent_ids}.flatten.inject(Hash.new(0)){|h,v|h[v] += 1;h}
    count = iois.count
    while count > 1 do
      common = freq.select{|k,v| v == count}
      common = remove_no_buyer_or_no_seller(common, iois)
      break if !common.empty?
      count -= 1
    end
    common.empty? ? false : common.map{|k,v| k}
  end

  def self.remove_no_buyer_or_no_seller(common, iois)
    return common if common.empty?
    common.select do |agent_id, freq|
      buys = iois.select{|ioi|ioi.side=="Buy"}.map{|ioi|ioi.ranked_agent_ids}.select{|ranked_agent_ids|ranked_agent_ids.include?(agent_id)}
      sells = iois.select {|ioi|ioi.side == "Sell"}.map{|ioi|ioi.ranked_agent_ids}.select{|ranked_agent_ids|ranked_agent_ids.include?(agent_id)}
      !buys.empty? && !sells.empty?
    end
  end

  def self.ranked_voting(ranked_agents, canidates, round=1)
    votes = ranked_agents.map{|agents| agents & canidates}.map{|agents| agents[0]}.compact
    vote_freq = votes.each_with_object(Hash.new(0)){|key,hash| hash[key] += 1}
    sorted_vote_count = vote_freq.map{|agent_id, count| count}.sort

    if sorted_vote_count[-1] >= self.majority(votes.count)
      return vote_freq.select{|agent_id, votes| votes == sorted_vote_count[-1]}.map{|agent_id, votes| agent_id}.first
    else
      losers = vote_freq.select{|agent_id, votes| votes == sorted_vote_count[0]}.map{|agent_id, votes| agent_id}
      losers = tiebreaker(ranked_agents, losers) if losers.count > 1
      remaining_canidaties = canidates.select{|agent_id| agent_id != losers.first}
      self.ranked_voting(ranked_agents, remaining_canidaties, round + 1)
    end
  end

  def self.tiebreaker (ranked_agents, losers, index=0)
    max_index = ranked_agents.max_by(&:length).count
    while index < max_index
      votes = ranked_agents.map{|agents| agents & losers}.map{|agents| agents[0..index]}.compact.flatten
      vote_freq = votes.each_with_object(Hash.new(0)){|key,hash| hash[key] += 1}
      sorted_vote_count = vote_freq.map{|agent_id, count| count}.sort
      losers = vote_freq.select{|agent_id, votes| votes == sorted_vote_count[0]}.map{|agent_id, votes| agent_id}
      return losers.first if losers.count == 1
      index += 1
      self.tiebreaker(ranked_agents, losers, index)
    end
    losers.shuffle.first
  end

  def self.majority(count)
    count % 2 == 0 ? (count / 2) + 1 : (count /2.0).round
  end

  def self.add_particitpants(iois, negotiation)
    iois.each do |ioi|
      if ioi.ranked_agent_ids.include?(negotiation.agent_id.to_s)
        NegotiationPrincipal.create(negotiation_id: negotiation.id, principal_id: ioi.principal_id, side: ioi.side)
      else
        next
      end
    end

  end


end
