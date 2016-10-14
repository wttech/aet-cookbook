#
# Cookbook Name:: aet
# Recipe:: win_nssm
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

node.default['aet']['nssm']['root_dir'] = 'c:/content/nssm'
node.default['aet']['nssm']['source'] = 'https://nssm.cc/release/nssm-2.24.zip'

# Install Chef Windows toolset
include_recipe 'windows::default'

# Install service wrapper
directory node['aet']['nssm']['root_dir'] do
  recursive true
  action :create
end

filename = get_filename(node['aet']['nssm']['source'])

remote_file "#{node['aet']['nssm']['root_dir']}/#{filename}" do
  source node['aet']['nssm']['source']
  action :create
end

basename = ::File.basename(filename, '.zip')

windows_zipfile node['aet']['nssm']['root_dir'] do
  source "#{node['aet']['nssm']['root_dir']}/#{filename}"
  action :unzip

  not_if do
    ::File.exist?(
      "#{node['aet']['nssm']['root_dir']}/#{basename}/win64/nssm.exe"
    )
  end
end

link "#{node['aet']['nssm']['root_dir']}/current" do
  to "#{node['aet']['nssm']['root_dir']}/#{basename}"
end

env 'Path' do
  value "#{node['aet']['nssm']['root_dir']}/current/win64/"
  delim ';'
  action :modify
end
