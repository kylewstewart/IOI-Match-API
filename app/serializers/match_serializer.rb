class MatchSerializer < ActiveModel::Serializer
  attributes :id, :name, :side, :ranked_agents, :exch_code

  def name
    Principal.find(object.principal_id).name
  end

  def ranked_agents
    object.ranked_agent_ids.map{|id| Agent.find(id)}.map{|agent| agent.name}
  end

  def exch_code
    Stock.find(object.stock_id).exch_code
  end

end
