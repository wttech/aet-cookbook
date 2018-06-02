#
# Cookbook Name:: aet
# Recipe:: apache
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

# INSTALLATION
###############################################################################

# Install Apache using supermarket cookbook
include_recipe 'apache2::default'

# Create log directory
directory node['aet']['apache']['log_dir'] do
  owner 'root'
  group 'root'
  mode 0755
  recursive true
  action :create
end

# Remove original logging directory
directory '/var/log/httpd' do
  recursive true
  action :delete

  not_if do
    ::File.symlink?('/var/log/httpd')
  end
end

# Link created logging dir to original one
link '/var/log/httpd' do
  to node['aet']['apache']['log_dir']

  notifies :restart, 'service[apache2]', :delayed
end

%w(
  proxy
  proxy_http
  headers
).each do |it|
  apache_module it do
    enable true
  end
end
