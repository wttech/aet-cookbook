#
# Cookbook Name:: aet
# Recipe:: deploy_configs
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

# This requires recipes: 'karaf' and 'postdeploy_restart'

# PREREQUISITES
###############################################################################

package 'unzip' do
  action :install
end

# CONFIG DEPLOYMENT
###############################################################################

ver = node['aet']['version']
base_dir = node['aet']['karaf']['root_dir']
work_dir = "#{base_dir}/aet_configs"
config_local_path = "#{work_dir}/configs-#{ver}.zip"
config_download_url = "#{node['aet']['base_link']}/#{ver}/configs.zip"
config_deploy_dir = "#{base_dir}/current/etc/aet"

# Create AET config directory
directory work_dir do
  owner node['aet']['karaf']['user']
  group node['aet']['karaf']['group']
  recursive true
  action :create
end

# Overwrite config to point to appropriate configuration branch
template "#{base_dir}/current/etc/custom.properties" do
  source 'content/karaf/current/etc/custom.properties.erb'
  owner node['aet']['karaf']['user']
  group node['aet']['karaf']['group']
  cookbook node['aet']['karaf']['src_cookbook']['custom_prop']
  mode '0644'

  notifies :restart, 'service[karaf]', :delayed
end

# Download config zip
# The package is only re-downloaded if the name of remote file has changed
remote_file config_local_path do
  source config_download_url
  owner node['aet']['karaf']['user']
  group node['aet']['karaf']['group']
end

# see `helpers.rb` file
check_if_new('configs',
             config_deploy_dir,
             "#{work_dir}/#{ver}",
             'execute[extract-configs]')

# Extract config zip (skipped by default, run only when notified)
execute 'extract-configs' do
  command "unzip -o #{config_local_path} -d #{ver}"
  cwd work_dir
  user node['aet']['karaf']['user']
  group node['aet']['karaf']['group']
  action :nothing
end
