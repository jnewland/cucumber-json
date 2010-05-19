require 'yaml'
Then /^the output should contain "([^"]*)" set to "([^"]*)"$/ do |variable, value|
  output = YAML.load(last_stdout)
  eval(variable).to_s.should == value
end

Then /^the output should contain the alert$/ do |success, output|
  output = YAML.load(last_stdout)
  output[:alerts].should include(output)
end