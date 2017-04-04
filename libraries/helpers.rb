#
# Cookbook Name:: aet
# Library:: helpers
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

def get_filename(uri)
  require 'uri'
  Pathname.new(URI.parse(uri).path).basename.to_s
end

def parent(path)
  Pathname.new(path).parent.to_s
end

def similar?(file_a, file_b)
  ::File.exist?(file_a) && ::File.exist?(file_b) &&
    ::File.identical?(
      file_a,
      file_b
    )
end

def check_if_new(artifacts_name, deploy_dir, version_dir)
  log "#{artifacts_name}-version-changed" do
    message "version of #{artifacts_name} has changed."\
            'notifying dependant resources...'

    not_if { similar?(deploy_dir, version_dir) }

    notifies :stop, 'service[karaf-deploy-stop]', :immediately
    if windows?
      notifies :unzip,
               "windows_zipfile[extract-#{artifacts_name}]",
               :immediately
    else
      notifies :run, "execute[extract-#{artifacts_name}]", :immediately
    end
    notifies :create, 'file[schedule-karaf-restart]', :immediately
  end

  create_link(deploy_dir, version_dir)
end

def create_link(link, folder)
  if windows?
    # We have to use junctions for Windows because links do not work properly
    batch "Link #{link} to #{folder}" do
      code <<-EOH
        rmdir /S /Q "#{link}"
        mklink /J "#{link}" "#{folder}"
      EOH
      not_if { similar?(link, folder) }
    end
  else
    link link do
      to folder
    end
  end
end

def wait_for_response_code(uri, expected_code, timeout_in_seconds)
  start_time = Time.now
  time_diff = 0
  puts "\nwaiting for response code #{expected_code} from #{uri}"
  while get_response_code(uri) != expected_code.to_s
    time_diff = Time.now - start_time
    abort_if_too_long(time_diff, timeout_in_seconds, uri, expected_code)
    puts 'incorrect response code. will try again in 5 seconds...'
    sleep(5)
  end
  time_diff
end

def abort_if_too_long(time_diff, timeout_in_seconds, uri, expected_code)
  abort "Aborting since waiting for response code #{expected_code} "\
        "from #{uri} took more than #{timeout_in_seconds}"\
        'seconds' if time_diff > timeout_in_seconds
end

def get_response_code(uri)
  require 'net/http'
  response = -1
  begin
    response = Net::HTTP.get_response(uri).code
  rescue => e
    Chef::Log.debug("Error occurred while trying to send GET #{uri} "\
                        "request: #{e}")
  end
  response
end
