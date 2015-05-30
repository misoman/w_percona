
task default: "test"

desc "Run all tests"
task all_tests: [
  :foodcritic, :chefspec
]

# rubocop style checker
require "rubocop/rake_task"
RuboCop::RakeTask.new

# foodcritic chef lint
require "foodcritic"
FoodCritic::Rake::LintTask.new

# chefspec unit tests
require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:chefspec) do |t|
  t.rspec_opts = "--color --format progress"
end
