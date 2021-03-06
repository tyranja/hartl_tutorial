require 'spec_helper'

describe "Authentication" do

  subject { page }

  describe "signin page" do
    before { visit signin_path }

    it { should have_selector('h1', text: 'Sign in') }
    it { should have_selector('title', text: 'Sign in') }
  end


  describe "signin" do
    before { visit signin_path }

    describe "with invalid information" do
      before { invalid_signin }

      it { should have_selector('title', text: 'Sign in') }
      it { should have_error_meassage('Invalid') }

      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_selector('div.alert.alert-error') }
      end
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before { valid_signin(user) }

      it { should have_selector('title', text: user.name) }

      it { should have_link('Users', href: users_path) }
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Settings', href: edit_user_path(user)) }
      it { should have_link('Sign out', href: signout_path) }
      
      it { should_not have_link('Sign in', href: signin_path) }

      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link('Sign in')}
      end
    end
  end

  describe "authorization" do

    describe "for signed in users" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in user }

      describe "using a 'new' action" do
        before { get new_user_path }
        specify { response.should redirect_to(root_path) }
        specify { flash[:notice]. should eql("Already logged in") }
      end

      describe "using a 'create' action" do
        before { post users_path }
        specify { response.should redirect_to(root_path) }
        specify { flash[:notice]. should eql("Already logged in") }
      end
    end

    describe "for non-signed-in users" do
      it { should_not have_link('Profile') }
      it { should_not have_link('Settings') }


      let(:user) { FactoryGirl.create(:user) }

      describe "in the users controller" do

        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_selector('title', text: 'Sign in') }

          describe "submitting to the update action" do
            before { put user_path(user) }
            specify { response.should redirect_to(signin_path) }
          end
        end

        describe "visiting the user index" do
          before { visit users_path }
          it { should have_selector('title', text: 'Sign in') }
        end
      end

      describe "when attempting to visit a proteced page" do
        before do 
          visit edit_user_path(user)
          fill_in "Email",      with: user.email
          fill_in "Password",   with: user.password
          click_button "Sign in"
        end

        describe "after signin in" do

          it "should render the desired proteced page" do
            page.should have_selector('title', text: 'Edit user')
          end

          describe "when signing in again" do
            before do
              delete signout_path
              visit signin_path
              fill_in "Email",  with: user.email
              fill_in "Password", with: user.password
              click_button "Sign in"
            end

            it "should render the default (profile) page" do
              page.should have_selector('title', text: user.name)
            end
          end
        end
      end
    end

    describe "as wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      before { sign_in user }

      describe "visiting Users#edit page" do
        before { visit edit_user_path(wrong_user) }
        it { should_not have_selector('title', text: full_title('Edit user')) }
      end

      describe "submitting a PUT request to the Users#update action" do
        before { put user_path(wrong_user) }
        specify { response.should redirect_to(root_path) }
      end
    end

    describe "for non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) {FactoryGirl.create(:user) }

      before { sign_in non_admin }

      describe "submitting a DELETE request to the Users#destroy action" do
        before {delete user_path(user) }
        specify { response.should redirect_to(root_path) }
      end
    end

    describe "admin user" do
      let(:admin)     { FactoryGirl.create(:admin) }
      let(:non_admin) {FactoryGirl.create(:user) }

      before { sign_in admin }

      describe "should not be able to destroy themselves" do
        before { delete user_path(admin) }

        specify { response.should redirect_to(users_path) }
        specify { flash[:error].should eql("You can not destroy yourself as an admin.") }
      end

      describe "should be able to destroy user" do
        before { delete user_path(non_admin) }

        specify { response.should redirect_to(users_path) }
        specify { flash[:success].should eql("User destroyed.") }
      end
    end  
  end
end
