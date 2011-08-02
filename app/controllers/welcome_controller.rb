class WelcomeController < ApplicationController
  def index
  end

  def notfound
    redirect_to '/'
  end
end
