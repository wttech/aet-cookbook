#
# Cookbook Name:: aet
# Recipe:: deploy_sample_site
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

# This requires recipes: 'apache', 'tomcat'

# PREREQUISITES
###############################################################################

package 'unzip' do
  action :install
end

# REPORTS DEPLOYMENT
###############################################################################

ver = node['aet']['version']
base_dir = node['aet']['tomcat']['base_dir']
work_dir = "#{base_dir}/aet_sample_site"
sample_site_local_path = "#{work_dir}/sample-site-#{ver}.zip"
sample_site_download_url = "#{node['aet']['base_link']}/#{ver}/sample-site.zip"
sample_site_deploy_dir = "#{work_dir}/current"

# Create AET sample sites directory
directory work_dir do
  owner node['aet']['tomcat']['user']
  group node['aet']['tomcat']['group']
  recursive true
  action :create
end

# Download sample site zip
remote_file sample_site_local_path do
  source sample_site_download_url
  owner node['aet']['tomcat']['user']
  group node['aet']['tomcat']['user']
end

# Check if new version of reports
log 'sample-site-version-changed' do
  message 'version of sample_site has changed. notifying dependant resources...'

  not_if do
    ::File.exist?("#{work_dir}/#{ver}") &&
      ::File.identical?(
        "#{sample_site_deploy_dir}/sample-site.war",
        "#{work_dir}/#{ver}/sample-site.war"
      )
  end

  notifies :run, 'execute[extract-sample-site]', :immediately
  notifies :create, "link[#{sample_site_deploy_dir}]", :immediately
  notifies :restart, 'service[tomcat]', :delayed
end

# Extract sample site zip (skipped by default, run only when notified)
execute 'extract-sample-site' do
  command "unzip -o #{sample_site_local_path} -d #{ver}"
  cwd work_dir
  user node['aet']['tomcat']['user']
  group node['aet']['tomcat']['group']
  action :nothing
end

# Link sample site directory to 'current'
# (skipped by default, run only when notified)
link sample_site_deploy_dir do
  to "#{work_dir}/#{ver}"
  action :nothing
end

# Link sample site to tomcat
link "#{base_dir}/webapps/sample-site.war" do
  to "#{sample_site_deploy_dir}/sample-site.war"
  notifies :restart, 'service[tomcat]', :delayed
end
