#
# Cookbook Name:: aet
# Recipe:: browsermob
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

# PREREQUISITES
###############################################################################

include_recipe 'java::default'

package 'unzip' do
  action :install

  not_if { windows? }
end

# INSTALLATION
###############################################################################

unless windows?
  # Create deducated group
  group node['aet']['browsermob']['group'] do
    action :create
  end

  # Create dedicated user
  user node['aet']['browsermob']['user'] do
    group node['aet']['browsermob']['group']
    home "/home/#{node['aet']['browsermob']['user']}"
    shell '/bin/bash'
    action :create
  end
end

# Create dedicated root directory
directory node['aet']['browsermob']['root_dir'] do
  owner node['aet']['browsermob']['user']
  group node['aet']['browsermob']['group']
  mode '0755'
  action :create
  recursive true
end

# Create dedicated log directory
directory node['aet']['browsermob']['log_dir'] do
  owner node['aet']['browsermob']['user']
  group node['aet']['browsermob']['group']
  mode '0755'
  action :create
  recursive true
end

# Get binaries file name from link
filename = get_filename(node['aet']['browsermob']['source'])

remote_file "#{node['aet']['browsermob']['root_dir']}/#{filename}" do
  owner node['aet']['browsermob']['user']
  group node['aet']['browsermob']['group']
  mode '0644'
  source node['aet']['browsermob']['source']
end

# Get file name without extension
basename = ::File.basename(filename, '-bin.zip')

# This is basically the name of the directory that Karaf extracted itself to
if windows?
  # Extract browsermob
  windows_zipfile node['aet']['browsermob']['root_dir'] do
    source "#{node['aet']['browsermob']['root_dir']}/#{filename}"
    action :unzip

    not_if do
      ::File.exist?(
        "#{node['aet']['browsermob']['root_dir']}/"\
        "#{basename}/bin/browsermob-proxy"
      )
    end
  end
else
  # Extract browsermob
  execute 'extract browsermob' do
    command "unzip -o #{filename}"
    cwd node['aet']['browsermob']['root_dir']

    user node['aet']['browsermob']['user']
    group node['aet']['browsermob']['group']

    not_if do
      ::File.exist?(
        "#{node['aet']['browsermob']['root_dir']}/"\
          "#{basename}/bin/browsermob-proxy"
      )
    end
  end
end

# Link extracted browsermob to some common directory
link "#{node['aet']['browsermob']['root_dir']}/current" do
  to "#{node['aet']['browsermob']['root_dir']}/#{basename}"

  notifies :restart, 'service[browsermob]', :delayed
end

