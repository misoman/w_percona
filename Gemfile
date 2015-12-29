source 'https://rubygems.org'

chef_version = ENV.fetch("CHEF_VERSION", "12.6.0")

gem "chef", "~> #{chef_version}"
gem 'chefspec'
gem 'chef-zero'
gem 'berkshelf'
gem 'foodcritic'
gem 'rake'
gem 'rubocop'
gem 'byebug'

group :integration do
  gem 'serverspec'
  gem 'kitchen-vagrant'
  gem 'vagrant-wrapper'
  gem 'kitchen-sync'
  gem 'test-kitchen'
end
