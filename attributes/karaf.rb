#
# Cookbook Name:: aet
# Attributes:: karaf
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

# KARAF

default['aet']['karaf']['source'] =
  'https://archive.apache.org/dist/karaf/4.2.0/apache-karaf-4.2.0.tar.gz'

default['aet']['karaf']['user'] = 'karaf'
default['aet']['karaf']['group'] = 'karaf'

default['aet']['karaf']['login'] = 'karaf'
default['aet']['karaf']['password'] = 'karaf'

default['aet']['karaf']['root_dir'] = '/opt/aet/karaf'
default['aet']['karaf']['log_dir'] = '/var/log/karaf'

default['aet']['karaf']['enable_debug'] = false
default['aet']['karaf']['web_port'] = '8181'
default['aet']['karaf']['ssh_port'] = '8101'

default['aet']['karaf']['java_min_mem'] = '512M'
default['aet']['karaf']['java_max_mem'] = '1024M'
default['aet']['karaf']['java_min_perm_mem'] = '64M'
default['aet']['karaf']['java_max_perm_mem'] = '128M'

default['aet']['karaf']['src_cookbook']['setenv'] = 'aet'
default['aet']['karaf']['src_cookbook']['config_prop'] = 'aet'
default['aet']['karaf']['src_cookbook']['users_prop'] = 'aet'
default['aet']['karaf']['src_cookbook']['fileinstall_configs_prop'] = 'aet'
default['aet']['karaf']['src_cookbook']['fileinstall_features_prop'] = 'aet'
default['aet']['karaf']['src_cookbook']['fileinstall_bundles_prop'] = 'aet'
default['aet']['karaf']['src_cookbook']['shell_cfg'] = 'aet'
default['aet']['karaf']['src_cookbook']['ops4j_cfg'] = 'aet'
default['aet']['karaf']['src_cookbook']['init_script'] = 'aet'
