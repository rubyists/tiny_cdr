# Define a subclass of Ramaze::Controller holding your defaults for all
# controllers

class Controller < Ramaze::Controller
  helper :xhtml, :user
  layout :main
  engine :Erubis
  trait :user_model => TinyCdr::Account
  private

  def login_first
    return if logged_in?
    redirect MainController.r(:login)
  end
end

# Here go your requires for subclasses of Controller:
require_relative 'main'
require_relative 'cdr'
require_relative 'recordings'
