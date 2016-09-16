#
# Cookbook Name:: aet
# Recipe:: reboot
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

# This recipe must be used as last one!!

# After installing X environment in display.rb recipe we create temporary file
# to notify recipe below that restart is required

# Verify if reboot is required and if it is, wait for Karaf to configure itself
# and then reboot whole OS
execute 'restart-not-required-anymore' do
  command 'rm /tmp/first-chef-run'
  action :run

  notifies :run, 'ruby_block[karaf-config-guard]', :immediately

  only_if do
    ::File.exist?('/tmp/first-chef-run')
  end
end

# Wait until Karaf configured itself properly
# This needs improvement. OSGi bundles status could be checked.
ruby_block 'karaf-config-guard' do
  block do
    require 'uri'
    uri = URI.parse('http://localhost:8181/system/console/bundles')
    time_diff = wait_for_response_code(uri, 401, 600)
    puts "Karaf configuration time: #{time_diff} seconds"
    Chef::Log.info("Karaf configuration time: #{time_diff} seconds")
  end

  action :nothing
  notifies :run, 'execute[reboot-machine]', :delayed
end

# Restart machine if notified
execute 'reboot-machine' do
  command 'shutdown -r +1 &'
  action :nothing
end
