require 'serverspec'

$LOAD_PATH.concat Dir.glob('/opt/chef/embedded/lib/ruby/gems/2.1.0/gems/*/lib')
require 'ohai'

# Setup proper path for sudo environment
path = ENV['PATH'].split(":")
["/sbin", "/usr/sbin", "/usr/local/sbin"].each do |dir|
  if !path.include?(dir)
    path.insert(0, dir)
  end
end
ENV['PATH'] = path.join(":")

PLUGIN_PATH = "/opt/ohai-plugins/plugins"
Ohai::Config[:plugin_path] << PLUGIN_PATH

ohai = Ohai::System.new
ohai.all_plugins
$ohaidata = ohai.data

set :backend, :exec