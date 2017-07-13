
def add_principals
  ["Vangaurd", "Templeton", "Capital", "BlackRock", "T. Rowe Price", "Fidelity"].each{|name| Principal.create(name: name, password: "password")}
end

 # "Aberdeen Asset Management",  "JP Morgan Asset Management", "Fidelity International",  "Matthews International Capital Management", "Oppenheimer Funds",
# "Schroders Investment Management", "Lazard Asset Management",   "First State Investments", "Grantham, Mayo, Van Otterloo & Co.", "TIAA-CREF Investment Management", "Pictet Asset Management",
# "UBS Global Asset Management", "Nomura Asset Management", "Goldman Sachs Asset Management", "Baring Asset Management",  "Allianz Global Investors", "Principal Global Investors", "MFS Investment Management", "Morgan Stanley Investment Management",
# "Wasatch Advisors", "William Blair & Company", "Nordea Investment Management", "First Eagle Investment Management", "Deutsche Asset Management",
# "Thornburg Management", "Artisan Partners", "BNP Paribas Asset Management", "Wells Capital Management", "Driehaus Capital Management", "AllianceBernstein"

def add_agents
  ["Citi", "GS", "JPM", "MS"].each{|name| Agent.create(name: name, password: "password")}
end

# , "BAML", "UBS", "BarCap", "DB", "CS"

def add_stocks
  ["AAPL", "CSCO", "MSFT", "IBM", "INTC", "MMM", "AXP", "BA", "CAT", "CVX"].each{|exch_code| Stock.create(exch_code: exch_code, country: 'us')}
end

#  "KO", "DD", "XOM", "GE", "GS", "HD",  , "JNJ", "JPM", "MCD", "MRK",  "NKE", "PFE", "PG", "TRV", "UNH", "UTX", "VZ", "V", "WMT", "DIS"

def add_sponserships(num_per_principal)
  principals.each do |principal|
    agents.shuffle[0..num_per_principal - 1].map{|agent| Sponsorship.create(principal_id: principal.id, agent_id: agent.id)}
  end
end

def add_iois(num_per_principal)
  principals.each do |principal|
    stocks.shuffle[0..num_per_principal - 1].each do |stock|
      side = ["Buy", "Sell"].shuffle[0]
      Ioi.create(principal_id: principal.id, stock_id: stock.id, side: side,
      ranked_agent_ids: principal.sponsorships.map{|sp| sp.agent_id}.shuffle, side: side, active: true)
    end
  end
end

def add_negotiations
  agents.each do |agent|
    stock = stocks.shuffle.first
    neg = Negotiation.create(agent_id: agent.id, stock_id: stock.id, active: false, traded: true)
    prins = principals.shuffle
    buyers = prins[0..1]
    sellers = prins[2..3]
    rating = [1,2,3,4,5].shuffle.first
    traded = [true, false].shuffle.first
    buyers.each do |buyer|
      NegotiationPrincipal.create(negotiation_id: neg.id, principal_id: buyer.id,
      side: "Buy", rating: rating, traded: traded)
    end
    sellers.each do |buyer|
      NegotiationPrincipal.create(negotiation_id: neg.id, principal_id: buyer.id,
      side: "Sell", rating: rating, traded: traded)
    end
  end
end


def principals
  principals ||= Principal.all
end

def agents
  agents ||= Agent.all
end

def stocks
  stocks ||= Stock.all
end


add_principals
add_agents
add_stocks
add_negotiations
add_sponserships(3)
add_iois(5)

Negotiation.match

# principal = Principal.find(1)
# Ioi.create(principal_id: principal.id, stock_id: 1, side: 'Buy',
# ranked_agent_ids: [1,2,3], active: true)
#
# principal = Principal.find(2)
# Ioi.create(principal_id: principal.id, stock_id: 1, side: 'Buy',
# ranked_agent_ids: [1,2,3], active: true)
#
# principal = Principal.find(3)
# Ioi.create(principal_id: principal.id, stock_id: 1, side: 'Buy',
# ranked_agent_ids: [2,3,1], active: true)
#
# principal = Principal.find(4)
# Ioi.create(principal_id: principal.id, stock_id: 1, side: 'Sell',
# ranked_agent_ids: [2,3,1], active: true)
#
# principal = Principal.find(5)
# Ioi.create(principal_id: principal.id, stock_id: 1, side: 'Sell',
# ranked_agent_ids: [3,2,1], active: true)
#
# principal = Principal.find(6)
# Ioi.create(principal_id: principal.id, stock_id: 1, side: 'Sell',
# ranked_agent_ids: [3,2,1], active: true)
