require 'json'
Then /^the output should contain "([^"]*)" set to "([^"]*)"$/ do |variable, value|
  Then 'STDERR should be empty'
  output = JSON.parse(last_stdout)
  eval(variable).to_s.should == value
end

Then /^the output should contain the failing feature$/ do |alert|
  Then 'STDERR should be empty'
  output = JSON.parse(last_stdout)
  output['failing_features'].should include(alert)
end

Then /^the output should contain no failing features$/ do
  Then 'STDERR should be empty'
  output = JSON.parse(last_stdout)
  output['failing_features'].should == []
end