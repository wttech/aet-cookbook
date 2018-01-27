#
# Cookbook Name:: aet
# Recipe:: browsermob
#
# AET Cookbook
#
# Copyright (C) 2016 Cognifide Limited
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# PREREQUISITES
###############################################################################

include_recipe 'java::default'

package 'unzip' do
  action :install
end

# INSTALLATION
###############################################################################

# Create dedicated group
group node['aet']['browsermob']['group'] do
  action :create
end

# Create dedicated user
user node['aet']['browsermob']['user'] do
  group node['aet']['browsermob']['group']
  manage_home true
  home node['aet']['browsermob']['root_dir']
  system true
  shell '/bin/bash'
  action :create
end

# Create dedicated root directory
directory node['aet']['browsermob']['root_dir'] do
  owner node['aet']['browsermob']['user']
  group node['aet']['browsermob']['group']
  mode '0755'
  action :create
  recursive true
end

# Create dedicated log directory
directory node['aet']['browsermob']['log_dir'] do
  owner node['aet']['browsermob']['user']
  group node['aet']['browsermob']['group']
  mode '0755'
  action :create
  recursive true
end

# Get binaries file name from link
filename = get_filename(node['aet']['browsermob']['source'])

remote_file "#{node['aet']['browsermob']['root_dir']}/#{filename}" do
  owner node['aet']['browsermob']['user']
  group node['aet']['browsermob']['group']
  mode '0644'
  source node['aet']['browsermob']['source']
end

# Get file name without extension
basename = ::File.basename(filename, '-bin.zip')

# Extract browsermob
execute 'extract browsermob' do
  command "unzip -o #{filename}"
  cwd node['aet']['browsermob']['root_dir']

  user node['aet']['browsermob']['user']
  group node['aet']['browsermob']['group']

  not_if do
    ::File.exist?(
      "#{node['aet']['browsermob']['root_dir']}/"\
        "#{basename}/bin/browsermob-proxy"
    )
  end
end

# Link extracted browsermob to some common directory
link "#{node['aet']['browsermob']['root_dir']}/current" do
  to "#{node['aet']['browsermob']['root_dir']}/#{basename}"

  notifies :restart, 'service[browsermob]', :delayed
end

# Create init script for browsermob
template '/etc/init.d/browsermob' do
  source 'etc/init.d/browsermob.erb'
  owner 'root'
  group 'root'
  cookbook node['aet']['browsermob']['src_cookbook']['init_script']
  mode '0755'

  notifies :restart, 'service[browsermob]', :delayed
end

# Enable and start browsermob service
service 'browsermob' do
  action [:start, :enable]
end
