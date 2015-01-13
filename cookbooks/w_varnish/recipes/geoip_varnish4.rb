include_recipe "apt-repo"
ppa "chris-lea/python-geoip2"

package "libmaxminddb-dev"
package "automake"
package "autoconf"
package "build-essential"
package "libtool"

uv_varnish_vmod "GeoIP" do
  source "https://github.com/simonvik/libvmod_maxminddb"
  packages %w(libgeoip-dev libvarnishapi-dev python-docutils) if platform_family?('debian')
end

remote_file "/etc/varnish/GeoIP2-City.mmdb" do
  source node['w_varnish']['geoip']['db_file_url']
end