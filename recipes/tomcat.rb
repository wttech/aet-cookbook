#
# Cookbook Name:: aet
# Recipe:: tomcat
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

# This requires recipes: 'apache'

# Missing gem for Chef execution
chef_gem 'addressable' do
  compile_time false if respond_to?(:compile_time)
end

# Install Java
include_recipe 'java'

#### PREPARATION ####

# Create group
group node['aet']['tomcat']['group'] do
  system true
  action :create
end

# Create user
user node['aet']['tomcat']['user'] do
  supports manage_home: false
  system true
  comment 'Tomcat'
  group node['aet']['tomcat']['group']
  shell '/bin/bash'
  action :create
end

# Preparing root directory
directory node['aet']['tomcat']['base_dir'] do
  owner node['aet']['tomcat']['user']
  group node['aet']['tomcat']['group']
  mode '0755'
  recursive true
  action :create
end

# Preparing log directory
directory node['aet']['tomcat']['log_dir'] do
  owner node['aet']['tomcat']['user']
  group node['aet']['tomcat']['group']
  mode '0755'
  recursive true
  action :create
end

#### INSTALLATION ####

# Extracting filename
src_filename = get_filename(node['aet']['tomcat']['source'])

# Downloading Tomcat
remote_file "#{Chef::Config[:file_cache_path]}/#{src_filename}" do
  source node['aet']['tomcat']['source']
end

# Extracting tomcat to base_dir
bash "Unpack #{src_filename} to #{node['aet']['tomcat']['base_dir']}" do
  user node['aet']['tomcat']['user']
  group node['aet']['tomcat']['group']
  code <<-EOH
    tar zxf #{Chef::Config[:file_cache_path]}/#{src_filename} \
    -C #{node['aet']['tomcat']['base_dir']} \
    --strip-components=1
  EOH

  not_if { ::Dir.exist?("#{node['aet']['tomcat']['base_dir']}/bin") }
end

# Init script handling
template '/etc/init.d/tomcat' do
  cookbook node['aet']['tomcat']['init']['source_cookbook']
  source 'etc/init.d/tomcat.erb'
  owner 'root'
  group 'root'
  mode '0755'
  notifies :restart, 'service[tomcat]', :delayed
end

# Removing old logs directory
directory "#{node['aet']['tomcat']['base_dir']}/logs" do
  recursive true
  action :delete
  not_if { File.symlink?("#{node['aet']['tomcat']['base_dir']}/logs") }
end

# Creating symling to final log dir
link "#{node['aet']['tomcat']['base_dir']}/logs" do
  to node['aet']['tomcat']['log_dir']
  notifies :restart, 'service[tomcat]', :delayed
end

#### CONFIGURATION ####

# Creating settings override file to easily handle all required variables
template "#{node['aet']['tomcat']['base_dir']}/bin/setenv.sh" do
  cookbook node['aet']['tomcat']['setenv.sh']['source_cookbook']
  source 'content/tomcat/bin/setenv.sh.erb'
  owner node['aet']['tomcat']['user']
  group node['aet']['tomcat']['group']
  mode '0755'

  notifies :restart, 'service[tomcat]', :delayed
end

# Base settings management template
template "#{node['aet']['tomcat']['base_dir']}/conf/server.xml" do
  cookbook node['aet']['tomcat']['server.xml']['source_cookbook']
  source 'content/tomcat/conf/server.xml.erb'
  owner node['aet']['tomcat']['user']
  group node['aet']['tomcat']['group']
  mode '0644'

  notifies :restart, 'service[tomcat]', :delayed
end

# User management template
template "#{node['aet']['tomcat']['base_dir']}/conf/tomcat-users.xml" do
  cookbook node['aet']['tomcat']['tomcat-users.xml']['source_cookbook']
  source 'content/tomcat/conf/tomcat-users.xml.erb'
  owner node['aet']['tomcat']['user']
  group node['aet']['tomcat']['group']
  mode '0644'

  notifies :restart, 'service[tomcat]', :delayed
end

#### STARTUP ####

service 'tomcat (enable)' do
  service_name 'tomcat'
  action :enable
end

service 'tomcat' do
  supports status: true, restart: true
  action :start
end
