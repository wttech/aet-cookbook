#
# Cookbook Name:: aet
# Recipe:: deploy_aet_for_karaf
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

# This requires recipes: 'karaf' and 'postdeploy_restart'

# PREREQUISITES
###############################################################################

package 'unzip' do
  action :install
end

# APP DEPLOYMENT
###############################################################################

setup_aet_artifact 'configs'
setup_aet_artifact 'features'
setup_aet_artifact 'bundles'

base_dir = node['aet']['karaf']['root_dir']

create_fileinstall_config(base_dir, 'configs')
create_fileinstall_config(base_dir, 'features')
create_fileinstall_config(base_dir, 'bundles')
