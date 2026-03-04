class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]
  def home
    # @chat = Chat.find(params[:id])
  end
end
