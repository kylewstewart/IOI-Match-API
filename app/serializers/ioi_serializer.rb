class IoiSerializer < ActiveModel::Serializer
  attributes :id, :side, :stock, :time, :ranked_principals, :active

  def stock
    {id: object.stock_id, name: Stock.find(object.stock_id).name}
  end

  def time
    DateTime.parse(object.updated_at.to_s).strftime('%H:%M:%S')
  end

  def ranked_principals
    object.ranked_principal_ids.map{|id| Principal.find(id)}.map{|principal| {id: principal.id, name: principal.name}}
  end

  def active
    object.active ? "Active" : "Expired"
  end
end
