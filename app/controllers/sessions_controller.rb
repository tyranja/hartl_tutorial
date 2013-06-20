class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by_email(params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # sign the user in and redirect to the user's show page
    else
      flash.now[:error] = 'Invalid email/password combination' 
      render 'new'
      # Create an message and re-render the singin form
    end
  end

  def destroy
  end
  
end
