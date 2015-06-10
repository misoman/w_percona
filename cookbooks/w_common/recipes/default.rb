# php-dev, percona related packages and some other package needs latest updated packages
include_recipe 'apt'

# doc start handle bash vulnerability http://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2014-6271
package 'bash' do
  action :upgrade
end

package 'curl'

include_recipe 'sudo'
include_recipe 'w_common::users'
# user recipe needs to be executed before ntp because ntp create group ntp with git 111
include_recipe 'ntp'
include_recipe 'timezone-ii'

include_recipe 'vmware-tools::default' if node['w_common']['vmware-tools_enabled']
include_recipe 'w_common::hosts'


firewall 'ufw' do
  action :enable
end

firewall_rule 'ssh' do
  port     22
  protocol :tcp
  action   :allow
end