class HomeController < ApplicationController
  def index
  end

  def broadcast
    ActionCable.server.broadcast("chat", { msg: params[:msg], at: Time.now.to_s })
    head :ok
  end
end
