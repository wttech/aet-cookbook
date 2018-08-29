
describe service('activemq') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
end

describe file('/opt/aet/activemq') do
    it { should exist }
    it { should be_directory }
    its('owner') { should eq 'activemq' }
end

describe port(8161) do
    # wait for activemq to start
    before do
        sleep 30
    end
    it { should be_listening }
end
