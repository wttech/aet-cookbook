#
# Cookbook Name:: aet
# Recipe:: deploy_aet_for_karaf
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

# APP DEPLOYMENT
###############################################################################

# global variables
$ver = "#{node['aet']['version']}"
$deploy_dir = "#{node['aet']['karaf']['root_dir']}/current/deploy"
$version_dir = "#{node['aet']['karaf']['root_dir']}/#{node['aet']['version']}"

# registers tasks for artifacts
%w(
  bundles
  configs
  features
).each do |artifact_type|

  url = "#{node['aet']['base_link']}/#{$ver}/#{artifact_type}.zip"

  remote_file artifact_type do
    source url
    path "/tmp/#{artifact_type}-#{$ver}.zip"
    owner node['aet']['karaf']['user']
    group node['aet']['karaf']['group']
    # action :nothing as it will be called explicitly if version has changed
    action :nothing
  end

  file = "/tmp/#{artifact_type}-#{$ver}.zip"

  execute "unzip-#{artifact_type}" do
    command "unzip -o -d #{$version_dir} #{file}"
    user node['aet']['karaf']['user']
    group node['aet']['karaf']['group']
    # action :nothing as it will be called explicitly if version has changed
    action :nothing
  end
end

# registers task for deploy folder
execute 'delete-deploy-folder' do
  command "rm -fr #{$deploy_dir}"
  user node['aet']['karaf']['user']
  group node['aet']['karaf']['group']
  # action :nothing as it will be called explicitly if version has changed
  action :nothing
end

link 'deploy-folder' do
  target_file $deploy_dir
  to $version_dir
  # action :nothing as it will be called explicitly if version has changed
  action :nothing
end

# will only extract zip file if version has changed
log "version-changed" do
  message "version of AET has changed. "\
          'notifying dependant resources...'

  not_if { same_version?($deploy_dir, $version_dir) }

  notifies :stop, 'service[karaf-deploy-stop]', :immediately

  notifies :run, 'execute[delete-deploy-folder]', :immediately
  notifies :create, 'link[deploy-folder]', :immediately
  %w(
    bundles
    configs
    features
  ).each do |artifact_type|

    notifies :create, "remote_file[#{artifact_type}]", :immediately
    notifies :run, "execute[unzip-#{artifact_type}]", :immediately
  end

  notifies :run, 'execute[schedule-karaf-restart]', :immediately
end
