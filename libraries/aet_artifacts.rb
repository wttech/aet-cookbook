#
# Cookbook Name:: aet
# Library:: aet_artifacts
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

def setup_aet_artifact(artifact_type)
  ver = node['aet']['version']
  base_dir = node['aet']['karaf']['root_dir']
  work_dir = "#{base_dir}/aet_#{artifact_type}"
  deploy_dir = "#{base_dir}/current/deploy/#{artifact_type}"

  create_aet_artifact_dir("#{base_dir}/aet_#{artifact_type}")

  target_file = "#{base_dir}/current/etc/org.apache.felix.fileinstall-deploy-#{artifact_type}.cfg"
  create_fileinstall_config(artifact_type, target_file)

  url = "#{node['aet']['base_link']}/#{ver}/#{artifact_type}.zip"
  file = "#{node['aet']['karaf']['root_dir']}/aet_#{artifact_type}/#{artifact_type}-#{node['aet']['version']}.zip"
  download_artifact(url, file)

  # see `helpers.rb` file
  check_if_new(artifact_type,
               deploy_dir,
               "#{work_dir}/#{ver}",
               "execute[extract-#{artifact_type}]")

  extract_artifact(artifact_type, node['aet']['version'])
end

def create_aet_artifact_dir(path)
  directory path do
    owner node['aet']['karaf']['user']
    group node['aet']['karaf']['group']
    recursive true
    action :create
  end
end

def create_fileinstall_config(artifact_type, target_file)
  template target_file do
    source 'content/karaf/current/etc/org.apache.felix.fileinstall-template.cfg.erb'
    owner node['aet']['karaf']['user']
    group node['aet']['karaf']['group']
    cookbook node['aet']['karaf']['src_cookbook']['bundles_cfg']
    mode '0644'
    variables(
      'artifact_type' => artifact_type
    )

    notifies :restart, 'service[karaf]', :delayed
  end
end

def download_artifact(url, file)
  remote_file file do
    source url
    owner node['aet']['karaf']['user']
    group node['aet']['karaf']['group']
  end
end

def extract_artifact(artifact_type, version)
  execute "extract-#{artifact_type}" do
    command "unzip -o #{artifact_type}-#{version}.zip -d #{version}"
    cwd "#{node['aet']['karaf']['root_dir']}/aet_#{artifact_type}"
    user node['aet']['karaf']['user']
    group node['aet']['karaf']['group']
    action :nothing
  end
end
