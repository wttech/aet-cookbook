#
# Cookbook Name:: aet
# Recipe:: deploy_reports
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

# This requires Apache

# PREREQUISITES
###############################################################################

package 'unzip' do
  action :install
end

# REPORTS DEPLOYMENT
###############################################################################

ver = node['aet']['version']
base_dir = node['aet']['apache']['report_base_dir']
work_dir = "#{base_dir}/aet_reports"
reports_local_path = "#{work_dir}/report-#{ver}.zip"
reports_download_url = "#{node['aet']['base_link']}/#{ver}/report.zip"
reports_deploy_dir = "#{work_dir}/current"

# Create AET config directory
directory work_dir do
  owner node['apache']['user']
  group node['apache']['group']
  mode '0775'

  recursive true
  action :create
end

# Download reports zip
remote_file reports_local_path do
  source reports_download_url
  owner node['apache']['user']
  group node['apache']['group']
end

# Check if new version of reports
log 'reports-version-changed' do
  message 'version of reports web application has changed.'\
          'notifying dependant resources...'

  not_if do
    ::File.exist?("#{work_dir}/#{ver}") &&
      ::File.identical?(
        reports_deploy_dir,
        "#{work_dir}/#{ver}"
      )
  end

  notifies :run, 'execute[extract-reports]', :immediately
  notifies :create, "link[#{reports_deploy_dir}]", :immediately
  notifies :restart, 'service[apache2]', :delayed
end

# Extract reports zip (skipped by default, run only when notified)
execute 'extract-reports' do
  command "unzip -o -q #{reports_local_path} -d #{ver}"
  cwd work_dir
  user node['apache']['user']
  group node['apache']['group']
  action :nothing
end

# Link reports directory to 'current'
# (skipped by default, run only when notified)
link reports_deploy_dir do
  to "#{work_dir}/#{ver}"
  action :nothing
end

# Create virtualhost with docroot pointing to current reports directory
template '/etc/httpd/sites-available/aet.conf' do
  source 'etc/httpd/sites-available/aet.conf.erb'
  owner 'root'
  group 'root'
  cookbook node['aet']['apache']['src_cookbook']['reports_conf']
  mode 0644
  notifies :restart, 'service[apache2]', :delayed
end

# Enable virtual host
link '/etc/httpd/sites-enabled/aet.conf' do
  to '/etc/httpd/sites-available/aet.conf'
end
