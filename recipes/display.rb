#
# Cookbook Name:: aet
# Recipe:: display
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

# Install all required X packages
[
  'X Window System',
  'Desktop',
  'General Purpose Desktop',
  'Fonts'
].each do |p_group|
  execute "Installing: #{p_group}" do
    command "yum groupinstall '#{p_group}' -y"
    action :run
    not_if "yum grouplist '#{p_group}' | grep Installed"
    notifies :run, 'execute[restart-required]', :immediately
  end
end

# Schedule restart
execute 'restart-required' do
  command 'touch /tmp/first-chef-run'
  action :nothing
end

# Change default init level to enable X environment on restart
template '/etc/inittab' do
  source 'etc/inittab.erb'
  owner 'root'
  group 'root'
  cookbook node['aet']['display']['src_cookbook']['inittab']
  mode '0644'
end
