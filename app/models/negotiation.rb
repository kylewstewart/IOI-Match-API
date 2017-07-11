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
  #   Recieves all Matches from #Match
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
  #   Recieves all IOIs for a Match from #Get_negotiations
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
  #   Recieves all IOIs for a Match from #Get_pref_broker
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
  #   Receives all common brokers and IOIs for a given match from #Get_common_broker
  #   Seperates IOI between buys and sells
  #   Collects ranked broker lists
  #   Iterates over list of common brokers
  #     Interates over array of buy ranked borker list and selects those that include common broker
  #     Interates over array of sell ranked borker list and selects those that include common broker
  #     return true and the common broker if neither buy or sell lists are empty
  def self.remove_no_buyer_or_no_seller(common, iois)
    return common if common.empty?
    buys = iois.select{|ioi|ioi.side == "Buy"}
    sells = iois.select {|ioi|ioi.side == "Sell"}
    buys_agent_ids = buys.map{|ioi|ioi.ranked_agent_ids}
    sells_agent_ids = sells.map{|ioi|ioi.ranked_agent_ids}
    common.select do |agent_id, freq|
      filtered_buys = buys_agent_ids.select{|ranked_agent_ids|ranked_agent_ids.include?(agent_id)}
      filtered_sells = sells_agent_ids.select{|ranked_agent_ids|ranked_agent_ids.include?(agent_id)}
      !filtered_buys.empty? && !filtered_sells.empty?
    end
  end

  ##  RANKED_VOTING
  #   Recieves array of ranked_canidates arrays(or brokers), array of canidates and set round to default 1
  #   Iterates thru ranked canidates array and removes any ranked candiate that is not included in canidates
  #   Collects most preferred canidate from each filtered_canidate array into one array of votes
  #   Groups canidates into frequency has with key: canidate and value: # of votes
  #   Iterates thru freq hash and puts each vote total into an array and sorts
  #   Checks if max vote count is a majortiy of votes
  #     if true finds canidate with max votes and returns canidate at the winner
  #     else:
  #       Finds the lowest vote count
  #       Checks for a tie if true calls #tiebreaker
  #       Canidate with the lowest vote total is removed from Canidates and makes a recursive call to
  #         #Ranked_voting with new Candidates and increments round by 1
  def self.ranked_voting(ranked_canidates, canidates, round=1)
    filtered_canidates = ranked_canidates.map{|agents| agents & canidates}
    votes = filtered_canidates.map{|agents| agents[0]}.compact
    vote_freq = votes.each_with_object(Hash.new(0)){|key,hash| hash[key] += 1}
    sorted_vote_count = vote_freq.map{|agent_id, count| count}.sort

    if sorted_vote_count[-1] >= self.majority(votes.count)
      return vote_freq.select{|agent_id, votes| votes == sorted_vote_count[-1]}.map{|agent_id, votes| agent_id}.first
    else
      losers = vote_freq.select{|agent_id, votes| votes == sorted_vote_count[0]}.map{|agent_id, votes| agent_id}
      losers = tiebreaker(ranked_canidates, losers) if losers.count > 1
      remaining_canidaties = canidates.select{|agent_id| agent_id != losers.first}
      self.ranked_voting(ranked_canidates, remaining_canidaties, round + 1)
    end
  end

  ## TIEBREAKER
  #  Receives ranked_canditate arrays, an array of losers and defaults index to 0
  #  Follows same steps as #ranked_voting to find a sorted_vote_count
  #  If lowest vote count is 1, returns lowest vote getting as the loser
  #  Else, makes a recursive call to #Tiebreaker with all losers with the lowest vote count
  #   and increments index by 1, so that the next round will count the first and second most preferred canidates
  #   recursive calls continue until their is a single lowest vote getter or all votes are counted.
  #   If their is never a single lowest vote getter, loser is chosen at radom.
  def self.tiebreaker (ranked_canidates, losers, index=0)
    max_index = ranked_canidates.max_by(&:length).count
    while index < max_index
      filtered_canidates = ranked_canidates.map{|agents| agents & losers}
      votes = filtered_canidates.map{|agents| agents[0..index]}.compact.flatten
      vote_freq = votes.each_with_object(Hash.new(0)){|key,hash| hash[key] += 1}
      sorted_vote_count = vote_freq.map{|agent_id, count| count}.sort

      losers = vote_freq.select{|agent_id, votes| votes == sorted_vote_count[0]}.map{|agent_id, votes| agent_id}
      return losers.first if losers.count == 1
      index += 1
      self.tiebreaker(ranked_canidates, losers, index)
    end
    losers.shuffle.first
  end

  ##  MAJORITY
  #   Called by #ranked_voting to determine the majority of votes
  def self.majority(count)
    count % 2 == 0 ? (count / 2) + 1 : (count /2.0).round
  end

  ## ADD_PARTICIPANTS
  #  Called by #get_negotiations and revieves all a match IOIs and the newly created Negotiation object
  #  Iterates thru IOIs and creates a NegotiationPrincipal for all Principal that that are included in the new Negotiation.
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
