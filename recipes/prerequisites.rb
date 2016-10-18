#
# Cookbook Name:: aet
# Recipe:: prerequisites
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

include_recipe 'chef-sugar::default'

if windows?
  node.default['aet']['karaf']['user'] = 'Administrator'
  node.default['aet']['karaf']['group'] = 'Administrators'

  node.default['aet']['browsermob']['user'] = 'Administrator'
  node.default['aet']['browsermob']['group'] = 'Administrators'

  node.default['java']['install_flavor'] = 'windows'
  node.default['aet']['karaf']['root_dir'] = 'c:/content/karaf'
  node.default['aet']['karaf']['log_dir'] = 'c:/content/logs/karaf'
  node.default['aet']['karaf']['source'] =
    'https://archive.apache.org/dist/karaf/2.3.9/apache-karaf-2.3.9.zip'

  node.default['aet']['browsermob']['root_dir'] = 'c:/content/browsermob'
  node.default['aet']['browsermob']['log_dir'] = 'c:/content/logs/browsermob'

  include_recipe 'windows::default'
  include_recipe 'notepadpp::default'
  include_recipe 'aet::nssm'

  firewall 'default' do
    action :nothing
  end

  firewall_rule 'allow-all-tcp' do
    protocol :tcp
    port 1..65_535
    command :allow
  end
end
