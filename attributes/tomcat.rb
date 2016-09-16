#
# Cookbook Name:: aet
# Attributes:: apache
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

###############################################################################
# CORE ELEMENTS

# Use only original TAR.GZ file
default['aet']['tomcat']['source'] = 'http://archive.apache.org/dist/tomcat/'\
  'tomcat-8/v8.0.36/bin/apache-tomcat-8.0.36.tar.gz'

# This cookbook supports only versions 7 and 8
default['aet']['tomcat']['tomcat_version'] = '8'

default['aet']['tomcat']['base_dir'] = '/opt/aet/tomcat'
default['aet']['tomcat']['log_dir'] = '/var/log/tomcat'

default['aet']['tomcat']['user'] = 'tomcat'
default['aet']['tomcat']['group'] = 'tomcat'

default['aet']['tomcat']['debug_enabled'] = false
default['aet']['tomcat']['jmx_enabled'] = true

default['aet']['tomcat']['port'] = '9090'
default['aet']['tomcat']['jmx_ip'] = '0.0.0.0'
default['aet']['tomcat']['jmx_port'] = '19090'
default['aet']['tomcat']['debug_port'] = '29090'

default['aet']['tomcat']['min_heap'] = '256'
default['aet']['tomcat']['max_heap'] = '512'
default['aet']['tomcat']['max_permsize'] = '256'
default['aet']['tomcat']['code_cache'] = '64'
default['aet']['tomcat']['extra_opts'] = ''

default['aet']['tomcat']['init']['source_cookbook'] = 'aet'
default['aet']['tomcat']['setenv.sh']['source_cookbook'] = 'aet'
default['aet']['tomcat']['server.xml']['source_cookbook'] = 'aet'
default['aet']['tomcat']['tomcat-users.xml']['source_cookbook'] = 'aet'

###############################################################################
# PROPERTIES

# MaxSwallowSize (only version 8)
default['aet']['tomcat']['connector']['maxswallowsize'] = '2097152'

###############################################################################
# DEPLOYMENT

default['aet']['tomcat']['login'] = 'admin'
default['aet']['tomcat']['password'] = 'admin'

default['aet']['tomcat']['context']['source_cookbook'] = 'aet'
