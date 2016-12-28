#
# Cookbook Name:: aet
# Attributes:: common
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

# JAVA
default['java']['oracle']['accept_oracle_download_terms'] = 'true'
default['java']['jdk_version'] = '7'
default['java']['install_flavor'] = 'oracle'

default['java']['windows']['url'] = 'http://download.oracle.com/'\
  'otn-pub/java/jdk/7u79-b15/jdk-7u79-windows-x64.exe'
default['java']['windows']['package_name'] =
  'Java 7 Update 79 (64-bit)'

default['aet']['common']['java_home'] =
  'C:/Program Files/Java/jdk1.7.0_79'
