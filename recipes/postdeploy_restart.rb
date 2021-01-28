#
# Cookbook Name:: aet
# Recipe:: postdeploy_restart
#
# AET Cookbook
#
# Copyright (C) 2016 Wunderman Thompson Technology
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

# global variables
$karaf_cache = %w(
  cache
  generated-bundles
  kar
  security
  tmp
)

execute 'schedule-karaf-restart' do
  command 'touch /tmp/karaf-restart'
  action :nothing
end

execute 'execute-scheduled-karaf-restart' do
  command 'rm -f /tmp/karaf-restart'
  action :run

  notifies :stop, 'service[karaf-deploy-stop]', :immediately
  # notifies cache folders deletion
  $karaf_cache.each do |cache_folder|
    notifies :delete, "directory[#{cache_folder}]", :immediately
  end
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

# Registers cache deletion (skipped by default, run only when notified)
$karaf_cache.each do |cache_folder|
  
  directory cache_folder do
    path "#{node['aet']['karaf']['root_dir']}/current/data/#{cache_folder}"
    recursive true
    # action :nothing as it will be notified explicitly
    action :nothing
  end
end
