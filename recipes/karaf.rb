#
# Cookbook Name:: aet
# Recipe:: karaf
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

# PREREQUISITES
###############################################################################
include_recipe 'java::default'

# INSTALLATION
###############################################################################

unless windows?
  # Create dedicated group
  group node['aet']['karaf']['group'] do
    action :create
  end

  # Create dedicated user
  user node['aet']['karaf']['user'] do
    group node['aet']['karaf']['group']
    home "/home/#{node['aet']['karaf']['user']}"
    shell '/bin/bash'
    action :create
  end
end

# Create base dir
directory node['aet']['karaf']['root_dir'] do
  owner node['aet']['karaf']['user']
  group node['aet']['karaf']['group']
  mode '0755'
  action :create
  recursive true
end

# Create log dir
directory node['aet']['karaf']['log_dir'] do
  owner node['aet']['karaf']['user']
  group node['aet']['karaf']['group']
  mode '0755'
  action :create
  recursive true
end

# Get Karaf binaries file name from link
filename = get_filename(node['aet']['karaf']['source'])

# Download Karaf binaries
remote_file "#{node['aet']['karaf']['root_dir']}/#{filename}" do
  owner node['aet']['karaf']['user']
  group node['aet']['karaf']['group']
  mode '0644'
  source node['aet']['karaf']['source']
end

# Get Karaf file name without extension
# This is basically the name of the directory that Karaf extracted itself to
if windows?
  basename = ::File.basename(filename, '.zip')

  # Extract Karaf binaries
  windows_zipfile node['aet']['karaf']['root_dir'] do
    source "#{node['aet']['karaf']['root_dir']}/#{filename}"
    action :unzip

    not_if do
      ::File.exist?(
        "#{node['aet']['karaf']['root_dir']}/#{basename}/bin/karaf.bat"
      )
    end
  end
else
  basename = ::File.basename(filename, '.tar.gz')

  # Extract Karaf binaries
  execute 'extract karaf' do
    command "tar xvf #{filename}"
    cwd node['aet']['karaf']['root_dir']
    user node['aet']['karaf']['user']
    group node['aet']['karaf']['group']
    not_if do
      ::File.exist?("#{node['aet']['karaf']['root_dir']}/#{basename}/bin/karaf")
    end
  end
end

# Create symlink from extracted Karaf dir
link "#{node['aet']['karaf']['root_dir']}/current" do
  to "#{node['aet']['karaf']['root_dir']}/#{basename}"

  notifies :restart, 'service[karaf]', :delayed
end

# KARAF 2.3.9 FIX
##############################################################################

directory "#{node['aet']['karaf']['root_dir']}/current/system/org/apache/"\
  'felix/org.apache.felix.framework/4.2.1' do
  owner node['aet']['karaf']['user']
  group node['aet']['karaf']['group']
  mode '0755'
  recursive true
  action :create
end

remote_file "#{node['aet']['karaf']['root_dir']}/current/system/org/apache/"\
  'felix/org.apache.felix.framework/4.2.1/'\
  'org.apache.felix.framework-4.2.1.jar' do
  source node['aet']['karaf']['felix_jar']
  owner node['aet']['karaf']['user']
  group node['aet']['karaf']['group']
end

# Overwrite config to point to appropriate felix
template "#{node['aet']['karaf']['root_dir']}/current/etc/config.properties" do
  source 'content/karaf/current/etc/config.properties.erb'
  owner node['aet']['karaf']['user']
  group node['aet']['karaf']['group']
  mode '0644'

  notifies :restart, 'service[karaf]', :delayed
end

##############################################################################
if windows?
  # Overwrite JVM properties for Karaf
  template "#{node['aet']['karaf']['root_dir']}/current/bin/setenv.bat" do
    source 'content/karaf/current/bin/setenv.bat.erb'
    owner node['aet']['karaf']['user']
    group node['aet']['karaf']['group']
    mode '0644'

    notifies :restart, 'service[karaf]', :delayed
  end

  srv_install_cmd =
    "nssm install karaf #{node['aet']['karaf']['root_dir']}"\
    '/current/bin/karaf.bat'

  execute 'config-karaf-service' do
    command srv_install_cmd
    action :run

    not_if { ::Win32::Service.exists?('karaf') }
  end
else
  # Overwrite JVM properties for Karaf
  template "#{node['aet']['karaf']['root_dir']}/current/bin/setenv" do
    source 'content/karaf/current/bin/setenv.erb'
    owner node['aet']['karaf']['user']
    group node['aet']['karaf']['group']
    mode '0644'

    notifies :restart, 'service[karaf]', :delayed
  end

  # Create Karaf init file
  template '/etc/init.d/karaf' do
    source 'etc/init.d/karaf.erb'
    owner 'root'
    group 'root'
    mode '0755'

    notifies :restart, 'service[karaf]', :delayed
  end
end

# Configure user credentials
template "#{node['aet']['karaf']['root_dir']}/current/etc/users.properties" do
  source 'content/karaf/current/etc/users.properties.erb'
  owner node['aet']['karaf']['user']
  group node['aet']['karaf']['group']
  mode '0644'
end

# Configure Web console port
template "#{node['aet']['karaf']['root_dir']}/current/etc/"\
  'org.ops4j.pax.web.cfg' do
  source 'content/karaf/current/etc/org.ops4j.pax.web.cfg.erb'
  owner node['aet']['karaf']['user']
  group node['aet']['karaf']['group']
  mode '0644'

  notifies :restart, 'service[karaf]', :delayed
end

# Configure SSH console port
template "#{node['aet']['karaf']['root_dir']}/current/etc/"\
  'org.apache.karaf.shell.cfg' do
  source 'content/karaf/current/etc/org.apache.karaf.shell.cfg.erb'
  owner node['aet']['karaf']['user']
  group node['aet']['karaf']['group']
  mode '0644'

  notifies :restart, 'service[karaf]', :delayed
end

# Remove old logs directory
directory "#{node['aet']['karaf']['root_dir']}/current/data/log" do
  recursive true
  action :delete
  not_if do
    ::File.symlink?("#{node['aet']['karaf']['root_dir']}/current/data/log")
  end
end

# Create symplink for logs directory
link "#{node['aet']['karaf']['root_dir']}/current/data/log" do
  to node['aet']['karaf']['log_dir']
end

# Enable and start Karaf
service 'karaf' do
  supports status: true, restart: true
  action [:start, :enable]
end
