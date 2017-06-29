class IoiSerializer < ActiveModel::Serializer
  attributes :id, :side, :stock, :time, :ranked_agents, :active

  def stock
    {id: object.stock_id, name: Stock.find(object.stock_id).name}
  end

  def time
    DateTime.parse(object.updated_at.to_s).strftime('%H:%M:%S')
  end

  def ranked_agents
    object.ranked_agent_ids.map{|id| Agent.find(id)}.map{|agent| {id: agent.id, name: agent.name}}
  end

  def active
    object.active ? "Active" : "Expired"
  end
end
