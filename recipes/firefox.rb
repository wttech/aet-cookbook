#
# Cookbook Name:: aet
# Recipe:: firefox
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

if windows?
  # Install Firefox on Windows
  windows_package node['aet']['firefox']['win_package_name'] do
    source node['aet']['firefox']['win_source']
    options '-ms'
    installer_type :custom
    action :install
  end

  disable_update = '
    user_pref("app.update.enabled", false);
    user_pref("app.update.service.enabled", false);'

  ruby_block 'disable-ff-update' do
    block do
      puts 'placeholder'
    end
  end

else
  # Create deducated group
  group node['aet']['firefox']['group'] do
    action :create
  end

  # Create dedicated user
  user node['aet']['firefox']['user'] do
    group node['aet']['firefox']['group']
    home "/home/#{node['aet']['firefox']['user']}"
    shell '/bin/bash'
    action :create
  end

  # Create dedicated root directory
  directory node['aet']['firefox']['root_dir'] do
    owner node['aet']['firefox']['user']
    group node['aet']['firefox']['group']
    mode '0755'
    action :create
    recursive true
  end

  # Get Firefox binaries file name from link
  filename = get_filename(node['aet']['firefox']['source'])

  # Download firefox binaries
  remote_file "#{node['aet']['firefox']['root_dir']}/#{filename}" do
    owner node['aet']['firefox']['user']
    group node['aet']['firefox']['group']
    mode '0644'
    source node['aet']['firefox']['source']
  end

  # Get Firefox binaries filename after extraction
  basename = ::File.basename(filename, '.tar.bz2')

  # Create version specific firefox directory
  directory "#{node['aet']['firefox']['root_dir']}/#{basename}" do
    owner node['aet']['firefox']['user']
    group node['aet']['firefox']['group']
    mode '0755'
    action :create
    recursive true
  end

  # Extract firefox tar.bz2 file
  execute 'extract firefox' do
    command "tar xvf #{filename} -C #{basename} --strip-components 1"
    cwd node['aet']['firefox']['root_dir']
    user node['aet']['firefox']['user']
    group node['aet']['firefox']['group']

    not_if do
      File.exist?("#{node['aet']['firefox']['root_dir']}/current/firefox-bin")
    end
  end

  # Link extracted firefox directory to some common one
  link "#{node['aet']['firefox']['root_dir']}/current" do
    to "#{node['aet']['firefox']['root_dir']}/#{basename}"
  end

  # Create script to always run firefox with parameters
  template '/usr/bin/firefox' do
    source 'usr/bin/firefox.erb'
    owner 'root'
    group 'root'
    cookbook node['aet']['firefox']['src_cookbook']['bin']
    mode '0755'
  end
end
