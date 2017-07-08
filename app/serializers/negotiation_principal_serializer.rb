class NegotiationPrincipalSerializer < ActiveModel::Serializer
  attributes :id, :name, :side, :satisfaction, :traded

  def name
    Principal.find(object.principal_id).name
  end

end
