#
# Cookbook Name:: aet
# Attributes:: apache
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

default['aet']['apache']['report_base_dir'] = '/opt/aet/apache'
default['aet']['apache']['log_dir'] = '/var/log/apache'
default['aet']['apache']['karaf_ip'] = 'localhost'
default['aet']['apache']['src_cookbook']['reports_conf'] = 'aet'
