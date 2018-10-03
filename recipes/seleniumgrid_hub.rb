#
# Cookbook Name:: aet
# Recipe:: seleniumgrid_hub
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

# Create dedicated group
group node['aet']['seleniumgrid']['group'] do
  action :create
end

# Create dedicated user
user node['aet']['seleniumgrid']['user'] do
  group node['aet']['seleniumgrid']['group']
  system true
  action :create
end

# Create dedicated hub directory
directory "#{node['aet']['seleniumgrid']['hub']['root_dir']}" do
  owner node['aet']['seleniumgrid']['user']
  group node['aet']['seleniumgrid']['group']
  mode '0755'
  action :create
  recursive true
end

# Create log directory
directory "#{node['aet']['seleniumgrid']['hub']['log_dir']}" do
  owner node['aet']['seleniumgrid']['user']
  group node['aet']['seleniumgrid']['group']
  mode '0755'
  action :create
  recursive true
end

# Get Selenium Grid file name from link
filename = get_filename(node['aet']['seleniumgrid']['source'])

# Copy Selenium Grid jar to hub folder
remote_file "#{node['aet']['seleniumgrid']['hub']['root_dir']}/#{filename}" do
  source node['aet']['seleniumgrid']['source']
  owner node['aet']['seleniumgrid']['user']
  group node['aet']['seleniumgrid']['group']
  mode 0755
end

# Create Selenium Grid hub init file
template '/etc/init.d/hub' do
  source 'etc/init.d/hub.erb'
  owner 'root'
  group 'root'
  cookbook node['aet']['seleniumgrid']['hub']['src_cookbook']['init_script']
  mode '0755'

  notifies :restart, 'service[hub]', :delayed
end

# Enable and start Selenium Grid hub
service 'hub' do
  supports status: true, restart: true
  action [:start, :enable]
end
