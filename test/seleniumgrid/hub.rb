
describe service('hub') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
end

describe port(4444) do
    it { should be_listening }
end
