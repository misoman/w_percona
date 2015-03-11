w_varnish_vmod 'Header' do
  source 'https://github.com/varnish/libvmod-header'
  branch '4.0'
  packages %w(libvarnishapi-dev python-docutils) if platform_family?('debian')
end