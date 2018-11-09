
describe service('mongod') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
end

describe port(27017) do
    it { should be_listening }
end

describe file('/opt/aet/mongodb/db') do
  it { should exist }
  it { should be_directory  }
  it { should be_owned_by 'mongod' }
end
