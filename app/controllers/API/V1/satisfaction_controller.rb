class Api::V1::SatisfactionController < ApplicationController

  def index
    agent = Agent.find(params['agent_id'])
    satisfactions = agent.negotiations.map{|n| n.negotiation_principals}.flatten.map{|np| np.satisfaction}
    avg_satisfaction = satisfactions.inject{|sum, sat| sum + sat }.to_f / satisfactions.length

    render json: {satisfaction: "#{avg_satisfaction}"}
  end
end
