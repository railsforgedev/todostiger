ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...

    # Add Rich Text content to fixtures
    def setup
      # Set up Rich Text content for Todo fixtures
      todos(:today).description = "This is a todo for today"
      todos(:yesterday).description = "This is a todo for yesterday"
      todos(:tomorrow).description = "This is a todo for tomorrow"
      todos(:completed).description = "This is a completed todo"
      todos(:urgent).description = "This is an urgent todo"
    end
  end
end
