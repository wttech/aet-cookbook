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
include_recipe 'java::default'

# Install Chef Windows toolset
include_recipe 'windows::default'

# Install service wrapper
directory 'c:\content\nssm' do
  recursive true
  action :create
end

remote_file 'c:\content\nssm\nssm-2.24.zip' do
  source 'https://nssm.cc/release/nssm-2.24.zip'
  action :create
end

windows_zipfile 'c:\content\nssm' do
  source 'c:\content\nssm\nssm-2.24.zip'
  action :unzip

  not_if { ::File.exist?('c:\content\nssm\nssm-2.24\win64\nssm.exe') }
end

link 'c:\content\nssm\current' do
  to 'c:\content\nssm\nssm-2.24'
end

env 'Path' do
  value 'c:\\content\\nssm\\current\\win64\\'
  delim ';'
  action :modify
end

# Karaf
directory 'c:\content\karaf' do
  action :create
end

remote_file 'c:\content\karaf\apache-karaf-2.3.9.zip' do
  source 'https://archive.apache.org/dist/karaf/2.3.9/apache-karaf-2.3.9.zip'
  action :create
end

windows_zipfile 'c:\content\karaf' do
  source 'c:\content\karaf\apache-karaf-2.3.9.zip'
  action :unzip

  not_if { ::File.exist?('c:\content\karaf\apache-karaf-2.3.9\bin\karaf.bat') }
end

link 'c:\content\karaf\current' do
  to 'c:\content\karaf\apache-karaf-2.3.9'
end

execute 'config-karaf-service' do
  # NSSM creates service in Automatic state,
  # so enable action is not requried in service
  command 'nssm install karaf c:\content\karaf\current\bin\karaf.bat'
  action :run

  not_if { ::Win32::Service.exists?('karaf') }
end

service 'karaf' do
  action :start
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
      "JAVA_PERM_MEM=#{node['aet']['karaf']['java_min_perm_mem']}",
      "JAVA_MAX_PERM_MEM=#{node['aet']['karaf']['java_max_perm_mem']}"
    ]
  }]
  action :create

  notifies :restart, 'service[karaf]', :delayed
end
