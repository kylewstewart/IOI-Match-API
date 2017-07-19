class Negotiation < ApplicationRecord
  belongs_to :agent
  has_many :negotiation_principals
  has_many :principals, through: :negotiation_principals

  ##  MATCH
  #   Algorithm begins here
  #   Calls #get_matches which returns all Matches (IOIs from same stock that contain at least on buy and one sell). Returns false if none.
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
    iois_by_stock = Ioi.where(active: true).group_by(&:stock_id)
    matches = iois_by_stock.select do |stock_id, iois|
      buy = false
      sell = false
      iois.each {|ioi| ioi.side == "Buy" ? buy = true : sell = true}
      buy && sell
    end
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
      common = []
      freq.each do |agent_id, agent_count|
        if agent_count == count
            common << agent_id if self.buyer_and_seller?(agent_id, iois)
        end
      end
      break if !common.empty?
      count -= 1
    end
    common.empty? ? false : common
  end

  ##  REMOVE_NO_BUYER_OR_NO_SELLER
  #   Receives all common brokers and IOIs for a given match from #Get_common_broker
  #   Seperates IOI between buys and sells
  #   Collects ranked broker lists
  #   Iterates over list of common brokers
  #     Interates over array of buy ranked borker list and selects those that include common broker
  #     Interates over array of sell ranked borker list and selects those that include common broker
  #     return true and the common broker if neither buy or sell lists are empty
  def self.buyer_and_seller?(agent_id, iois)
    buys = []
    sells = []
    iois.each do |ioi|
      if ioi.ranked_agent_ids.include?(agent_id)
        ioi.side == 'Buy' ? buys << agent_id : sells << agent_id
      end
    end
    !buys.empty? && !sells.empty?
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
  def self.ranked_voting(ranked_canidates, canidates)
    filtered_agents = ranked_canidates.map{|agents| agents & canidates}
    votes = filtered_agents.map{|agents| agents[0]}.compact
    vote_count_with_max = self.votes_with_max(votes)
    if vote_count_with_max[:max] >= self.majority(votes.count)
      return self.get_winner(vote_count_with_max[:freq], vote_count_with_max[:max])
    else
      min = self.min_votes(vote_count_with_max[:freq])
      losers = self.get_losers(vote_count_with_max[:freq], min)
      losers.count > 1 ? loser = tiebreaker(ranked_canidates, losers) : loser = losers.first
      remaining_canidaties = canidates.select{|agent_id| agent_id != loser}
      self.ranked_voting(ranked_canidates, remaining_canidaties)
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
      vote_count = self.votes(votes)
      min = self.min_votes(vote_count)
      losers = self.get_losers(vote_count, min)
      return losers.first if losers.count == 1
      index += 1
      self.tiebreaker(ranked_canidates, losers, index)
    end
    losers.shuffle.first
  end

  def self.majority(count)
    count % 2 == 0 ? (count / 2) + 1 : (count /2.0).round
  end

  def self.votes(votes)
  freq = {}
  i = 0
  while i < votes.length do
    !freq[votes[i]] ? freq[votes[i]] = 1 : freq[votes[i]] += 1
    i += 1
  end
  return freq
end

def self.votes_with_max(votes)
  freq = {}
  max = 0
  i = 0
  while i < votes.length do
    !freq[votes[i]] ? freq[votes[i]] = 1 : freq[votes[i]] += 1
    max = freq[votes[i]] if freq[votes[i]] > max
    i += 1
  end
  return {freq: freq, max: max}
end

def self.max_votes(freq)
  max = 0
  freq.each{|candiate, votes| max = votes if votes > max }
  return max
end

def self.min_votes(freq)
  min = 1000000
  freq.each{|candiate, votes| min = votes if votes < min }
  return min
end

def self.get_winner (freq, max)
  winner = ''
  freq.each {|canidate, votes| winner = canidate if votes == max}
  return winner
end

def self.get_losers(freq, min)
  losers = []
  freq.each {|canidate, votes| losers.push(canidate) if votes == min}
  return losers
end




end
