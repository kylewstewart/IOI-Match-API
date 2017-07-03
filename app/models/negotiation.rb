class Negotiation < ApplicationRecord
  belongs_to :agent
  has_many :negotiation_principals
  has_many :principals, through: :negotiation_principals

  def self.match
    grouped_iois = Ioi.where(active: true).group_by(&:stock_id)
    matches = self.get_matches(grouped_iois)
    return false if matches.empty?
    negatiations = self.create_negotiations(matches)
    return false if !negatiations

  end

  def self.get_matches(grouped_iois)
    grouped_iois.select do |stock_id, iois|
      iois.select{|ioi| ioi.side == "Buy"}.count != 0 &&
      iois.select{|ioi| ioi.side == "Sell"}.count != 0
    end
  end

  def self.create_negotiations(matches)
    matches.map do|stock_id, iois|
      agent_id = self.pref_broker(iois)
      return false if !agent_id
      negotation = Negotiation.create(agent_id: agent_id, stock_id: stock_id, active: true)
    end
  end

  def self.pref_broker(iois)
    common = self.common(iois)
    return false if !common
    most_pref = self.most_pref(iois, common)
  end

  def self.common(iois)
    freq = iois.map{|ioi|ioi.ranked_agent_ids}.flatten.inject(Hash.new(0)){|h,v|h[v] += 1;h}
    count = iois.count
    while count > 1 do
      common = freq.select{|k,v| v == count}
      break if !common.empty?
      count -= 1
    end
    common.empty? ? false : common.map{|k,v| k}
  end

  def self.most_pref(iois, common)
    buy_iois = iois.select {|ioi| ioi.side == "Buy"}
    sell_iois = iois.select {|ioi| ioi.side == "Sell"}
    binding.pry

  end


end
