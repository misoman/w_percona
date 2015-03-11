
# Cookbook Name:: varnish
# Provider:: vmod
# Author:: Matthew Thode <matt.thode@rackspace.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

action 'add' do
  vmod_name = ::File.basename(new_resource.source, '.git')
  if ::File.exist?("/usr/lib/varnish/vmods/#{vmod_name.gsub('-', '_')}.so")
    Chef::Log.info "vmod #{new_resource.name} added already, skipping."
  else
    @run_context.include_recipe 'build-essential'
    %w(libtool git).concat(new_resource.packages).each do |pkg|
      package pkg
    end
    if platform_family?('debian')
      package 'dpkg-dev'
      package 'pkg-config'
      package 'libpcre3-dev'
    end
    if platform_family?('redhat')
      package 'pcre-devel'
      package 'varnish-libs-devel'
    end

    clone_options = new_resource.branch.nil? ? new_resource.source : "-b #{new_resource.branch} #{new_resource.source}"

    bash "install #{new_resource.name}" do
      cwd node['w_varnish']['vmod_build_dir']
      flags '-e -u'
      environment 'skip_source' => ::Gem::Version.new(node['varnish']['version']) >= ::Gem::Version.new('4.0') ? 'true' : 'false',
                  'redhat' => platform_family?('redhat') ? 'true' : 'false'
      code <<-EOH
      git clone #{clone_options}
      # we don't need the varnish sources if the version is >= 4.0
      if [[ "${skip_source}" == *false* ]]; then
        if [[ "${redhat}" == *false* ]]; then
          apt-get source varnish
          export VARNISHDIR=`find . -maxdepth 1 -type d -name 'varnish-*'`
          cd $VARNISHDIR
          ./configure && make
          cd ..
        else
          VARNISHDIR=/usr/include/varnish
        fi
      else
        if [[ "${redhat}" == *false* ]]; then
          apt-get install libvarnishapi-dev
        fi
      fi
      cd #{vmod_name}
      echo 'running autogen'
      set +o errexit
      ./autogen.sh
      ./autogen.sh
      set -o errexit
      echo 'running configure'
      if [[ "${skip_source}" == *false* ]]; then
        ./configure VARNISHSRC=../$VARNISHDIR VMODDIR=/usr/lib/varnish/vmods
      else
        ./configure VMODDIR=/usr/lib/varnish/vmods
      fi
      echo 'running make'
      make
      make install
      echo "Finished installation of #{new_resource.name}"
      EOH
    end
  end
end

action 'remove' do
  # undefined method `basename' for Chef::Provider::File:Class
  vmod_path = "/usr/lib/varnish/vmods/#{::File.basename(current_resource.source, '.git').gsub('-', '_')}.so"
  if ::File.exist?(vmod_path)
    if ::File.writable?(vmod_path)
      Chef::Log.info("Deleting #{new_resource} at #{vmod_path}")
      ::File.delete(vmod_path)
      new_resource.updated_by_last_action(true)
    else
      fail "Cannot delete #{new_resource} at #{vmod_path}!"
    end
  end
end