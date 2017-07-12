
["Vangaurd", "Templeton", "Capital", "BlackRock", "T. Rowe Price", "Fidelity"].each{|name| Principal.create(name: name, password: "password")}

 # "Aberdeen Asset Management",  "JP Morgan Asset Management", "Fidelity International",  "Matthews International Capital Management", "Oppenheimer Funds",
# "Schroders Investment Management", "Lazard Asset Management",   "First State Investments", "Grantham, Mayo, Van Otterloo & Co.", "TIAA-CREF Investment Management", "Pictet Asset Management",
# "UBS Global Asset Management", "Nomura Asset Management", "Goldman Sachs Asset Management", "Baring Asset Management",  "Allianz Global Investors", "Principal Global Investors", "MFS Investment Management", "Morgan Stanley Investment Management",
# "Wasatch Advisors", "William Blair & Company", "Nordea Investment Management", "First Eagle Investment Management", "Deutsche Asset Management",
# "Thornburg Management", "Artisan Partners", "BNP Paribas Asset Management", "Wells Capital Management", "Driehaus Capital Management", "AllianceBernstein"



["Citi", "GS", "JPM", "MS", "BAML", "UBS"].each{|name| Agent.create(name: name, password: "password")}

# "BarCap",  "DB", "CS"

["MMM", "AXP", "AAPL", "BA", "CAT", "CVX", "CSCO", "KO", "DD", "XOM", "GE", "GS", "HD", "IBM", "INTC", "JNJ", "JPM", "MCD",
  "MRK", "MSFT", "NKE", "PFE", "PG", "TRV", "UNH", "UTX", "VZ", "V", "WMT", "DIS"].each{|exch_code| Stock.create(exch_code: exch_code, country: 'us')}

principals ||= Principal.all
agents ||= Agent.all
stocks ||= Stock.all

principals.each do |principal|
  agents.shuffle[0..2].map{|agent| Sponsorship.create(principal_id: principal.id, agent_id: agent.id)}
end

# principals.each do |principal|
#   stocks.shuffle[0..2].each do |stock|
#     side = ["Buy", "Sell"].shuffle[0]
#     Ioi.create(principal_id: principal.id, stock_id: stock.id, side: side,
#       ranked_agent_ids: principal.sponsorships.map{|sp| sp.agent_id}.shuffle, side: side, active: true)
#   end
# end

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

# Negotiation.match
