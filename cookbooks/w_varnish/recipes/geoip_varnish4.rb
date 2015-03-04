include_recipe "apt-repo"
ppa "chris-lea/python-geoip2"
ppa "maxmind/ppa"

package "libmaxminddb-dev"
package "automake"
package "autoconf"
package "build-essential"
package "libtool"

db_source = node['w_varnish']['geoip']['db_file_url']
db_dest = '/etc/varnish/GeoIP2-City.mmdb'

unless node['w_varnish']['geoip']['auto_update'] then


  if db_source.end_with? 'GeoLite2-City.mmdb.gz' then
    # downloading maxmind geoip db free version
    remote_file db_dest + '.gz' do
      source db_source
    end

    execute 'gzip -d ' + db_dest + '.gz' do
      creates db_dest
    end
  else
    # downloading maxmind geoip db paid version
    remote_file db_dest do
      source db_source
    end
  end
else

  package "geoipupdate"

  geoip = data_bag_item('w_varnish', 'geoip')

  template "/etc/GeoIP.conf" do
    owner 'root'
    group 'root'
    mode 0644
    variables({
      :userid => geoip['maxmind_userid'],
      :licensekey => geoip['maxmind_licensekey']
    })
  end

  execute 'geoipupdate'

  cron_minute = Random.rand(60)
  cron_hour = Random.rand(24)
  cron_weekday = 1

  cron "auto update geoip db" do
    minute cron_minute.to_s
    hour cron_hour.to_s
    weekday cron_weekday.to_s
    command "geoipupdate && /etc/init.d/varnish restart"
  end

  link db_dest do
    to "/usr/share/GeoIP/GeoIP2-City.mmdb"
  end
end

w_varnish_vmod "GeoIP" do
  source "https://github.com/simonvik/libvmod_maxminddb"
  packages %w(libgeoip-dev libvarnishapi-dev python-docutils) if platform_family?('debian')
end