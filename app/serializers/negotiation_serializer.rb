class NegotiationSerializer < ActiveModel::Serializer
  attributes :id, :agent_id, :agent_name, :active, :traded, :stock_id,
    :exch_code

  def agent_name
    agent = Agent.find(object.agent_id)
    agent.name
  end

  def active
    !object.active ? "Completed" : "Active"
  end

  def traded
    !object.traded ? "No Trade" : "Traded"
  end

  def exch_code
    stock = Stock.find(object.stock_id)
    stock.exch_code
  end
end
