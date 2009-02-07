# -*- encoding: utf-8 -*- 
$KCODE = 'u'
require 'test/unit'

require File.dirname(__FILE__) + '/../lib/rutils'

# Load all the prereqs
integration_tests = ['rubygems', 'multi_rails_init'] + Dir.glob(File.dirname(__FILE__) + '/extras/integration_*.rb')

if ENV['NO_RAILS']
  integration_tests.reject! {|t| t.include?("rails") }
end

integration_tests.each do | integration_test |
  begin
    require integration_test
  rescue LoadError => e
    $stderr.puts "Skipping integration test #{File.basename(integration_test)} - deps not met (#{e.message})"
  end
end