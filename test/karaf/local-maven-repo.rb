
# local Maven repo folder should exists
describe file('/opt/aet/karaf/m2/repository') do
    it { should exist }
    it { should be_directory }
    its('owner') { should eq 'karaf' }
end
