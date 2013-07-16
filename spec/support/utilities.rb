include ApplicationHelper

def sign_in(user)
  visit signin_path
  fill_in "Email", with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"
  # Sign in when not using Capybara as well
  cookies[:remember_token] = user.remember_token
end

def valid_signin(user)
  fill_in "Email", with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"
end

def invalid_signin
  click_button "Sign in"
end

def valid_signup(user) #doesnt work
  fill_in "Name", with: user.name
  fill_in "Email", with: user.email
  fill_in "Password", with: user.password
  fill_in "Confirmation", with: user.password_confirmation
end


RSpec::Matchers.define :have_error_meassage do |message|
  match do |page|
    page.should have_selector('div.alert.alert-error', text: message)
  end
end

