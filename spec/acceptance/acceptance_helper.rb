require 'spec_helper'
require 'steak'
require 'capybara/rails'
require 'capybara/dsl'

module Steak::Capybara
  include Rack::Test::Methods
  include Capybara::DSL
  
  def app
    ::Rails.application
  end
end

RSpec.configuration.include Steak::Capybara, :type => :acceptance

# Put your acceptance spec helpers inside /spec/acceptance/support
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
