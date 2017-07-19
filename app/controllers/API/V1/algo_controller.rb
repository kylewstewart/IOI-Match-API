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

  def ranked_voting
    canidates = params['common'].map{|agent| agent['name']}
    ranked_canidates = params['match'].map {|ioi| ioi ['ranked_agents']}
    results = {}
    round = 1
    winner = nil
    while !winner
      results[round] = ranked_voting_data(canidates, ranked_canidates)
      winner = results[round][:winner]
      loser = results[round][:loser]
      canidates = canidates.select{|agent_id| agent_id != loser} unless !loser
      round += 1
    end
    render json: results
  end

  def ranked_voting_data(canidates, ranked_canidates)
    filtered_ranked_canidates = ranked_canidates.map{|agents| agents & canidates}
    votes = filtered_ranked_canidates.map{|canidates| canidates[0]}.compact
    vote_count_with_max = Negotiation.votes_with_max(votes)
    if vote_count_with_max[:max] >= Negotiation.majority(votes.count)
      winner = Negotiation.get_winner(vote_count_with_max[:freq], vote_count_with_max[:max])
      loser = nil
    else
      winner = nil
      min = Negotiation.min_votes(vote_count_with_max[:freq])
      losers = Negotiation.get_losers(vote_count_with_max[:freq], min)
      losers.count > 1 ? loser = Negotiation.tiebreaker(ranked_canidates, losers) : loser = losers.first
    end
    data = {canidates: canidates, winner: winner, loser: loser, votes: vote_count_with_max[:freq]}
  end

end
