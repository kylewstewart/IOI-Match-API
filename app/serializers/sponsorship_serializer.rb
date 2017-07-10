class SponsorshipSerializer < ActiveModel::Serializer
  attributes :id, :principal_id, :principal_name, :pct_traded

  def principal_id
    principal.id
  end

  def principal_name
    principal.name
  end

  def pct_traded
    negotiations = principal.negotiation_principals.select{|np| np.negotiation.active == false}
    return 'n/a' if negotiations.count == 0
    trade_count = negotiations.select{|neg| !!neg.traded}.count
    return "0.0%" if trade_count == 0
    pct_traded = trade_count / negotiations.count.to_f
    '%.0f' % (pct_traded * 100) + "%"
  end

  def principal
    principal ||= Principal.find(object.principal_id)
  end
end
