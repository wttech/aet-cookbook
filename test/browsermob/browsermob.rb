
describe service('browsermob') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
end

describe file('/opt/aet/browsermob') do
    it { should exist }
    it { should be_directory }
    its('owner') { should eq 'browsermob' }
end

describe port(8080) do
    it { should be_listening }
end
