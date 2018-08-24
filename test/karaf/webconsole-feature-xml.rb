
# tests aet features file for webconsole
describe file('/opt/aet/karaf/aet_features/current/aet-webconsole.xml') do
    it { should exist }
    its('content') { should match(%r{\<feature\>webconsole\</feature\>}) }
    its('content') { should match(%r{\<bundle\>mvn:org\.apache\.karaf\.webconsole/org\.apache\.karaf\.webconsole\.features/[\d\.]+\</bundle\>}) }
end
