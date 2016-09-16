#
# Cookbook Name:: aet
# Recipe:: postdeploy_restart
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

# This requires recipes: 'karaf'

# As we cannot relay on :delayed notification for Karaf restart in this Cookbook
# we have to use a trick, where we create temporary file during Karaf deployment
# After that we execute this recipe. If the temporary file exists, then we
# restart Karaf service, to trigger bundle/config deployment.

cache_dir = "#{node['aet']['karaf']['root_dir']}/current/data/cache"
tmp_dir = "#{node['aet']['karaf']['root_dir']}/current/data/tmp"
generated_bundles_dir =
  "#{node['aet']['karaf']['root_dir']}/current/data/generated_bundles"

execute 'schedule-karaf-restart' do
  command 'touch /tmp/karaf-restart'
  action :nothing
end

execute 'execute-scheduled-karaf-restart' do
  command 'rm -f /tmp/karaf-restart'
  action :run

  notifies :stop, 'service[karaf-deploy-stop]', :immediately
  notifies :delete, "directory[#{cache_dir}]", :immediately
  notifies :delete, "directory[#{tmp_dir}]", :immediately
  notifies :delete, "directory[#{generated_bundles_dir}]", :immediately
  notifies :start, 'service[karaf]', :immediately

  only_if do
    ::File.exist?('/tmp/karaf-restart')
  end
end

# Stopping Karaf (skipped by default, run only when notified)
service 'karaf-deploy-stop' do
  service_name 'karaf'
  action :nothing
end

# Removing cache (skipped by default, run only when notified)
directory cache_dir do
  recursive true
  action :nothing
end
directory tmp_dir do
  recursive true
  action :nothing
end
directory generated_bundles_dir do
  recursive true
  action :nothing
end
