
["Vangaurd Group", "Aberdeen Asset Management", "Templeton Investment", "JP Morgan Asset Management", "Fidelity International",
  "Capital Global", "Matthews International Capital Management", "BlackRock Investment Management", "Oppenheimer Funds",
  "Schroders Investment Management", "T. Rowe Price & Associates", "Lazard Asset Management", "Fidelity Management & Research",
  "First State Investments", "Grantham, Mayo, Van Otterloo & Co.", "TIAA-CREF Investment Management", "Pictet Asset Management",
  "Allianz Global Investors", "Principal Global Investors", "MFS Investment Management", "Morgan Stanley Investment Management",
  "UBS Global Asset Management", "Nomura Asset Management", "Goldman Sachs Asset Management", "Baring Asset Management",
  "Wasatch Advisors", "William Blair & Company", "Nordea Investment Management", "First Eagle Investment Management", "Deutsche Asset Management",
  "Thornburg Management", "Artisan Partners", "BNP Paribas Asset Management", "Wells Capital Management", "Driehaus Capital Management",
  "AllianceBernstein"].each{|name| Principal.create(name: name, password: "password")}

["Merrill Lynch", "Barclays Capital", "Citi", "Credit Suisse", "Deutsche Bank", "Goldman Sachs", "J.P. Morgan", "Morgan Stanley",
  "UBS"].each{|name| Agent.create(name: name, password: "password")}

["MMM", "AXP", "AAPL", "BA", "CAT", "CVX", "CSCO", "KO", "DD", "XOM", "GE", "GS", "HD", "IBM", "INTC", "JNJ", "JPM", "MCD",
  "MRK", "MSFT", "NKE", "PFE", "PG", "TRV", "UNH", "UTX", "VZ", "V", "WMT", "DIS"].each{|name| Stock.create(name: name)}

principals ||= Principal.all
agents ||= Agent.all
stocks ||= Stock.all

principals.each do |principal|
  random_agents = agents.shuffle
  for i in 0..4
    Sponsership.create(principal_id: principal.id, agent_id: random_agents[i].id)
  end
end

principals.each do |principal|
  stocks.each do |stock|
    side = ["Buy", "Sell"].shuffle[0]
    Ioi.create(principal_id: principal.id, stock: stock, side: side,
      ranked_eps: agents.shuffle, side: side, active: true)
  end
end
