#
# Cookbook Name:: aet
# Attributes:: browsermob
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

default['aet']['browsermob']['source'] = 'https://github.com/lightbody/'\
  'browsermob-proxy/releases/download/'\
  'browsermob-proxy-2.1.4/browsermob-proxy-2.1.4-bin.zip'

default['aet']['browsermob']['root_dir'] = '/opt/aet/browsermob'
default['aet']['browsermob']['log_dir'] = '/var/log/browsermob'

default['aet']['browsermob']['user'] = 'browsermob'
default['aet']['browsermob']['group'] = 'browsermob'

default['aet']['browsermob']['port'] = '8080'
default['aet']['browsermob']['proxy_port_range'] = '8081-8151'

default['aet']['browsermob']['src_cookbook']['init_script'] = 'aet'
