#
# Cookbook Name:: aet
# Recipe:: develop
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

# Create dedicated group
group node['aet']['develop']['group'] do
  action :create
end

# Create dedicated user
user node['aet']['develop']['user'] do
  group node['aet']['develop']['group']
  home "/home/#{node['aet']['develop']['user']}"
  shell '/bin/bash'
  password node['aet']['develop']['ssh_password']
  action :create
end

# Overwrites service users and groups for developer instance
node.normal['aet']['karaf']['user']         = node['aet']['develop']['user']
node.normal['aet']['karaf']['group']        = node['aet']['develop']['group']
node.normal['aet']['karaf']['ssh_password'] =
  node['aet']['develop']['ssh_password']

node.normal['aet']['tomcat']['user']        = node['aet']['develop']['user']
node.normal['aet']['tomcat']['group']       = node['aet']['develop']['group']

node.normal['apache']['user']               = node['aet']['develop']['user']
node.normal['apache']['group']              = node['aet']['develop']['group']
