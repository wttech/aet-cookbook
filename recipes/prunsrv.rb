#
# Cookbook Name:: aet
# Recipe:: prunsrv
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

node.default['aet']['prunsrv']['root_dir'] = 'c:/content/prunsrv'
node.default['aet']['prunsrv']['source'] = 'http://www.apache.org/dist/commons'\
  '/daemon/binaries/windows/commons-daemon-1.0.15-bin-windows-signed.zip'

# Install service wrapper
directory node['aet']['prunsrv']['root_dir'] do
  recursive true
  action :create
end

filename = get_filename(node['aet']['prunsrv']['source'])

remote_file "#{node['aet']['prunsrv']['root_dir']}/#{filename}" do
  source node['aet']['prunsrv']['source']
  action :create
end

basename = ::File.basename(filename, '.zip')

windows_zipfile "#{node['aet']['prunsrv']['root_dir']}/#{basename}" do
  source "#{node['aet']['prunsrv']['root_dir']}/#{filename}"
  action :unzip

  not_if do
    ::File.exist?(
      "#{node['aet']['prunsrv']['root_dir']}/#{basename}/amd64/prunsrv.exe"
    )
  end
end

link "#{node['aet']['prunsrv']['root_dir']}/current" do
  to "#{node['aet']['prunsrv']['root_dir']}/#{basename}"
end

env 'Path' do
  value "#{node['aet']['prunsrv']['root_dir']}/current/amd64/"
  delim ';'
  action :modify
end
