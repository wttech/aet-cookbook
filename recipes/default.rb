#
# Cookbook Name:: aet
# Recipe:: default
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

# Base packages and X Windows System
include_recipe 'aet::display'

# Apache to handle reports
include_recipe 'aet::apache'

# MongoDB to store AET results and patterns
include_recipe 'aet::mongo'

# ActiveMQ to queue tasks scheduled for AET run
include_recipe 'aet::activemq'

# Browsermob proxy to catch pages that are displayed during AET run
include_recipe 'aet::browsermob'

# Firefox to handle displaying the page during AET run
include_recipe 'aet::firefox'

# Xvfb to handlin virtual displays for Firefox
include_recipe 'aet::xvfb'

# Tomcat to host sample sites
include_recipe 'aet::tomcat'

# Selenium Grid hub to dispatch tests to many browsers
include_recipe 'aet::seleniumgrid_hub'

# Selenium Grid node to handle tests on Firefox browser
include_recipe 'aet::seleniumgrid_node_ff'

# Karaf to host AET bundles and be the core of the system
include_recipe 'aet::karaf'

# Deploying current version of AET artifacts for Karaf
include_recipe 'aet::deploy_aet_for_karaf'

# Deploying current version of AET reports to Apache
include_recipe 'aet::deploy_reports'

# Deploying current version of AET sample site to Tomcat
include_recipe 'aet::deploy_sample_site'

# Restart instance after X installation
include_recipe 'aet::postdeploy_restart'

# Executing reboot after installation of X Window System
include_recipe 'aet::reboot'
