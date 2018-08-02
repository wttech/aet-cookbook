#
# Cookbook Name:: aet
# Recipe:: activemq
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

# This recipe is based on ActiveMQ on Supermarket, but allows for much more
# customization and is way more secure.

# PREREQUISITES
###############################################################################

include_recipe 'java::default'

# INSTALLATION
###############################################################################

# Create dedicated group
group node['aet']['activemq']['group'] do
  action :create
end

# Create dedicated user
user node['aet']['activemq']['user'] do
  group node['aet']['activemq']['group']
  manage_home true
  home node['aet']['activemq']['root_dir']
  system true
  shell '/bin/bash'
  action :create
end

# Create root dir for ActiveMQ
directory node['aet']['activemq']['root_dir'] do
  owner node['aet']['activemq']['user']
  group node['aet']['activemq']['group']
  mode '0755'
  recursive true
end

# Create root dir for Logs
directory node['aet']['activemq']['log_dir'] do
  owner node['aet']['activemq']['user']
  group node['aet']['activemq']['group']
  recursive true
end

# Get ActiveMQ binaries file name from link
filename = get_filename(node['aet']['activemq']['source'])

# Download ActiveMQ binaries
remote_file "#{node['aet']['activemq']['root_dir']}/#{filename}" do
  owner node['aet']['activemq']['user']
  group node['aet']['activemq']['group']
  mode '0644'
  source node['aet']['activemq']['source']
end

# Get ActiveMQ binaries filename after extraction
basename = ::File.basename(filename, '-bin.tar.gz')

# Extract ActiveMQ binaries
execute 'extract activemq' do
  command "tar xvf #{node['aet']['activemq']['root_dir']}/#{filename}"
  cwd node['aet']['activemq']['root_dir']
  user node['aet']['activemq']['user']
  group node['aet']['activemq']['group']

  not_if do
    ::File.exist?("#{node['aet']['activemq']['root_dir']}/"\
      "#{basename}/bin/activemq")
  end
end

# Pre check to stop service before updating symlink
# This is required because graceful shutdown requires old directory
execute 'symlink-check' do
  command 'echo'
  action :run

  notifies :stop, 'service[activemq]', :immediately
  not_if do
    ::File.identical?(
      "#{node['aet']['activemq']['root_dir']}/current",
      "#{node['aet']['activemq']['root_dir']}/#{basename}"
    )
  end
end

# Create link from extracted folder with version in name to universal one
link "#{node['aet']['activemq']['root_dir']}/current" do
  to "#{node['aet']['activemq']['root_dir']}/#{basename}"
end

# Change permissions on activemq main file
file "#{node['aet']['activemq']['root_dir']}/current/bin/activemq" do
  owner node['aet']['activemq']['user']
  group node['aet']['activemq']['group']
  mode '0755'
end

# Create ActiveMQ init file
template "#{node['aet']['activemq']['root_dir']}/current/bin/env" do
  source 'content/activemq/current/bin/env.erb'
  owner node['aet']['activemq']['user']
  group node['aet']['activemq']['group']
  cookbook node['aet']['activemq']['src_cookbook']['env']
  mode '0755'

  notifies :restart, 'service[activemq]', :delayed
end

# Link init file
link '/etc/init.d/activemq' do
  to "#{node['aet']['activemq']['root_dir']}/current/bin/activemq"
end

# Overwrite ActiveMQ core settings
template "#{node['aet']['activemq']['root_dir']}/current/conf/activemq.xml" do
  source 'content/activemq/current/conf/activemq.xml.erb'
  owner node['aet']['activemq']['user']
  group node['aet']['activemq']['group']
  cookbook node['aet']['activemq']['src_cookbook']['activemq_xml']
  mode '0644'
  notifies :restart, 'service[activemq]', :delayed
end

# Overwrite ActiveMQ logging settings
template "#{node['aet']['activemq']['root_dir']}/current"\
  '/conf/log4j.properties' do
  source 'content/activemq/current/conf/log4j.properties.erb'
  owner node['aet']['activemq']['user']
  group node['aet']['activemq']['group']
  cookbook node['aet']['activemq']['src_cookbook']['log4j_prop']
  mode '0644'
  notifies :restart, 'service[activemq]', :delayed
end

# Overwrite ActiveMQ credentials
template "#{node['aet']['activemq']['root_dir']}/current"\
  '/conf/jetty-realm.properties' do
  source 'content/activemq/current/conf/jetty-realm.properties.erb'
  owner node['aet']['activemq']['user']
  group node['aet']['activemq']['group']
  cookbook node['aet']['activemq']['src_cookbook']['jetty_prop']
  mode '0644'
  notifies :restart, 'service[activemq]', :delayed
end

# Start and enable ActiveMQ service
service 'activemq' do
  supports restart: true, status: true
  action [:enable, :start]
end
