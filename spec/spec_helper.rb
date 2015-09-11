require 'chefspec'
require 'chefspec/berkshelf'
require 'mymatchers'

ChefSpec::Coverage.start! do
  add_filter(%r{/vmware-tools/})
  add_filter(%r{/ntp/})
  add_filter(%r{/sudo/})
  add_filter(%r{/timezone-ii/})
  add_filter(%r{/apt/})
  add_filter(%r{/apt-repo/})
  add_filter(%r{/percona/})
  add_filter(%r{/xinetd/}) 
end

RSpec.configure do |config|
  config.platform = 'ubuntu'
  config.version = '14.04'
  config.filter_run_excluding skip: true
end
