#
# Cookbook Name:: aet
# Attributes:: seleniumgrid
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

default['aet']['seleniumgrid']['user'] = 'seleniumgrid'
default['aet']['seleniumgrid']['group'] = 'seleniumgrid'

default['aet']['seleniumgrid']['hub']['root_dir'] = '/opt/aet/seleniumgrid/hub'

default['aet']['seleniumgrid']['hub']['log_dir'] = '/var/log/seleniumgrid'

default['aet']['seleniumgrid']['source'] = 'http://selenium-release.storage.googleapis.com/3.8/selenium-server-standalone-3.8.1.jar'

default['aet']['seleniumgrid']['src_cookbook']['init_script'] = 'aet'
