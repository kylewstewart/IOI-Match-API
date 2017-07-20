class IoiSerializer < ActiveModel::Serializer
  attributes :id, :side, :stock, :ranked_agents, :time

  def stock
    Stock.find(object.stock_id).exch_code
  end

  def time
    DateTime.parse(object.updated_at.to_s).strftime('%H:%M:%S')
  end

  def ranked_agents
    object.ranked_agent_ids.map{|id| Agent.find(id)}.map{|agent| agent.name}
  end

  def active
    object.active ? "Active" : "Expired"
  end

end
