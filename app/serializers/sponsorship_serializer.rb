class SponsorshipSerializer < ActiveModel::Serializer
  attributes :id, :principal_id, :principal_name, :pct_traded

  def principal_id
    principal.id
  end

  def principal_name
    principal.name
  end

  def pct_traded
    negotiation_count = principal.negotiations.where(active: false).count
    return 'N/A' if negotiation_count == 0
    trade_count = principal.negotiations.where(traded: true, active: false).count
    return "0.00%" if trade_count == 0
    pct_traded = trade_count / negotiation_count.to_f
    '%.2f' % (pct_traded * 100) + "%"
  end

  def principal
    principal ||= Principal.find(object.principal_id)
  end
end
