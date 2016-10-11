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
