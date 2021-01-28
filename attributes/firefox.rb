#
# Cookbook Name:: aet
# Attributes:: firefox
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

default['aet']['firefox']['user'] = 'firefox'
default['aet']['firefox']['group'] = 'firefox'

default['aet']['firefox']['root_dir'] = '/opt/aet/firefox'

default['aet']['firefox']['log_dir'] = '/opt/aet/firefox/log'

default['aet']['firefox']['source'] = 'https://ftp.mozilla.org/pub/firefox/'\
  'releases/38.6.0esr/linux-x86_64/en-US/firefox-38.6.0esr.tar.bz2'

default['aet']['firefox']['src_cookbook']['bin'] = 'aet'
