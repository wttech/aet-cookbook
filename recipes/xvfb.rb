#
# Cookbook Name:: aet
# Recipe:: xvfb
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

# This recipe is dependency for any browser running on linux machine

# INSTALLATION
###############################################################################

# Install required packages
%w(
  Xvfb
  libXfont
  Xorg
).each do |p|
  package p do
    action :install
  end
end

# Create dedicated group
group node['aet']['xvfb']['group'] do
  action :create
end

# Create dedicated user
user node['aet']['xvfb']['user'] do
  group node['aet']['xvfb']['group']
  manage_home true
  home "/var/lib/#{node['aet']['xvfb']['user']}"
  system true
  shell '/bin/bash'
  action :create
end

# Create dedicate log directory
directory node['aet']['xvfb']['log_dir'] do
  owner node['aet']['xvfb']['user']
  group node['aet']['xvfb']['group']
  mode '0755'
  action :create
  recursive true
end

# Create init script for Xvfb
template '/etc/init.d/xvfb' do
  source 'etc/init.d/xvfb.erb'
  owner 'root'
  group 'root'
  cookbook node['aet']['xvfb']['src_cookbook']['init_script']
  mode '0755'

  notifies :restart, 'service[xvfb]', :immediately
end

# Start and enable Xvfb service
service 'xvfb' do
  supports status: true, restart: true
  action [:start, :enable]
end
