#
# Cookbook Name:: aet
# Recipe:: win_karaf
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

# Install JAVA on Windows
node.default['java']['install_flavor'] = 'windows'
node.default['aet']['karaf']['root_dir'] = 'c:/content/karaf'
node.default['aet']['karaf']['source'] =
  'https://archive.apache.org/dist/karaf/2.3.9/apache-karaf-2.3.9.zip'

include_recipe 'java::default'

include_recipe 'aet::win_karaf_prereq'

# Karaf
directory node['aet']['karaf']['root_dir'] do
  action :create
end

filename = get_filename(node['aet']['karaf']['source'])

remote_file "#{node['aet']['karaf']['root_dir']}/#{filename}" do
  source node['aet']['karaf']['source']
  action :create
end

basename = ::File.basename(filename, '.zip')

windows_zipfile node['aet']['karaf']['root_dir'] do
  source "#{node['aet']['karaf']['root_dir']}/#{filename}"
  action :unzip

  not_if do
    ::File.exist?(
      "#{node['aet']['karaf']['root_dir']}/#{basename}/bin/karaf.bat"
    )
  end
end

link "#{node['aet']['karaf']['root_dir']}/current" do
  to "#{node['aet']['karaf']['root_dir']}/#{basename}"

  notifies :restart, 'service[karaf]', :delayed
end

srv_install_cmd =
  "nssm install karaf #{node['aet']['karaf']['root_dir']}/current/bin/karaf.bat"

execute 'config-karaf-service' do
  # NSSM creates service in Automatic state,
  # so enable action is not requried in service
  command srv_install_cmd
  action :run

  not_if { ::Win32::Service.exists?('karaf') }
end

karaf_service_config =
  'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\karaf\Parameters'

registry_key karaf_service_config do
  values [{
    name: 'AppEnvironmentExtra',
    type: :multi_string,
    data: [
      "JAVA_MIN_MEM=#{node['aet']['karaf']['java_min_mem']}",
      "JAVA_MAX_MEM=#{node['aet']['karaf']['java_max_mem']}",
      # Parameters below currently are not caught up by Karaf during startup
      # To be investigated
      "JAVA_PERM_MEM=#{node['aet']['karaf']['java_min_perm_mem']}",
      "JAVA_MAX_PERM_MEM=#{node['aet']['karaf']['java_max_perm_mem']}"
    ]
  }]
  action :create

  notifies :restart, 'service[karaf]', :delayed
end

service 'karaf' do
  action :start
end
