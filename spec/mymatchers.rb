def add_w_varnish_vmod(vmod)
  ChefSpec::Matchers::ResourceMatcher.new(:w_varnish_vmod, :add, vmod)
end

def add_monit_config(service)
  ChefSpec::Matchers::ResourceMatcher.new(:monit_monitrc, :create, service)
end