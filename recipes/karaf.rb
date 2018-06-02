#
# Cookbook Name:: aet
# Recipe:: karaf
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

# INSTALLATION
###############################################################################

# Create dedicated group
group node['aet']['karaf']['group'] do
  action :create
end

# Create dedicated user if 'developer' user doesn't exist
user 'karaf user' do
  username node['aet']['karaf']['user']
  group node['aet']['karaf']['group']
  system true
  shell '/bin/bash'
  action :create

  not_if { node['etc']['passwd'].key?(node['aet']['develop']['user']) }
end

# Create base dir
directory node['aet']['karaf']['root_dir'] do
  owner node['aet']['karaf']['user']
  group node['aet']['karaf']['group']
  mode '0755'
  action :create
  recursive true
end

# Create log dir
directory node['aet']['karaf']['log_dir'] do
  owner node['aet']['karaf']['user']
  group node['aet']['karaf']['group']
  mode '0755'
  action :create
  recursive true
end

# Get Karaf binaries file name from link
filename = get_filename(node['aet']['karaf']['source'])

# Download Karaf binaries
remote_file "#{node['aet']['karaf']['root_dir']}/#{filename}" do
  owner node['aet']['karaf']['user']
  group node['aet']['karaf']['group']
  mode '0644'
  source node['aet']['karaf']['source']
end

# Get Karaf file name without extension
# This is basically the name of the directory that Karaf extracted itself to
basename = ::File.basename(filename, '.tar.gz')

# Extract Karaf binaries
execute 'extract karaf' do
  command "tar xvf #{filename}"
  cwd node['aet']['karaf']['root_dir']
  user node['aet']['karaf']['user']
  group node['aet']['karaf']['group']
  not_if do
    ::File.exist?("#{node['aet']['karaf']['root_dir']}/#{basename}/bin/karaf")
  end
end

# Create symlink from extracted Karaf dir
link "#{node['aet']['karaf']['root_dir']}/current" do
  to "#{node['aet']['karaf']['root_dir']}/#{basename}"

  notifies :restart, 'service[karaf]', :delayed
end

# Overwrite JVM properties for Karaf
template "#{node['aet']['karaf']['root_dir']}/current/bin/setenv" do
  source 'opt/aet/karaf/current/bin/setenv.erb'
  owner node['aet']['karaf']['user']
  group node['aet']['karaf']['group']
  cookbook node['aet']['karaf']['src_cookbook']['setenv']
  mode '0644'

  notifies :restart, 'service[karaf]', :delayed
end

# Create systemd script for karaf
template '/etc/systemd/system/karaf.service' do
  source 'etc/systemd/system/karaf.service.erb'
  owner 'root'
  group 'root'
  cookbook node['aet']['karaf']['src_cookbook']['systemd_script']
  mode '0755'
  variables(
    :home_dir => node['aet']['karaf']['root_dir'],
    :user => node['aet']['karaf']['user'],
    :group => node['aet']['karaf']['port']
  )

  notifies :run, 'execute[systemd-reload]', :delayed
  notifies :restart, 'service[karaf]', :delayed
end

# Reload systemd services if script changed
execute 'systemd-reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

# Configure user credentials
template "#{node['aet']['karaf']['root_dir']}/current/etc/users.properties" do
  source 'opt/aet/karaf/current/etc/users.properties.erb'
  owner node['aet']['karaf']['user']
  group node['aet']['karaf']['group']
  cookbook node['aet']['karaf']['src_cookbook']['users_prop']
  mode '0644'
end

# Configure Web console port
template "#{node['aet']['karaf']['root_dir']}/current/etc/"\
  'org.ops4j.pax.web.cfg' do
  source 'opt/aet/karaf/current/etc/org.ops4j.pax.web.cfg.erb'
  owner node['aet']['karaf']['user']
  group node['aet']['karaf']['group']
  cookbook node['aet']['karaf']['src_cookbook']['ops4j_cfg']
  mode '0644'

  notifies :restart, 'service[karaf]', :delayed
end

# Configure SSH console port
template "#{node['aet']['karaf']['root_dir']}/current/etc/"\
  'org.apache.karaf.shell.cfg' do
  source 'opt/aet/karaf/current/etc/org.apache.karaf.shell.cfg.erb'
  owner node['aet']['karaf']['user']
  group node['aet']['karaf']['group']
  cookbook node['aet']['karaf']['src_cookbook']['shell_cfg']
  mode '0644'

  notifies :restart, 'service[karaf]', :delayed
end

# Remove old logs directory
directory "#{node['aet']['karaf']['root_dir']}/current/data/log" do
  recursive true
  action :delete
  not_if do
    ::File.symlink?("#{node['aet']['karaf']['root_dir']}/current/data/log")
  end
end

# Create data folder if it doesn't exists so that we can create link for logs
directory "#{node['aet']['karaf']['root_dir']}/current/data" do
  owner node['aet']['karaf']['user']
  group node['aet']['karaf']['group']
  mode '0755'
  action :create
  recursive true
end

# Create symlink for logs directory
link "#{node['aet']['karaf']['root_dir']}/current/data/log" do
  to node['aet']['karaf']['log_dir']
end

# Enable and start Karaf
service 'karaf' do
  supports status: true, restart: true
  action [:start, :enable]
end
