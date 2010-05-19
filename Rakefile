begin
  require 'cucumber/rake/task'

  Cucumber::Rake::Task.new do |t|
    t.cucumber_opts = "--require features/"
  end
rescue LoadError
end

require 'rubygems'
require 'rake'
$LOAD_PATH.unshift 'lib'
require 'cucumber/formatter/json/version'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.version = Cucumber::Formatter::JSON::VERSION
  gem.name = "cucumber-json"
  gem.summary = %Q{A cucumber formatter that outputs JSON}
  gem.description = %Q{A cucumber formatter that outputs JSON}
  gem.email = "jnewland@gmail.com"
  gem.homepage = "http://github.com/jnewland/cucumber-json"
  gem.authors = ["Jesse Newland"]
  gem.add_dependency "cucumber", "~> 0.6.3"
  gem.add_dependency "json", "~> 1.2.1"
  gem.test_files.include 'features/**/*'
  gem.test_files.exclude 'examples/self_test/tmp/features'
  # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
end
Jeweler::GemcutterTasks.new

task :cucumber => :check_dependencies

task :default => :cucumber
