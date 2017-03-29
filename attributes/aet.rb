#
# Cookbook Name:: aet
# Attributes:: aet
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

# AET
default['aet']['version'] = '2.0.2'
default['aet']['base_link'] =
  'https://github.com/Cognifide/AET/releases/download'


# CONFIG
default['aet']['config']['mongodb_uri'] = 'mongodb://192.168.123.112'
default['aet']['config']['mongodb_autocreate'] = 'true'

default['aet']['config']['activemq_uri'] =
  'failover:tcp://192.168.123.112:61616'
default['aet']['config']['activemq_user'] = 'admin'
default['aet']['config']['activemq_pass'] = 'admin'
default['aet']['config']['activemq_jmxuri'] =
  'service:jmx:rmi:///jndi/rmi://192.168.123.112:11199/jmxrmi'

default['aet']['config']['report_uri'] = 'http://aet-vagrant'