if windows?
  srv_install_cmd =
    "nssm install browsermob #{node['aet']['browsermob']['root_dir']}"\
    '/current/bin/browsermob-proxy.bat'

  # browsermob_home = "#{node['aet']['browsermob']['root_dir']}/current"
  # java_home = node['aet']['common']['java_home']

  # srv_install_cmd =
  #   'prunsrv //IS//browsermob '\
  #   '--DisplayName="Browsermob Proxy" '\
  #   '--Description="Browsermob Proxy for AET" '\
  #   '--Startup=auto '\
  #   "--LogPath=\"#{node['aet']['browsermob']['log_dir']}\" "\
  #   '--LogLevel=INFO '\
  #   '--LogPrefix=browsermob-proxy '\
  #   '--StdOutput=auto '\
  #   '--StdError=auto '\
  #   "--StartPath=\"#{browsermob_home}\" "\
  #   '--StartClass=net.lightbody.bmp.proxy.Main '\
  #   '--StartMethod=main '\
  #   '--StartParams=start '\
  #   '--StartMode=jvm '\
  #   "--StopPath=\"#{browsermob_home}\" "\
  #   '--StopClass=net.lightbody.bmp.proxy.Main '\
  #   '--StopMethod=main '\
  #   '--StopParams=stop '\
  #   '--StopMode=jvm '\
  #   '--StopTimeout=1 '\
  #   "--JavaHome=\"#{java_home}\" "\
  #   "--Jvm=\"#{java_home}\\jre\\bin\\server\\jvm.dll\" "\
  #   '--JvmOptions=-Xmx1024M '\
  #   "--Classpath=\"#{browsermob_home}\\etc;#{browsermob_home}\\lib\\slf4j-api-1.7.7.jar;#{browsermob_home}\\lib\\slf4j-jdk14-1.7.7.jar;#{browsermob_home}\\lib\\sitebricks-0.8.9.jar;#{browsermob_home}\\lib\\sitebricks-converter-0.8.9.jar;#{browsermob_home}\\lib\\sitebricks-client-0.8.9.jar;#{browsermob_home}\\lib\\xstream-1.3.1.jar;#{browsermob_home}\\lib\\xpp3_min-1.1.4c.jar;#{browsermob_home}\\lib\\sitebricks-annotations-0.8.9.jar;#{browsermob_home}\\lib\\mvel2-2.1.3.Final.jar;#{browsermob_home}\\lib\\guava-15.0.jar;#{browsermob_home}\\lib\\annotations-7.0.3.jar;#{browsermob_home}\\lib\\async-http-client-1.6.3.jar;#{browsermob_home}\\lib\\netty-3.2.4.Final.jar;#{browsermob_home}\\lib\\jsoup-1.5.2.jar;#{browsermob_home}\\lib\\validation-api-1.0.0.GA.jar;#{browsermob_home}\\lib\\guice-multibindings-3.0.jar;#{browsermob_home}\\lib\\jackson-core-2.4.4.jar;#{browsermob_home}\\lib\\jackson-databind-2.4.4.jar;#{browsermob_home}\\lib\\jackson-annotations-2.4.0.jar;#{browsermob_home}\\lib\\httpclient-4.3.4.jar;#{browsermob_home}\\lib\\httpcore-4.3.2.jar;#{browsermob_home}\\lib\\commons-logging-1.1.3.jar;#{browsermob_home}\\lib\\commons-codec-1.6.jar;#{browsermob_home}\\lib\\httpmime-4.3.4.jar;#{browsermob_home}\\lib\\jopt-simple-3.2.jar;#{browsermob_home}\\lib\\ant-1.8.2.jar;#{browsermob_home}\\lib\\ant-launcher-1.8.2.jar;#{browsermob_home}\\lib\\bcprov-jdk15on-1.47.jar;#{browsermob_home}\\lib\\jetty-server-7.3.0.v20110203.jar;#{browsermob_home}\\lib\\servlet-api-2.5.jar;#{browsermob_home}\\lib\\jetty-continuation-7.3.0.v20110203.jar;#{browsermob_home}\\lib\\jetty-http-7.3.0.v20110203.jar;#{browsermob_home}\\lib\\jetty-io-7.3.0.v20110203.jar;#{browsermob_home}\\lib\\jetty-util-7.3.0.v20110203.jar;#{browsermob_home}\\lib\\jetty-servlet-7.3.0.v20110203.jar;#{browsermob_home}\\lib\\jetty-security-7.3.0.v20110203.jar;#{browsermob_home}\\lib\\guice-3.0.jar;#{browsermob_home}\\lib\\javax.inject-1.jar;#{browsermob_home}\\lib\\aopalliance-1.0.jar;#{browsermob_home}\\lib\\guice-servlet-3.0.jar;#{browsermob_home}\\lib\\jcip-annotations-1.0.jar;#{browsermob_home}\\lib\\selenium-api-2.43.0.jar;#{browsermob_home}\\lib\\json-20080701.jar;#{browsermob_home}\\lib\\uadetector-resources-2014.10.jar;#{browsermob_home}\\lib\\uadetector-core-0.9.22.jar;#{browsermob_home}\\lib\\quality-check-1.3.jar;#{browsermob_home}\\lib\\jsr305-2.0.3.jar;#{browsermob_home}\\lib\\jsr250-api-1.0.jar;#{browsermob_home}\\lib\\arquillian-phantom-driver-1.1.1.Final.jar;#{browsermob_home}\\lib\\shrinkwrap-resolver-api-2.0.0.jar;#{browsermob_home}\\lib\\shrinkwrap-resolver-spi-2.0.0.jar;#{browsermob_home}\\lib\\shrinkwrap-resolver-api-maven-2.0.0.jar;#{browsermob_home}\\lib\\shrinkwrap-resolver-spi-maven-2.0.0.jar;#{browsermob_home}\\lib\\shrinkwrap-resolver-impl-maven-2.0.0.jar;#{browsermob_home}\\lib\\aether-api-1.13.1.jar;#{browsermob_home}\\lib\\aether-impl-1.13.1.jar;#{browsermob_home}\\lib\\aether-spi-1.13.1.jar;#{browsermob_home}\\lib\\aether-util-1.13.1.jar;#{browsermob_home}\\lib\\aether-connector-wagon-1.13.1.jar;#{browsermob_home}\\lib\\maven-aether-provider-3.0.5.jar;#{browsermob_home}\\lib\\maven-model-3.0.5.jar;#{browsermob_home}\\lib\\maven-model-builder-3.0.5.jar;#{browsermob_home}\\lib\\maven-repository-metadata-3.0.5.jar;#{browsermob_home}\\lib\\maven-settings-3.0.5.jar;#{browsermob_home}\\lib\\maven-settings-builder-3.0.5.jar;#{browsermob_home}\\lib\\plexus-interpolation-1.14.jar;#{browsermob_home}\\lib\\plexus-utils-2.0.6.jar;#{browsermob_home}\\lib\\plexus-sec-dispatcher-1.4.jar;#{browsermob_home}\\lib\\plexus-cipher-1.4.jar;#{browsermob_home}\\lib\\wagon-provider-api-2.4.jar;#{browsermob_home}\\lib\\wagon-file-2.4.jar;#{browsermob_home}\\lib\\wagon-http-lightweight-2.4.jar;#{browsermob_home}\\lib\\wagon-http-shared4-2.4.jar;#{browsermob_home}\\lib\\shrinkwrap-resolver-impl-maven-archive-2.0.0.jar;#{browsermob_home}\\lib\\shrinkwrap-impl-base-1.1.2.jar;#{browsermob_home}\\lib\\shrinkwrap-api-1.1.2.jar;#{browsermob_home}\\lib\\shrinkwrap-spi-1.1.2.jar;#{browsermob_home}\\lib\\shrinkwrap-resolver-api-maven-archive-2.0.0.jar;#{browsermob_home}\\lib\\shrinkwrap-resolver-spi-maven-archive-2.0.0.jar;#{browsermob_home}\\lib\\plexus-compiler-javac-2.1.jar;#{browsermob_home}\\lib\\plexus-compiler-api-2.1.jar;#{browsermob_home}\\lib\\plexus-component-api-1.0-alpha-33.jar;#{browsermob_home}\\lib\\plexus-classworlds-1.2-alpha-10.jar;#{browsermob_home}\\lib\\commons-io-2.4.jar;#{browsermob_home}\\lib\\browsermob-proxy-2.0.0.jar\" "\
  #   '--JvmOptions=-XX:MaxPermSize=256m '\
  #   "--JvmOptions=-Djava.ext.dirs=\"#{java_home}\\jre\\lib\\ext\" "\
  #   '--JvmOptions=-Dapp.name==\"browsermob-proxy\" '\
  #   "--JvmOptions=-Dapp.repo=\"#{browsermob_home}\\lib\" "\
  #   "--JvmOptions=-Dbasedir=\"#{browsermob_home}\" "\
  #   '--JvmOptions=-Dcom.sun.management.jmxremote.port=9104 '\
  #   '--JvmOptions=-Dcom.sun.management.jmxremote.authenticate=false '\
  #   '--JvmOptions=-Dcom.sun.management.jmxremote.ssl=false'

  execute 'config-browsermob-service' do
    command srv_install_cmd
    action :run

    not_if { ::Win32::Service.exists?('browsermob') }
  end
else
  # Create init script for browsermob
  template '/etc/init.d/browsermob' do
    source 'etc/init.d/browsermob.erb'
    owner 'root'
    group 'root'
    mode '0755'

    notifies :restart, 'service[browsermob]', :delayed
  end
end
# Enable and start browsermob service
service 'browsermob' do
  action [:start, :enable]
end
