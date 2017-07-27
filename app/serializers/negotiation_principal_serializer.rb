class NegotiationPrincipalSerializer < ActiveModel::Serializer
  attributes :id, :name, :side, :rating, :traded, :negotiation_id, :principal_id

  def name
    Principal.find(object.principal_id).name
  end

end
