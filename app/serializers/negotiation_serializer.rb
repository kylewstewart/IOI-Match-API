class NegotiationSerializer < ActiveModel::Serializer
  attributes :id, :agent_id, :agent_name, :active, :stock_id, :time, :exch_code

  def agent_name
    agent = Agent.find(object.agent_id)
    agent.name
  end

  def exch_code
    stock = Stock.find(object.stock_id)
    stock.exch_code
  end

  def time
    DateTime.parse(object.updated_at.to_s).strftime('%H:%M:%S')
  end
end
