class Api::V1::AgentsController < ApplicationController

  def index
    agents = Agent.all
    render json: agents
  end
  
end
