#
# Cookbook Name:: aet
# Attributes:: activemq
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

# ACTIVEMQ
default['aet']['activemq']['version'] = '5.15.2'
default['aet']['activemq']['root_dir'] = '/opt/aet/activemq'
default['aet']['activemq']['log_dir'] = '/var/log/activemq'
default['aet']['activemq']['source']  = 'https://archive.apache.org/dist/'\
  'activemq/5.15.2/apache-activemq-5.15.2-bin.tar.gz'

default['aet']['activemq']['user'] = 'activemq'
default['aet']['activemq']['group'] = 'activemq'

default['aet']['activemq']['login'] = 'admin'
default['aet']['activemq']['password'] = 'admin'

default['aet']['activemq']['java_min_mem'] = '64M'
default['aet']['activemq']['java_max_mem'] = '1024M'
default['aet']['activemq']['java_min_perm_mem'] = '64M'
default['aet']['activemq']['java_max_perm_mem'] = '128M'

default['aet']['activemq']['jmx_port'] = '11199'
default['aet']['activemq']['jmx_ip'] = node['ipaddress']

default['aet']['activemq']['enable_debug'] = false

default['aet']['activemq']['src_cookbook']['env'] = 'aet'
default['aet']['activemq']['src_cookbook']['activemq_xml'] = 'aet'
default['aet']['activemq']['src_cookbook']['jetty_prop'] = 'aet'
default['aet']['activemq']['src_cookbook']['log4j_prop'] = 'aet'
