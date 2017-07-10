class Negotiation < ApplicationRecord
  belongs_to :agent
  has_many :negotiation_principals
  has_many :principals, through: :negotiation_principals

  ##  MATCH
  #   Calls #get_matches to find all matches from IOIs in DB. Returns false if none exsist.
  #   Calls #get_negotiations to find and create new Negotiations from the set of Matches. Returns false if none exist.
  def self.match
    matches = get_matches
    return false if !matches
    negotiations = self.get_negotiations(matches)
    return false if !negotiations
    negotiations
  end

  ##  GET_MATCHES
  #   Retreives all active IOIs from DB and groups by stock.
  #   Adds IOIs, grouped by stock, to Matches when there are at least one buy and one sell IOI
  def self.get_matches
    iois_by_stk = Ioi.where(active: true).group_by(&:stock_id)
    matches = iois_by_stk.select{|stk_id, iois|iois.select{|ioi|ioi.side=="Buy"}.count!=0 && iois.select{|ioi|ioi.side=="Sell"}.count!=0}
    matches.empty? ? false : matches
  end

  ##  GET_NEGOTIATIONS
  #   Iterates over array of Matches
  #   Calls #get_pref_broker to find the most common preferred broker for each match. Return false if none exisit.
  #   Creates a new instance of a Negotiation that belongs to the preferred broker.
  #   Calls #add_particitpants to create an association between Principals and a Negotiation.
  #   Pushes the new Negotiation to the array Negotiations.
  #   Returns false if Negiations is empty
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

  ##  GET_PREF_BROKER
  #   Calls #get_common_brokers to find the most common broker.
  #   Returns false if no common broker exists
  #   Iterates over the the iois in a match and collects an array of broker preferance lists.
  #   Calls #ranked_voting to find and return the preferred most common broker.
  def self.get_pref_broker(iois)
    common = self.get_common_broker(iois)
    return false if !common
    ranked_agents = iois.map{|ioi| ioi.ranked_agent_ids}
    self.ranked_voting(ranked_agents, common)
  end

  ##  GET_COMMON_BROKER
  #   Collects the preferred broker lists (ranked_agent_ids) from each IOI into one array
  #   Creates a hash of key: broker(agent_id) and value: number of occurances.
  #   Interates over the range of the count of all brokers to 2.
  #     [Brokers count = max occurance and 2 = min occurance (must have at least on buyer and one seller)]
  #     1. Selects broker if occurance is equal to count
  #     2. Calls #remove_no_buyer_or_no_seller to check that at least one buyer and one seller is present
  #     3. Breaks loop iteration if 1 & 2 are true
  #   Returns false if no common broker is found.
  def self.get_common_broker(iois)
    all_brokers = iois.map{|ioi|ioi.ranked_agent_ids}.flatten
    freq = all_brokers.inject(Hash.new(0)){|h,v|h[v] += 1;h}
    count = iois.count
    while count > 1 do
      common = freq.select{|k,v| v == count}
      common = remove_no_buyer_or_no_seller(common, iois)
      break if !common.empty?
      count -= 1
    end
    common.empty? ? false : common.map{|k,v| k}
  end

  ##  REMOVE_NO_BUYER_OR_NO_SELLER
  #   

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
